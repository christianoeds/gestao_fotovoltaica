-- =============================================================================
-- Gestão Fotovoltaica: povoamento do banco de dados (dados de exemplo)
-- =============================================================================
-- Execute DEPOIS do 01_estrutura.sql.
--
-- Todos os nomes, documentos, telefones e endereços são fictícios.
-- Os CPFs e CNPJs têm dígitos verificadores válidos, mas não pertencem a ninguém.
--
-- Os ids são informados explicitamente para deixar claras as ligações entre
-- as tabelas (ex.: obra.cliente_id = 3 é o cliente de id 3).
--
-- Os dados foram pensados para que todas as consultas do 03_consultas.sql
-- tenham resultado. Data de referência usada no planejamento: 25/11/2026.
--   - obras de 2022 a 2026, com valores cobrados diferentes do preço atual
--     do catálogo (RN07);
--   - obras concluídas, em andamento e atrasadas (RN11);
--   - garantias que vencem nos próximos meses (RN10);
--   - tempos de homologação diferentes por concessionária (RN09);
--   - equipamentos e concessionárias que nunca foram usados em obras;
--   - uma pessoa que é engenheiro e cliente ao mesmo tempo (herança sobreposta, RN12).
-- =============================================================================

USE gestao_fotovoltaica;


-- -----------------------------------------------------------------------------
-- cidade (15)
-- -----------------------------------------------------------------------------
INSERT INTO cidade (id, nome, uf) VALUES
    (1,  'Formiga',              'MG'),
    (2,  'Arcos',                'MG'),
    (3,  'Córrego Fundo',        'MG'),
    (4,  'Itapecerica',          'MG'),
    (5,  'Cláudio',              'MG'),
    (6,  'Carmo da Mata',        'MG'),
    (7,  'Goiania',              'GO'),
    (8,  'Anápolis',             'GO'),
    (9,  'Caldas Novas',         'GO'),
    (10, 'Brasília',             'DF'),
    (11, 'São Paulo',            'SP'),
    (12, 'Ribeirão Preto',       'SP'),
    (13, 'Campinas',             'SP'),
    (14, 'São Bernardo do Campo','SP'),
    (15, 'Santo André',          'SP');

-- -----------------------------------------------------------------------------
-- pessoa (19)
--   1 a 10  → engenheiros
--   10      → também é cliente (herança sobreposta)
--   11 a 19 → clientes
-- -----------------------------------------------------------------------------
INSERT INTO pessoa (id, cidade_id, nome, telefone, email, logradouro, numero, bairro) VALUES
    -- engenheiros
    (1,  1,  'Ana Paula Ribeiro',              '37991234501', 'ana.ribeiro@derivar.example',       'Rua Barão de Piumhi',          '1120', 'Centro'),
    (2,  1,  'Bruno Henrique Castro',          '37991234502', 'bruno.castro@derivar.example',      'Avenida Getúlio Vargas',       '455',  'Centro'),
    (3,  10, 'Carla Mendes Furtado',           '61991234503', 'carla.furtado@derivar.example',     'SQS 308 Bloco C',              '204',  'Asa Sul'),
    (4,  2,  'Diego Martins Rocha',            '37991234504', 'diego.rocha@derivar.example',       'Rua Governador Valadares',     '780',  'Centro'),
    (5,  7,  'Eduarda Lima Prado',             '62991234505', 'eduarda.prado@derivar.example',     'Rua T-30',                     '310',  'Setor Bueno'),
    (6,  13, 'Felipe Augusto Nogueira',        '19991234506', 'felipe.nogueira@derivar.example',   'Rua Barão de Jaguara',         '1500', 'Centro'),
    (7,  4,  'Gabriela Souza Teixeira',        '37991234507', 'gabriela.teixeira@derivar.example', 'Rua Vigário Antunes',          '220',  'Centro'),
    (8,  11, 'Henrique Vieira Barbosa',        '11991234508', 'henrique.barbosa@derivar.example',  'Rua Vergueiro',                '900',  'Vila Mariana'),
    (9,  5,  'Isabela Cardoso Moura',          '37991234509', 'isabela.moura@derivar.example',     'Rua Coronel Lima',             '12',   'Centro'),
    (10, 1,  'João Pedro Almeida',             '37991234510', 'joao.almeida@derivar.example',      'Rua Doutor Teixeira Soares',   '58',   'Água Vermelha'),
    -- clientes
    (11, 1,  'Marcos Antônio Pereira',         '37981110011', 'marcos.pereira@email.example',      'Rua Silviano Brandão',         '340',  'Centro'),
    (12, 2,  'Supermercado Bom Preço',         '37981110012', 'financeiro@bompreco.example',       'Avenida Magalhães Pinto',      '3100', 'Centro'),
    (13, 10, 'Luciana Ferreira Gomes',         '61981110013', NULL,                                'SHIN QI 9 Conjunto 4',         '15',   'Lago Norte'),
    (14, 3,  'Laticínios Vale Verde',          '37981110014', 'compras@valeverde.example',         'Rodovia MG-050, km 197',       'S/N',  'Zona Rural'),
    (15, 7,  'Roberto Carlos Nunes',           '62981110015', 'roberto.nunes@email.example',       'Rua C-149',                    '77',   'Jardim América'),
    (16, 6,  'Patrícia Oliveira Santos',       '37981110016', NULL,                                'Rua Sete de Setembro',         '1245', 'Centro'),
    (17, 12, 'Clínica Sorriso Pleno',          '16981110017', 'contato@sorrisopleno.example',      'Avenida Presidente Vargas',    '2000', 'Jardim Sumaré'),
    (18, 14, 'Fernando José Arruda',           '11981110018', 'fernando.arruda@email.example',     'Rua Marechal Deodoro',         '2050', 'Centro'),
    (19, 9,  'Hotel Águas Termais do Cerrado', '64981110019', 'reservas@aguastermais.example',     'Avenida Orcalino Santos',      '1601', 'Centro');


-- -----------------------------------------------------------------------------
-- engenheiro (10)
-- -----------------------------------------------------------------------------
INSERT INTO engenheiro (id, pessoa_id, crea) VALUES
    (1,  1,  '0412345601D-MG'),
    (2,  2,  '0412345602D-MG'),
    (3,  3,  '0712345603D-DF'),
    (4,  4,  '0412345604D-MG'),
    (5,  5,  '1012345605D-GO'),
    (6,  6,  '2612345606D-SP'),
    (7,  7,  '0412345607D-MG'),
    (8,  8,  '2612345608D-SP'),
    (9,  9,  '0412345609D-MG'),
    (10, 10, '0412345610D-MG');


-- -----------------------------------------------------------------------------
-- cliente (10): 6 pessoas físicas (CPF) e 4 jurídicas (CNPJ)
--   o cliente 10 é a pessoa 10, que também é o engenheiro 10
-- -----------------------------------------------------------------------------
INSERT INTO cliente (id, pessoa_id, cpfCnpj) VALUES
    (1,  11, '10433218100'),      -- PF
    (2,  12, '31034131000113'),   -- PJ
    (3,  13, '96001338914'),      -- PF
    (4,  14, '64752553000183'),   -- PJ
    (5,  15, '08386379499'),      -- PF
    (6,  16, '02654235114'),      -- PF
    (7,  17, '41928327000105'),   -- PJ
    (8,  18, '16155940789'),      -- PF
    (9,  19, '64835030000109'),   -- PJ
    (10, 10, '81618495950');      -- PF (engenheiro que instalou uma usina em casa)


-- -----------------------------------------------------------------------------
-- concessionaria (10): as 5 últimas não têm obras (não atendem as cidades cadastradas)
-- -----------------------------------------------------------------------------
INSERT INTO concessionaria (id, nome, sigla, uf) VALUES
    (1,  'Cemig Distribuição',             'CEMIG-D',       'MG'),
    (2,  'Equatorial Goiás',               'EQUATORIAL-GO', 'GO'),
    (3,  'Neoenergia Brasília',            'NEOENERGIA-DF', 'DF'),
    (4,  'Enel Distribuição São Paulo',    'ENEL-SP',       'SP'),
    (5,  'CPFL Paulista',                  'CPFL-PAULISTA', 'SP'),
    (6,  'Energisa Mato Grosso',           'ENERGISA-MT',   'MT'),
    (7,  'Energisa Tocantins',             'ENERGISA-TO',   'TO'),
    (8,  'Copel Distribuição',             'COPEL-DIS',     'PR'),
    (9,  'Celesc Distribuição',            'CELESC-DIS',    'SC'),
    (10, 'Light Serviços de Eletricidade', 'LIGHT',         'RJ');


-- -----------------------------------------------------------------------------
-- fabricante (10)
-- -----------------------------------------------------------------------------
INSERT INTO fabricante (id, nome, paisOrigem) VALUES
    (1,  'Canadian Solar', 'Canadá'),
    (2,  'Jinko Solar',    'China'),
    (3,  'Trina Solar',    'China'),
    (4,  'Growatt',        'China'),
    (5,  'Fronius',        'Áustria'),
    (6,  'SMA',            'Alemanha'),
    (7,  'Hoymiles',       'China'),
    (8,  'WEG',            'Brasil'),
    (9,  'Romagnole',      'Brasil'),
    (10, 'Clamper',        'Brasil');


-- -----------------------------------------------------------------------------
-- equipamento (15)
--   nunca usados em obras: 5 (módulo Trina 710 W), 12 (inversor WEG)
--   e 14 (estrutura de solo)
--   a string box (15) tem só 2 anos de garantia
-- -----------------------------------------------------------------------------
INSERT INTO equipamento (id, fabricante_id, tipo, modelo, potenciaW, precoAtual, garantiaAnos) VALUES
    -- módulos
    (1,  1,  'modulo',        'HiKu6 CS6W-550MS',                         550,   850.00, 12),
    (2,  1,  'modulo',        'HiKu7 CS7N-665MS',                         665,   980.00, 12),
    (3,  2,  'modulo',        'Tiger Neo JKM580N-72HL4-V',                580,   820.00, 12),
    (4,  3,  'modulo',        'Vertex S+ TSM-445NEG9R.28',                445,   690.00, 15),
    (5,  3,  'modulo',        'Vertex N TSM-710NEG21C.20',                710,  1150.00, 15),
    -- inversores e microinversores
    (6,  4,  'inversor',      'MIN 5000TL-X',                            5000,  4200.00, 10),
    (7,  4,  'inversor',      'MID 25KTL3-X',                           25000, 14500.00, 10),
    (8,  5,  'inversor',      'Primo 8.2-1',                             8200,  9800.00,  7),
    (9,  6,  'inversor',      'Sunny Boy 5.0',                           5000,  7900.00,  5),
    (10, 6,  'inversor',      'Sunny Tripower 15000TL',                 15000, 16500.00,  5),
    (11, 7,  'microinversor', 'HMS-2000-4T',                             2000,  2900.00, 12),
    (12, 8,  'inversor',      'SIW200G M050',                            5000,  3900.00,  5),
    -- estruturas e proteção (sem potência)
    (13, 9,  'estrutura',     'Kit telhado cerâmico para 4 módulos',     NULL,   520.00, 12),
    (14, 9,  'estrutura',     'Kit solo para 4 módulos',                 NULL,  1450.00, 12),
    (15, 10, 'string_box',    'String Box 1000 V 2 entradas / 2 saídas', NULL,   690.00,  2);


-- -----------------------------------------------------------------------------
-- obra (14)
--   concluídas: 1 a 10
--   em andamento e ATRASADAS (dataPrevista já passou): 11 e 12
--   em andamento, dentro do prazo: 13 e 14
--   a obra 12 ainda aguarda a aprovação da concessionária
--   a obra 14 acabou de ser contratada (sem protocolo e sem equipamentos)
-- -----------------------------------------------------------------------------
INSERT INTO obra (id, cliente_id, engenheiro_id, concessionaria_id, cidade_id,
                  numeroUc, logradouro, numero, bairro, tipoLigacao,
                  dataContrato, valorContrato,
                  dataProtocolo, dataAprovacao, dataPrevista, dataConclusao) VALUES
    (1,  1,  1,  1, 1,  '3004561201', 'Rua Silviano Brandão',               '340',  'Centro',             'bifasica',
         '2022-01-10',  35600.00, '2022-01-20', '2022-02-28', '2022-03-31', '2022-03-18'),
    (2,  2,  2,  1, 2,  '3004561202', 'Avenida Magalhães Pinto',            '3100', 'Centro',             'trifasica',
         '2022-06-15', 109500.00, '2022-07-01', '2022-08-10', '2022-09-15', '2022-09-05'),
    (3,  3,  3,  3, 10, '2008765431', 'SHIN QI 9 Conjunto 4',               '15',   'Lago Norte',         'bifasica',
         '2023-03-01',  40800.00, '2023-03-15', '2023-05-20', '2023-06-30', '2023-06-12'),
    (4,  4,  4,  1, 3,  '3004561204', 'Rodovia MG-050, km 197',             'S/N',  'Zona Rural',         'trifasica',
         '2023-08-10', 159300.00, '2023-08-20', '2023-09-08', '2023-11-30', '2023-11-10'),
    (5,  5,  5,  2, 7,  '1002345675', 'Rua C-149',                          '77',   'Jardim América',     'monofasica',
         '2024-02-05',  21900.00, '2024-02-15', '2024-03-22', '2024-04-30', '2024-04-18'),
    (6,  6,  9,  1, 6,  '3004561206', 'Fazenda Boa Esperança, estrada para Oliveira', 'S/N', 'Zona Rural', 'bifasica',
         '2024-09-02',  28400.00, '2024-09-12', '2024-10-30', '2024-12-15', '2024-12-20'),
    (7,  7,  6,  5, 12, '4005566778', 'Avenida Presidente Vargas',          '2000', 'Jardim Sumaré',      'trifasica',
         '2025-01-15',  59100.00, '2025-01-25', '2025-02-12', '2025-03-31', '2025-03-20'),
    (8,  10, 7,  1, 1,  '3004561208', 'Rua Doutor Teixeira Soares',         '58',   'Água Vermelha',      'bifasica',
         '2025-05-05',  22300.00, '2025-05-15', '2025-06-20', '2025-07-31', '2025-07-25'),
    (9,  8,  8,  4, 14, '5009988776', 'Rua Marechal Deodoro',               '2050', 'Centro',             'bifasica',
         '2025-09-10',  34800.00, '2025-09-22', '2025-10-20', '2025-12-15', '2025-12-05'),
    (10, 9,  5,  2, 9,  '1002345680', 'Avenida Orcalino Santos',            '1601', 'Centro',             'trifasica',
         '2026-02-10', 115300.00, '2026-02-20', '2026-03-30', '2026-05-31', '2026-05-28'),
    (11, 1,  10, 1, 1,  '3004561211', 'Avenida Antônio Olímpio de Morais',  '1550', 'Centro',             'trifasica',
         '2026-06-01',  34500.00, '2026-06-10', '2026-07-28', '2026-09-30', NULL),
    (12, 4,  4,  2, 8,  '1002345682', 'Via Primária 2, Quadra 5 (DAIA)',     'S/N',  'Distrito Agroindustrial', 'trifasica',
         '2026-07-15',  77000.00, '2026-07-25', NULL,         '2026-10-31', NULL),
    (13, 3,  3,  3, 10, '2008765499', 'SHIS QL 14 Conjunto 2',              '8',    'Lago Sul',           'bifasica',
         '2026-09-01',  20700.00, '2026-09-15', '2026-11-10', '2026-12-20', NULL),
    (14, 5,  8,  4, 15, '5009988794', 'Rua das Figueiras',                  '410',  'Jardim',             'monofasica',
         '2026-10-20',  18500.00, NULL,         NULL,         '2027-01-31', NULL);


-- -----------------------------------------------------------------------------
-- obra_equipamento (51)
--   valorUnitario = valor cobrado na época da obra. Nas obras antigas ele é
--   diferente do precoAtual do catálogo, que caiu com o tempo (RN07).
-- -----------------------------------------------------------------------------
INSERT INTO obra_equipamento (obra_id, equipamento_id, quantidade, valorUnitario) VALUES
    -- obra 1: 5,50 kWp (2022)
    (1,  1,  10,  1250.00),
    (1,  9,   1,  9500.00),
    (1,  13,  3,   600.00),
    (1,  15,  1,   750.00),
    -- obra 2: 22,00 kWp (2022)
    (2,  1,  40,  1250.00),
    (2,  7,   1, 18000.00),
    (2,  13, 10,   600.00),
    (2,  15,  2,   750.00),
    -- obra 3: 8,12 kWp (2023)
    (3,  3,  14,  1050.00),
    (3,  8,   1, 10500.00),
    (3,  13,  4,   560.00),
    (3,  15,  1,   720.00),
    -- obra 4: 34,80 kWp (2023)
    (4,  3,  60,  1050.00),
    (4,  10,  2, 18500.00),
    (4,  13, 15,   560.00),
    (4,  15,  2,   720.00),
    -- obra 5: 5,32 kWp (2024)
    (5,  2,   8,  1100.00),
    (5,  6,   1,  4500.00),
    (5,  13,  2,   540.00),
    (5,  15,  1,   700.00),
    -- obra 6: 5,34 kWp com microinversores (2024)
    (6,  4,  12,   720.00),
    (6,  11,  3,  3100.00),
    (6,  13,  3,   540.00),
    -- obra 7: 13,30 kWp (2025)
    (7,  2,  20,  1020.00),
    (7,  10,  1, 17000.00),
    (7,  13,  5,   530.00),
    (7,  15,  1,   690.00),
    -- obra 8: 5,80 kWp (2025)
    (8,  3,  10,   880.00),
    (8,  6,   1,  4300.00),
    (8,  13,  3,   530.00),
    (8,  15,  1,   690.00),
    -- obra 9: 7,12 kWp (2025)
    (9,  4,  16,   700.00),
    (9,  8,   1, 10000.00),
    (9,  13,  4,   530.00),
    (9,  15,  1,   690.00),
    -- obra 10: 33,25 kWp (2026)
    (10, 2,  50,   980.00),
    (10, 7,   1, 14500.00),
    (10, 9,   1,  7900.00),
    (10, 13, 13,   520.00),
    (10, 15,  2,   690.00),
    -- obra 11: 7,98 kWp (2026, atrasada)
    (11, 2,  12,   980.00),
    (11, 8,   1,  9800.00),
    (11, 13,  3,   520.00),
    (11, 15,  1,   690.00),
    -- obra 12: 23,20 kWp (2026, atrasada, com desconto nos módulos)
    (12, 3,  40,   800.00),
    (12, 7,   1, 14500.00),
    (12, 13, 10,   520.00),
    (12, 15,  2,   690.00),
    -- obra 13: 4,45 kWp com microinversores (2026, em andamento)
    (13, 4,  10,   690.00),
    (13, 11,  2,  2900.00),
    (13, 13,  3,   520.00);
    -- obra 14: ainda sem equipamentos (projeto em elaboração)

