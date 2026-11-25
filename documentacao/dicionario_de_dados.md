# Dicionário de Dados: Gestão Fotovoltaica

Este documento descreve cada tabela e cada coluna do banco `gestao_fotovoltaica`, com tipo, obrigatoriedade, chaves, restrições e significado. Ele segue o [modelo lógico](modelo_logico.md).

## Convenções

| Item | Convenção |
|---|---|
| **Banco** | MariaDB 10.4, motor **InnoDB** (necessário para chaves estrangeiras e transações), codificação `utf8mb4` com ordenação `utf8mb4_unicode_ci`. |
| **Nomes de tabelas** | Em português, minúsculas, sem acentos, no singular e com palavras separadas por `_` (*snake_case*). Ex.: `obra_equipamento`. |
| **Nomes de colunas** | Em português, sem acentos e em *camelCase*. Ex.: `dataContrato`, `valorUnitario`. Nomes de uma palavra só ficam em minúsculas (`nome`, `tipo`). |
| **Chaves primárias** | Sempre `id`, tipo `INT`, com `AUTO_INCREMENT`. |
| **Chaves estrangeiras** | Nome da tabela referenciada + `_id`. Ex.: `obra.cliente_id` aponta para `cliente.id`. |
| **Herança** | As especializações (`cliente` e `engenheiro`) têm o próprio `id` e uma coluna `pessoa_id`, única, que aponta para `pessoa.id`. |
| **Tabelas associativas** | Não têm coluna `id`. A chave primária é composta pelas duas chaves estrangeiras: (`obra_id`, `equipamento_id`). |
| **Nomes de restrições** | Prefixo do tipo + tabela + coluna ou regra, em minúsculas: `pk_` (primária), `uk_` (única), `ck_` (`CHECK`) e `fk_` (estrangeira). Ex.: `fk_obra_cliente`, `ck_obra_valor`. |
| **Valores em dinheiro** | `DECIMAL`, e **nunca** `FLOAT` ou `DOUBLE`. `FLOAT` guarda valores aproximados (por exemplo, 0,1 + 0,2 pode resultar em 0,30000000000000004), o que causa erros de centavos em somas. `DECIMAL` guarda o valor exato. |
| **Datas** | `DATE` (só a data, sem hora), no formato `AAAA-MM-DD`. |
| **CPF, CNPJ e telefone** | Gravados **só com números**, sem pontos, traços, barras ou parênteses. A formatação é feita nas telas. O telefone inclui o DDD. |
| **UF** | Sigla do estado com 2 letras maiúsculas, por exemplo `GO`, `SP`. |
| **Valores de domínio** | Gravados em minúsculas e sem acentos (`monofasica`, `modulo`), e garantidos com `CHECK`. As telas exibem os nomes formatados. |

**Legenda das colunas abaixo:** *PK* = chave primária, *FK* = chave estrangeira, *UK* = valor único. "Nulo: Não" significa que o preenchimento é obrigatório (`NOT NULL`).

---

## Cidades

### cidade
Cidades onde moram as pessoas e onde ficam as obras.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador da cidade. |
| nome | VARCHAR(60) | Não | UK (com `uf`) | | Nome da cidade, com acentos. Ex.: `Goiânia`. |
| uf | CHAR(2) | Não | UK (com `nome`) | 2 letras maiúsculas | Estado da cidade. |

A chave única é o par (`nome`, `uf`), porque existem cidades com o mesmo nome em estados diferentes (RN13).

---

## Hierarquia de pessoas

### pessoa
Dados comuns a clientes e engenheiros. Toda linha desta tabela tem uma linha correspondente em `cliente`, em `engenheiro` ou nas duas, porque a mesma pessoa pode ter os dois papéis (RN12).

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador da pessoa. |
| cidade_id | INT | Não | FK | | Cidade onde a pessoa mora. |
| nome | VARCHAR(100) | Não | | | Nome completo. Para empresas, o nome usado no dia a dia. |
| telefone | VARCHAR(11) | Não | | Só números, com DDD | Telefone de contato. Ex.: `62988887777`. |
| email | VARCHAR(100) | Sim | | | E-mail de contato. Opcional. |
| logradouro | VARCHAR(100) | Não | | | Rua, avenida etc. |
| numero | VARCHAR(10) | Não | | | Número do endereço. É texto para aceitar valores como `S/N` ou `120-A`. |
| bairro | VARCHAR(60) | Não | | | Bairro. |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| cidade_id | cidade (id) | `RESTRICT` |

### cliente
Especialização de `pessoa`: quem contrata as obras. Pode ser pessoa física ou jurídica.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador do cliente. É o valor usado em `obra.cliente_id`. |
| pessoa_id | INT | Não | FK, UK | | Pessoa com os dados comuns deste cliente. |
| cpfCnpj | VARCHAR(14) | Não | UK | `CHECK`: só números, com 11 ou 14 dígitos | CPF (11 dígitos, pessoa física) ou CNPJ (14 dígitos, pessoa jurídica). O tipo de cliente é deduzido pelo tamanho (RN01). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| pessoa_id | pessoa (id) | `CASCADE` |

### engenheiro
Especialização de `pessoa`: engenheiros responsáveis pelas obras.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador do engenheiro. É o valor usado em `obra.engenheiro_id`. |
| pessoa_id | INT | Não | FK, UK | | Pessoa com os dados comuns deste engenheiro. |
| crea | VARCHAR(20) | Não | UK | | Número do registro no CREA (RN02). Ex.: `1019876543D-GO`. |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| pessoa_id | pessoa (id) | `CASCADE` |

---

## Cadastros de apoio

### concessionaria
Distribuidoras de energia que aprovam a conexão das usinas à rede.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador da concessionária. |
| nome | VARCHAR(100) | Não | | | Nome da distribuidora. |
| sigla | VARCHAR(20) | Não | UK | | Sigla pela qual a concessionária é conhecida. |
| uf | CHAR(2) | Não | | 2 letras maiúsculas | Estado onde a concessionária atua. |

### fabricante
Marcas dos equipamentos.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador do fabricante. |
| nome | VARCHAR(60) | Não | UK | | Nome da marca. |
| paisOrigem | VARCHAR(60) | Não | | | País de origem do fabricante. |

### equipamento
Catálogo de equipamentos que a empresa instala.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador do equipamento. |
| fabricante_id | INT | Não | FK | | Fabricante do equipamento. |
| tipo | VARCHAR(20) | Não | | `CHECK` em (`modulo`, `inversor`, `microinversor`, `estrutura`, `string_box`, `cabo`) | Categoria do equipamento. O cálculo do kWp usa apenas os do tipo `modulo`. |
| modelo | VARCHAR(100) | Não | | | Nome comercial do modelo. |
| potenciaW | INT | Sim | | `CHECK` > 0, quando preenchido | Potência em watts. Para módulos, é a potência de pico (Wp). Fica vazio em equipamentos sem potência, como estruturas e cabos. |
| precoAtual | DECIMAL(10,2) | Não | | `CHECK` > 0 | Preço de venda atual no catálogo, em reais. Serve de sugestão ao adicionar o equipamento a uma obra (RN07). |
| garantiaAnos | INT | Não | | `CHECK` ≥ 0 | Tempo de garantia do fabricante, em anos, contado a partir da conclusão da obra (RN10). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| fabricante_id | fabricante (id) | `RESTRICT` |

---

## Obras

### obra
Obras de instalação de usinas. O endereço é o local da instalação, que pode ser diferente do endereço do cliente.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador da obra. |
| cliente_id | INT | Não | FK | | Cliente que contratou a obra. |
| engenheiro_id | INT | Não | FK | | Engenheiro responsável. |
| concessionaria_id | INT | Não | FK | | Concessionária onde a usina será conectada. |
| cidade_id | INT | Não | FK | | Cidade do local da instalação. |
| numeroUc | VARCHAR(20) | Não | | | Número da unidade consumidora na concessionária. |
| logradouro | VARCHAR(100) | Não | | | Rua, avenida, rodovia etc. do local da instalação. |
| numero | VARCHAR(10) | Não | | | Número do endereço da instalação. |
| bairro | VARCHAR(60) | Não | | | Bairro ou região do local da instalação. |
| tipoLigacao | VARCHAR(10) | Não | | `CHECK` em (`monofasica`, `bifasica`, `trifasica`) | Tipo de ligação da unidade consumidora (RN04). |
| dataContrato | DATE | Não | | | Data de assinatura do contrato. |
| valorContrato | DECIMAL(12,2) | Não | | `CHECK` > 0 | Valor total do contrato, em reais (RN05). |
| dataProtocolo | DATE | Sim | | `CHECK` ≥ `dataContrato` | Data em que o pedido de homologação foi protocolado na concessionária. Vazio enquanto não for pedido. |
| dataAprovacao | DATE | Sim | | `CHECK` ≥ `dataProtocolo`; só pode ser preenchida junto com `dataProtocolo` | Data em que a concessionária aprovou a conexão. Vazio enquanto não for aprovada (RN06). |
| dataPrevista | DATE | Não | | `CHECK` ≥ `dataContrato` | Data prevista para concluir a instalação. Usada para identificar obras atrasadas (RN11). |
| dataConclusao | DATE | Sim | | `CHECK` ≥ `dataContrato` | Data em que a instalação foi concluída. Vazio enquanto a obra está em andamento. É o início da garantia dos equipamentos (RN10). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| cliente_id | cliente (id) | `RESTRICT` |
| engenheiro_id | engenheiro (id) | `RESTRICT` |
| concessionaria_id | concessionaria (id) | `RESTRICT` |
| cidade_id | cidade (id) | `RESTRICT` |

### obra_equipamento
Equipamentos usados em cada obra (relacionamento N:N entre `obra` e `equipamento`).

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| obra_id | INT | Não | PK, FK | | Obra onde o equipamento foi usado. |
| equipamento_id | INT | Não | PK, FK | | Equipamento usado. |
| quantidade | INT | Não | | `CHECK` > 0 | Quantidade instalada na obra (RN05). |
| valorUnitario | DECIMAL(10,2) | Não | | `CHECK` > 0 | Valor cobrado por unidade nesta obra. Não muda quando o preço do catálogo muda (RN07). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| obra_id | obra (id) | `CASCADE` |
| equipamento_id | equipamento (id) | `RESTRICT` |

---

## Informação calculada (não armazenada)

| Informação | Como é calculada | Regra |
|---|---|---|
| **Tipo de cliente (PF ou PJ)** | `cliente.cpfCnpj` com 11 dígitos é pessoa física; com 14, pessoa jurídica. | RN01 |
| **Potência da obra (kWp)** | Soma de `obra_equipamento.quantidade` × `equipamento.potenciaW` dos equipamentos do tipo `modulo` da obra, dividida por 1000. | RN08 |
| **Tempo de homologação (dias)** | Diferença em dias entre `obra.dataAprovacao` e `obra.dataProtocolo`. | RN09 |
| **Fim da garantia de um equipamento** | `obra.dataConclusao` somada a `equipamento.garantiaAnos`. | RN10 |
| **Obra atrasada** | `obra.dataPrevista` anterior à data atual e `obra.dataConclusao` vazia. | RN11 |

Esses valores não são guardados em colunas porque dependem de outras colunas: guardá-los criaria redundância e o risco de ficarem desatualizados.
