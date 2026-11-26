-- =============================================================================
-- Gestão Fotovoltaica: consultas (relatórios)
-- =============================================================================
-- Execute DEPOIS do 01_estrutura.sql e do 02_povoamento.sql.
--
-- São 12 consultas, cada uma com uma frase explicando o que ela faz:
--   01 a 03  consultas com junção (JOIN)
--   04 a 06  consultas com agrupamento (GROUP BY, funções agregadas e HAVING)
--   07 a 09  consultas com funções de data
--   10 a 12  consultas aninhadas (subconsultas)
--
-- As consultas de data usam a data atual (CURDATE()), então o resultado
-- depende do dia em que forem executadas.
--
-- Para executar uma consulta só no MySQL Workbench, coloque o cursor sobre
-- ela e pressione Ctrl+Enter.
-- =============================================================================

USE gestao_fotovoltaica;


-- -----------------------------------------------------------------------------
-- Consulta 01 (junção) - RF11
-- Lista as obras com o nome do cliente, o nome do engenheiro responsável,
-- a concessionária e a cidade onde a usina foi instalada.
-- -----------------------------------------------------------------------------

SELECT obra.id,
       obra.dataContrato,
       obra.valorContrato,
       pc.nome AS cliente,
       pe.nome AS engenheiro,
       concessionaria.nome AS concessionaria,
       cidade.nome AS cidade,
       cidade.uf AS estado
FROM obra
INNER JOIN cliente          ON obra.cliente_id = cliente.id
INNER JOIN engenheiro       ON obra.engenheiro_id = engenheiro.id
INNER JOIN pessoa AS pc       ON cliente.pessoa_id = pc.id
INNER JOIN pessoa AS pe       ON engenheiro.pessoa_id = pe.id
INNER JOIN concessionaria   ON obra.concessionaria_id = concessionaria.id
INNER JOIN cidade           ON obra.cidade_id = cidade.id;


-- -----------------------------------------------------------------------------
-- Consulta 02 (junção) - RF12
-- Lista os equipamentos instalados em cada obra, com o tipo, o modelo, o
-- fabricante, a quantidade, o valor unitário cobrado na obra e o total de
-- cada item (quantidade × valor unitário).
-- -----------------------------------------------------------------------------

SELECT
    obra_equipamento.obra_id,
    equipamento.tipo,
    equipamento.modelo,
    fabricante.nome AS fabricante,
    obra_equipamento.quantidade,
    obra_equipamento.valorUnitario,
    obra_equipamento.valorUnitario * obra_equipamento.quantidade AS total
FROM obra_equipamento
INNER JOIN equipamento ON obra_equipamento.equipamento_id = equipamento.id
INNER JOIN fabricante  ON equipamento.fabricante_id = fabricante.id
ORDER BY obra_equipamento.obra_id;


-- -----------------------------------------------------------------------------
-- Consulta 03 (junção) - RF13
-- Lista os clientes com o nome, o CPF ou CNPJ, o tipo de cliente (PF para
-- pessoa física ou PJ para pessoa jurídica, deduzido pela quantidade de
-- dígitos do documento) e a cidade e UF onde moram.
-- -----------------------------------------------------------------------------

SELECT pessoa.nome     AS cliente,
       cliente.cpfCnpj AS documento,
       IF(CHAR_LENGTH(cliente.cpfCnpj) = 11, 'Pessoa Física', 'Pessoa Jurídica') AS tipo,
       cidade.nome     AS cidade,
       cidade.uf       AS estado
FROM cliente
INNER JOIN pessoa   ON cliente.pessoa_id = pessoa.id
INNER JOIN cidade ON pessoa.cidade_id = cidade.id
ORDER BY cliente;


-- -----------------------------------------------------------------------------
-- Consulta 04 (agrupamento) - RF14
-- Mostra a potência total instalada (kWp) por cada engenheiro, somando
-- quantidade × potência dos módulos de todas as obras concluídas pelas
-- quais ele é responsável. A potência dos módulos está em watts; divide-se
-- por 1000 para obter kWp.
-- -----------------------------------------------------------------------------

SELECT pessoa.nome AS engenheiro,
       ROUND(SUM(equipamento.potenciaW/1000 * obra_equipamento.quantidade),2) AS potenciaInstalada
FROM pessoa
INNER JOIN engenheiro         ON engenheiro.pessoa_id = pessoa.id
INNER JOIN obra             ON obra.engenheiro_id = engenheiro.id
INNER JOIN obra_equipamento ON obra_equipamento.obra_id = obra.id
INNER JOIN equipamento      ON obra_equipamento.equipamento_id = equipamento.id
WHERE (equipamento.tipo = 'modulo' AND obra.dataConclusao IS NOT NULL)
GROUP BY pessoa.id, pessoa.nome
ORDER BY potenciaInstalada DESC;



-- -----------------------------------------------------------------------------
-- Consulta 05 (agrupamento) - RF15
-- Mostra, para cada mês, a quantidade de obras contratadas e o valor total
-- vendido (soma dos valores de contrato), considerando a data de assinatura
-- do contrato. Os meses saem em ordem cronológica.
-- -----------------------------------------------------------------------------

SELECT COUNT(obra.id) as quantidade,
       SUM(obra.valorContrato) as valorTotal,
       MONTH(obra.dataContrato) as mes,
       YEAR(obra.dataContrato) as ano
FROM obra
GROUP BY mes, ano
ORDER BY ano, mes;


-- -----------------------------------------------------------------------------
-- Consulta 06 (agrupamento com HAVING) - RF16
-- Lista as concessionárias que têm mais de 2 obras, com o nome, a sigla e a
-- quantidade de obras de cada uma, da que tem mais obras para a que tem menos.
-- O filtro é aplicado depois do agrupamento (HAVING), porque depende da
-- contagem. No sistema, o número mínimo de obras é informado pelo usuário.
-- -----------------------------------------------------------------------------

SELECT concessionaria.nome, concessionaria.sigla, COUNT(obra.concessionaria_id) AS qtdeObras
FROM concessionaria
INNER JOIN obra ON concessionaria.id = obra.concessionaria_id
GROUP BY concessionaria.nome, concessionaria.sigla
HAVING COUNT(obra.concessionaria_id) > 2
ORDER BY qtdeObras DESC;


-- -----------------------------------------------------------------------------
-- Consulta 07 (função de data) - RF17
-- Mostra, para cada obra já homologada, a concessionária, a data do protocolo,
-- a data da aprovação e quantos dias a concessionária levou para aprovar
-- (diferença entre a aprovação e o protocolo). As obras sem aprovação ficam
-- de fora. Ordena da homologação mais demorada para a mais rápida.
-- -----------------------------------------------------------------------------

SELECT obra.id as obra,
       concessionaria.sigla,
       obra.dataProtocolo,
       obra.dataAprovacao,
       DATEDIFF(obra.dataAprovacao, obra.dataProtocolo) AS tempoAprovacao
FROM concessionaria
INNER JOIN obra ON concessionaria.id = obra.concessionaria_id
WHERE (obra.dataAprovacao IS NOT NULL)
ORDER BY tempoAprovacao DESC, obra.dataProtocolo;


-- -----------------------------------------------------------------------------
-- Consulta 08 (função de data) - RF18
-- Lista as obras atrasadas: as que ainda não foram concluídas e cuja data
-- prevista de conclusão já passou. Mostra o número da obra, o nome do
-- cliente, a data prevista e há quantos dias a obra está atrasada, contando
-- até a data de hoje (CURDATE()). Ordena da obra mais atrasada para a menos.
-- -----------------------------------------------------------------------------

SELECT obra.id AS obra,
       pessoa.nome as cliente,
       obra.dataPrevista,
       DATEDIFF(CURDATE(), obra.dataPrevista) AS tempoAtraso
FROM obra
INNER JOIN cliente ON obra.cliente_id = cliente.id
INNER JOIN pessoa ON cliente.pessoa_id = pessoa.id
WHERE (DATEDIFF(CURDATE(), obra.dataPrevista) > 0 AND obra.dataConclusao IS NULL)
ORDER BY tempoAtraso DESC;

-- -----------------------------------------------------------------------------
-- Consulta 09 (função de data) - RF19
-- Lista os equipamentos instalados cuja garantia vence nos próximos 6 meses,
-- contando a partir de hoje (CURDATE()). A garantia começa na data de
-- conclusão da obra e dura a quantidade de anos de garantia do equipamento.
-- Mostra o número da obra, o nome do cliente, o tipo e o modelo do
-- equipamento, a data de conclusão da obra, a data de fim da garantia e os
-- dias restantes para o vencimento da garante, ordenando pela
-- garantia que vence primeiro para a que vence por último.
-- -----------------------------------------------------------------------------

SELECT obra.id AS obra,
       pessoa.nome AS cliente,
       equipamento.tipo AS tipoEquipamento,
       equipamento.modelo AS modeloEquipamento,
       obra.dataConclusao,
       DATE_ADD(obra.dataConclusao, INTERVAL equipamento.garantiaAnos YEAR) AS fimGarantia,
       DATEDIFF(DATE_ADD(obra.dataConclusao, INTERVAL equipamento.garantiaAnos YEAR), CURDATE()) AS diasRestantes
FROM equipamento
INNER JOIN obra_equipamento ON obra_equipamento.equipamento_id = equipamento.id
INNER JOIN obra             ON obra_equipamento.obra_id = obra.id
INNER JOIN cliente          ON obra.cliente_id = cliente.id
INNER JOIN pessoa             ON cliente.pessoa_id = pessoa.id
WHERE (obra.dataConclusao IS NOT NULL)
  AND (DATE_ADD(obra.dataConclusao, INTERVAL equipamento.garantiaAnos YEAR) BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 6 MONTH))
ORDER BY fimGarantia;


-- -----------------------------------------------------------------------------
-- Consulta 10 (aninhada) - RF20
-- Lista as obras cujo valor de contrato é maior que a média dos valores de
-- contrato de todas as obras, com o número da obra, o nome do cliente, a data
-- e o valor do contrato. A média é calculada por uma subconsulta no WHERE.
-- Ordena da obra de maior valor para a de menor.
-- -----------------------------------------------------------------------------

SELECT obra.id AS numObra,
       pessoa.nome AS cliente,
       obra.dataContrato,
       obra.valorContrato
FROM obra
INNER JOIN cliente ON obra.cliente_id = cliente.id
INNER JOIN pessoa    ON cliente.pessoa_id = pessoa.id
WHERE (obra.valorContrato > (SELECT AVG(obra.valorContrato) FROM obra))
ORDER BY obra.valorContrato DESC;