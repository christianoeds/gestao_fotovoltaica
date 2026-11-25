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
-- HIERARQUIA DE PESSOAS (herança: uma tabela para cada entidade)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- pessoa: dados comuns a clientes, engenheiros e colaboradores
-- -----------------------------------------------------------------------------
CREATE TABLE pessoa (
    id          INT           NOT NULL AUTO_INCREMENT,
    categoria   VARCHAR(12)   NOT NULL,
    nome        VARCHAR(100)  NOT NULL,
    telefone    VARCHAR(20)   NOT NULL,
    email       VARCHAR(100)  NULL,
    logradouro  VARCHAR(100)  NOT NULL,
    numero      VARCHAR(10)   NOT NULL,
    bairro      VARCHAR(60)   NOT NULL,
    cidade      VARCHAR(60)   NOT NULL,
    uf          CHAR(2)       NOT NULL,

    CONSTRAINT pk_pessoa PRIMARY KEY (id),
    CONSTRAINT ck_pessoa_categoria
        CHECK (categoria IN ('cliente', 'engenheiro', 'colaborador'))
) ENGINE = InnoDB
  COMMENT = 'Dados comuns a todas as pessoas do sistema (RN16).';

-- -----------------------------------------------------------------------------
-- cliente: especialização de pessoa (quem contrata obras)
-- -----------------------------------------------------------------------------
CREATE TABLE cliente (
    id        INT          NOT NULL,
    cpf_cnpj  VARCHAR(14)  NOT NULL,

    CONSTRAINT pk_cliente PRIMARY KEY (id),
    CONSTRAINT uk_cliente_cpf_cnpj UNIQUE (cpf_cnpj),
    -- só números: 11 dígitos (CPF, pessoa física) ou 14 dígitos (CNPJ, pessoa jurídica)
    CONSTRAINT ck_cliente_cpf_cnpj CHECK (cpf_cnpj REGEXP '^([0-9]{11}|[0-9]{14})$'),
    CONSTRAINT fk_cliente_pessoa FOREIGN KEY (id)
        REFERENCES pessoa (id)
        ON DELETE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Especialização de pessoa: clientes (CPF ou CNPJ).';

-- -----------------------------------------------------------------------------
-- engenheiro: especialização de pessoa (responsável técnico)
-- -----------------------------------------------------------------------------
CREATE TABLE engenheiro (
    id    INT          NOT NULL,
    crea  VARCHAR(20)  NOT NULL,

    CONSTRAINT pk_engenheiro PRIMARY KEY (id),
    CONSTRAINT uk_engenheiro_crea UNIQUE (crea),
    CONSTRAINT fk_engenheiro_pessoa FOREIGN KEY (id)
        REFERENCES pessoa (id)
        ON DELETE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Especialização de pessoa: engenheiros responsáveis pelas obras.';


-- =============================================================================
-- EQUIPES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- equipe: equipes de instalação
-- -----------------------------------------------------------------------------
CREATE TABLE equipe (
    id    INT          NOT NULL AUTO_INCREMENT,
    nome  VARCHAR(50)  NOT NULL,

    CONSTRAINT pk_equipe PRIMARY KEY (id),
    CONSTRAINT uk_equipe_nome UNIQUE (nome)
) ENGINE = InnoDB
  COMMENT = 'Equipes de instalação (mínimo de 1 instalador e 1 ajudante, RN12).';

-- -----------------------------------------------------------------------------
-- colaborador: especialização de pessoa (membro de uma equipe)
-- -----------------------------------------------------------------------------
CREATE TABLE colaborador (
    id         INT          NOT NULL,
    equipe_id  INT          NOT NULL,
    cpf        CHAR(11)     NOT NULL,
    funcao     VARCHAR(10)  NOT NULL,

    CONSTRAINT pk_colaborador PRIMARY KEY (id),
    CONSTRAINT uk_colaborador_cpf UNIQUE (cpf),
    CONSTRAINT ck_colaborador_funcao CHECK (funcao IN ('instalador', 'ajudante')),
    CONSTRAINT fk_colaborador_pessoa FOREIGN KEY (id)
        REFERENCES pessoa (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_colaborador_equipe FOREIGN KEY (equipe_id)
        REFERENCES equipe (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Especialização de pessoa: membros das equipes de instalação.';


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
    id           INT          NOT NULL AUTO_INCREMENT,
    nome         VARCHAR(60)  NOT NULL,
    pais_origem  VARCHAR(60)  NOT NULL,

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
    potencia_w     INT            NULL,
    preco_atual    DECIMAL(10,2)  NOT NULL,
    garantia_anos  INT            NOT NULL,

    CONSTRAINT pk_equipamento PRIMARY KEY (id),
    CONSTRAINT ck_equipamento_tipo
        CHECK (tipo IN ('modulo', 'inversor', 'microinversor', 'estrutura', 'string_box', 'cabo')),
    -- potencia_w aceita NULL: o CHECK só recusa resultado FALSO, e NULL > 0 resulta em "desconhecido"
    CONSTRAINT ck_equipamento_potencia CHECK (potencia_w > 0),
    CONSTRAINT ck_equipamento_preco    CHECK (preco_atual > 0),
    CONSTRAINT ck_equipamento_garantia CHECK (garantia_anos >= 0),
    CONSTRAINT fk_equipamento_fabricante FOREIGN KEY (fabricante_id)
        REFERENCES fabricante (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Catálogo de equipamentos (módulos, inversores, estruturas etc.).';

-- -----------------------------------------------------------------------------
-- etapa: etapas padrão de toda obra
-- -----------------------------------------------------------------------------
CREATE TABLE etapa (
    id     INT          NOT NULL AUTO_INCREMENT,
    nome   VARCHAR(50)  NOT NULL,
    ordem  INT          NOT NULL,

    CONSTRAINT pk_etapa PRIMARY KEY (id),
    CONSTRAINT uk_etapa_nome  UNIQUE (nome),
    CONSTRAINT uk_etapa_ordem UNIQUE (ordem),
    CONSTRAINT ck_etapa_ordem CHECK (ordem > 0)
) ENGINE = InnoDB
  COMMENT = 'Etapas padrão pelas quais toda obra passa, em ordem.';


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
    numero_uc          VARCHAR(20)    NOT NULL,
    logradouro         VARCHAR(100)   NOT NULL,
    numero             VARCHAR(10)    NOT NULL,
    bairro             VARCHAR(60)    NOT NULL,
    cidade             VARCHAR(60)    NOT NULL,
    uf                 CHAR(2)        NOT NULL,
    tipo_ligacao       VARCHAR(10)    NOT NULL,
    data_contrato      DATE           NOT NULL,
    valor_contrato     DECIMAL(12,2)  NOT NULL,

    CONSTRAINT pk_obra PRIMARY KEY (id),
    CONSTRAINT ck_obra_tipo_ligacao
        CHECK (tipo_ligacao IN ('monofasica', 'bifasica', 'trifasica')),
    CONSTRAINT ck_obra_valor CHECK (valor_contrato > 0),
    CONSTRAINT fk_obra_cliente FOREIGN KEY (cliente_id)
        REFERENCES cliente (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_obra_engenheiro FOREIGN KEY (engenheiro_id)
        REFERENCES engenheiro (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_obra_concessionaria FOREIGN KEY (concessionaria_id)
        REFERENCES concessionaria (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Obras de instalação. O endereço é o local da instalação.';

-- -----------------------------------------------------------------------------
-- obra_equipe: equipes alocadas em cada obra (N:N)
-- -----------------------------------------------------------------------------
CREATE TABLE obra_equipe (
    obra_id    INT  NOT NULL,
    equipe_id  INT  NOT NULL,

    -- a chave composta impede alocar a mesma equipe duas vezes na mesma obra (RN15)
    CONSTRAINT pk_obra_equipe PRIMARY KEY (obra_id, equipe_id),
    CONSTRAINT fk_obra_equipe_obra FOREIGN KEY (obra_id)
        REFERENCES obra (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_obra_equipe_equipe FOREIGN KEY (equipe_id)
        REFERENCES equipe (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Equipes de instalação alocadas em cada obra.';

-- -----------------------------------------------------------------------------
-- obra_equipamento: equipamentos utilizados em cada obra (N:N)
-- -----------------------------------------------------------------------------
CREATE TABLE obra_equipamento (
    obra_id         INT            NOT NULL,
    equipamento_id  INT            NOT NULL,
    quantidade      INT            NOT NULL,
    valor_unitario  DECIMAL(10,2)  NOT NULL,

    CONSTRAINT pk_obra_equipamento PRIMARY KEY (obra_id, equipamento_id),
    CONSTRAINT ck_obra_equipamento_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_obra_equipamento_valor      CHECK (valor_unitario > 0),
    CONSTRAINT fk_obra_equipamento_obra FOREIGN KEY (obra_id)
        REFERENCES obra (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_obra_equipamento_equipamento FOREIGN KEY (equipamento_id)
        REFERENCES equipamento (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Equipamentos usados em cada obra, com o valor cobrado na obra (RN07).';

-- -----------------------------------------------------------------------------
-- obra_etapa: andamento de cada etapa em cada obra (N:N)
-- -----------------------------------------------------------------------------
CREATE TABLE obra_etapa (
    obra_id         INT   NOT NULL,
    etapa_id        INT   NOT NULL,
    data_prevista   DATE  NOT NULL,
    data_inicio     DATE  NULL,
    data_conclusao  DATE  NULL,

    CONSTRAINT pk_obra_etapa PRIMARY KEY (obra_id, etapa_id),
    -- a conclusão não pode ser anterior ao início (RN06)
    CONSTRAINT ck_obra_etapa_datas CHECK (data_conclusao >= data_inicio),
    -- a etapa só pode ser concluída se tiver começado
    CONSTRAINT ck_obra_etapa_inicio CHECK (data_conclusao IS NULL OR data_inicio IS NOT NULL),
    CONSTRAINT fk_obra_etapa_obra FOREIGN KEY (obra_id)
        REFERENCES obra (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_obra_etapa_etapa FOREIGN KEY (etapa_id)
        REFERENCES etapa (id)
        ON DELETE RESTRICT
) ENGINE = InnoDB
  COMMENT = 'Andamento das etapas de cada obra (datas prevista, de início e de conclusão).';
