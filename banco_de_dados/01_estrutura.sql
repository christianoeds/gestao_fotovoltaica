-- =============================================================================
-- Gestão Fotovoltaica: estrutura do banco de dados (modelo físico)
-- =============================================================================
-- Ordem de execução:
--   1. 01_estrutura.sql   (este arquivo: cria o banco e as tabelas)
--   2. 02_povoamento.sql  (insere os dados de exemplo)
--
-- Banco: MariaDB 10.4 (XAMPP), motor InnoDB, codificação utf8mb4.
-- Referências: documentacao/modelo_logico.md e documentacao/dicionario_de_dados.md
--
-- ATENÇÃO: este script apaga o banco gestao_fotovoltaica, se ele existir,
-- e cria tudo do zero. Os dados de exemplo voltam com o 02_povoamento.sql.
--
-- Padrão de nomes:
--   tabelas em snake_case, colunas em camelCase, chaves estrangeiras tabela_id
--
-- Padrão de nomes das restrições:
--   pk_tabela               chave primária
--   uk_tabela_coluna        valor único
--   ck_tabela_regra         regra de domínio (CHECK)
--   fk_tabela_referenciada  chave estrangeira
-- =============================================================================

DROP DATABASE IF EXISTS gestao_fotovoltaica;

CREATE DATABASE gestao_fotovoltaica
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE gestao_fotovoltaica;


-- =============================================================================
-- CIDADES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- cidade: cidades das pessoas e das obras
-- -----------------------------------------------------------------------------
CREATE TABLE cidade (
    id    INT          NOT NULL AUTO_INCREMENT,
    nome  VARCHAR(60)  NOT NULL,
    uf    CHAR(2)      NOT NULL,

    CONSTRAINT pk_cidade PRIMARY KEY (id),
    -- pode haver cidades com o mesmo nome em estados diferentes (RN13)
    CONSTRAINT uk_cidade_nome_uf UNIQUE (nome, uf)
) ENGINE = InnoDB
  COMMENT = 'Cidades onde moram as pessoas e onde ficam as obras.';


-- =============================================================================
-- HIERARQUIA DE PESSOAS (herança: uma tabela para cada entidade)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- pessoa: dados comuns a clientes e engenheiros
-- (herança sobreposta: a mesma pessoa pode ser cliente e engenheiro)
-- -----------------------------------------------------------------------------
CREATE TABLE pessoa (
    id          INT           NOT NULL AUTO_INCREMENT,
    cidade_id   INT           NOT NULL,
    nome        VARCHAR(100)  NOT NULL,
    telefone    VARCHAR(11)   NOT NULL,
    email       VARCHAR(100)  NULL,
    logradouro  VARCHAR(100)  NOT NULL,
    numero      VARCHAR(10)   NOT NULL,
    bairro      VARCHAR(60)   NOT NULL,

    CONSTRAINT pk_pessoa PRIMARY KEY (id),
    CONSTRAINT fk_pessoa_cidade FOREIGN KEY (cidade_id)
        REFERENCES cidade (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Dados comuns a clientes e engenheiros. A mesma pessoa pode ter os dois papéis (RN12).';

-- -----------------------------------------------------------------------------
-- cliente: especialização de pessoa (quem contrata obras)
-- -----------------------------------------------------------------------------
CREATE TABLE cliente (
    id         INT          NOT NULL AUTO_INCREMENT,
    pessoa_id  INT          NOT NULL,
    cpfCnpj    VARCHAR(14)  NOT NULL,

    CONSTRAINT pk_cliente PRIMARY KEY (id),
    -- o UNIQUE em pessoa_id faz da herança um relacionamento 1:1
    CONSTRAINT uk_cliente_pessoa UNIQUE (pessoa_id),
    CONSTRAINT uk_cliente_cpf_cnpj UNIQUE (cpfCnpj),
    -- só números: 11 dígitos (CPF, pessoa física) ou 14 dígitos (CNPJ, pessoa jurídica)
    CONSTRAINT ck_cliente_cpf_cnpj CHECK (cpfCnpj REGEXP '^([0-9]{11}|[0-9]{14})$'),
    CONSTRAINT fk_cliente_pessoa FOREIGN KEY (pessoa_id)
        REFERENCES pessoa (id)
        ON DELETE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Especialização de pessoa: clientes (CPF ou CNPJ).';

-- -----------------------------------------------------------------------------
-- engenheiro: especialização de pessoa (responsável técnico)
-- -----------------------------------------------------------------------------
CREATE TABLE engenheiro (
    id         INT          NOT NULL AUTO_INCREMENT,
    pessoa_id  INT          NOT NULL,
    crea       VARCHAR(20)  NOT NULL,

    CONSTRAINT pk_engenheiro PRIMARY KEY (id),
    CONSTRAINT uk_engenheiro_pessoa UNIQUE (pessoa_id),
    CONSTRAINT uk_engenheiro_crea UNIQUE (crea),
    CONSTRAINT fk_engenheiro_pessoa FOREIGN KEY (pessoa_id)
        REFERENCES pessoa (id)
        ON DELETE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Especialização de pessoa: engenheiros responsáveis pelas obras.';


-- =============================================================================
-- CADASTROS DE APOIO
-- =============================================================================

-- -----------------------------------------------------------------------------
-- concessionaria: distribuidoras de energia
-- -----------------------------------------------------------------------------
CREATE TABLE concessionaria (
    id     INT           NOT NULL AUTO_INCREMENT,
    nome   VARCHAR(100)  NOT NULL,
    sigla  VARCHAR(20)   NOT NULL,
    uf     CHAR(2)       NOT NULL,

    CONSTRAINT pk_concessionaria PRIMARY KEY (id),
    CONSTRAINT uk_concessionaria_sigla UNIQUE (sigla)
) ENGINE = InnoDB
  COMMENT = 'Distribuidoras de energia que aprovam a conexão das usinas.';

-- -----------------------------------------------------------------------------
-- fabricante: marcas dos equipamentos
-- -----------------------------------------------------------------------------
CREATE TABLE fabricante (
    id          INT          NOT NULL AUTO_INCREMENT,
    nome        VARCHAR(60)  NOT NULL,
    paisOrigem  VARCHAR(60)  NOT NULL,

    CONSTRAINT pk_fabricante PRIMARY KEY (id),
    CONSTRAINT uk_fabricante_nome UNIQUE (nome)
) ENGINE = InnoDB
  COMMENT = 'Fabricantes dos equipamentos.';

-- -----------------------------------------------------------------------------
-- equipamento: catálogo de equipamentos
-- -----------------------------------------------------------------------------
CREATE TABLE equipamento (
    id             INT            NOT NULL AUTO_INCREMENT,
    fabricante_id  INT            NOT NULL,
    tipo           VARCHAR(20)    NOT NULL,
    modelo         VARCHAR(100)   NOT NULL,
    potenciaW      INT            NULL,
    precoAtual     DECIMAL(10,2)  NOT NULL,
    garantiaAnos   INT            NOT NULL,

    CONSTRAINT pk_equipamento PRIMARY KEY (id),
    CONSTRAINT ck_equipamento_tipo
        CHECK (tipo IN ('modulo', 'inversor', 'microinversor', 'estrutura', 'string_box', 'cabo')),
    -- potenciaW aceita NULL: o CHECK só recusa resultado FALSO, e NULL > 0 resulta em "desconhecido"
    CONSTRAINT ck_equipamento_potencia CHECK (potenciaW > 0),
    CONSTRAINT ck_equipamento_preco    CHECK (precoAtual > 0),
    CONSTRAINT ck_equipamento_garantia CHECK (garantiaAnos >= 0),
    CONSTRAINT fk_equipamento_fabricante FOREIGN KEY (fabricante_id)
        REFERENCES fabricante (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Catálogo de equipamentos (módulos, inversores, estruturas etc.).';


-- =============================================================================
-- OBRAS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- obra: instalação de uma usina fotovoltaica
-- -----------------------------------------------------------------------------
CREATE TABLE obra (
    id                 INT            NOT NULL AUTO_INCREMENT,
    cliente_id         INT            NOT NULL,
    engenheiro_id      INT            NOT NULL,
    concessionaria_id  INT            NOT NULL,
    cidade_id          INT            NOT NULL,
    numeroUc           VARCHAR(20)    NOT NULL,
    logradouro         VARCHAR(100)   NOT NULL,
    numero             VARCHAR(10)    NOT NULL,
    bairro             VARCHAR(60)    NOT NULL,
    tipoLigacao        VARCHAR(10)    NOT NULL,
    dataContrato       DATE           NOT NULL,
    valorContrato      DECIMAL(12,2)  NOT NULL,
    dataProtocolo      DATE           NULL,
    dataAprovacao      DATE           NULL,
    dataPrevista       DATE           NOT NULL,
    dataConclusao      DATE           NULL,

    CONSTRAINT pk_obra PRIMARY KEY (id),
    CONSTRAINT ck_obra_tipo_ligacao
        CHECK (tipoLigacao IN ('monofasica', 'bifasica', 'trifasica')),
    CONSTRAINT ck_obra_valor CHECK (valorContrato > 0),
    -- nenhuma data do andamento pode ser anterior ao contrato (RN06)
    -- (datas vazias passam, porque NULL na comparação resulta em "desconhecido")
    CONSTRAINT ck_obra_protocolo CHECK (dataProtocolo >= dataContrato),
    CONSTRAINT ck_obra_prevista  CHECK (dataPrevista  >= dataContrato),
    CONSTRAINT ck_obra_conclusao CHECK (dataConclusao >= dataContrato),
    -- a aprovação não pode ser anterior ao protocolo...
    CONSTRAINT ck_obra_aprovacao CHECK (dataAprovacao >= dataProtocolo),
    -- ...e só pode existir se o protocolo também existir
    CONSTRAINT ck_obra_aprovacao_protocolo
        CHECK (dataAprovacao IS NULL OR dataProtocolo IS NOT NULL),
    CONSTRAINT fk_obra_cliente FOREIGN KEY (cliente_id)
        REFERENCES cliente (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_obra_engenheiro FOREIGN KEY (engenheiro_id)
        REFERENCES engenheiro (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_obra_concessionaria FOREIGN KEY (concessionaria_id)
        REFERENCES concessionaria (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_obra_cidade FOREIGN KEY (cidade_id)
        REFERENCES cidade (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Obras de instalação. O endereço é o local da instalação.';

-- -----------------------------------------------------------------------------
-- obra_equipamento: equipamentos utilizados em cada obra (N:N)
-- -----------------------------------------------------------------------------
CREATE TABLE obra_equipamento (
    obra_id         INT            NOT NULL,
    equipamento_id  INT            NOT NULL,
    quantidade      INT            NOT NULL,
    valorUnitario   DECIMAL(10,2)  NOT NULL,

    -- a chave composta impede registrar o mesmo equipamento duas vezes na mesma obra
    CONSTRAINT pk_obra_equipamento PRIMARY KEY (obra_id, equipamento_id),
    CONSTRAINT ck_obra_equipamento_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_obra_equipamento_valor      CHECK (valorUnitario > 0),
    -- excluir a obra exclui os equipamentos registrados nela (RN03)
    CONSTRAINT fk_obra_equipamento_obra FOREIGN KEY (obra_id)
        REFERENCES obra (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_obra_equipamento_equipamento FOREIGN KEY (equipamento_id)
        REFERENCES equipamento (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Equipamentos usados em cada obra, com o valor cobrado na obra (RN07).';
