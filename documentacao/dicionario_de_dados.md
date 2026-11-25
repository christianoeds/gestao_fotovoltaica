# Dicionário de Dados: Gestão Fotovoltaica

Este documento descreve cada tabela e cada coluna do banco `gestao_fotovoltaica`, com tipo, obrigatoriedade, chaves, restrições e significado. Ele segue o [modelo lógico](modelo_logico.md).

## Convenções

| Item | Convenção |
|---|---|
| **Banco** | MariaDB 10.4, motor **InnoDB** (necessário para chaves estrangeiras e transações), codificação `utf8mb4` com ordenação `utf8mb4_unicode_ci`. |
| **Nomes** | Tabelas e colunas em português, minúsculas, sem acentos, com palavras separadas por `_` (*snake_case*). Nomes de tabela no singular. |
| **Chaves primárias** | Sempre `id`, tipo `INT`, com `AUTO_INCREMENT`. Nas especializações (`cliente`, `cliente_pf`, `cliente_pj`, `engenheiro`, `colaborador`), o `id` é também chave estrangeira para a tabela mãe e **não** tem `AUTO_INCREMENT`: recebe o mesmo valor do `id` de `pessoa`. |
| **Chaves estrangeiras** | Nome da tabela referenciada + `_id`. Ex.: `obra.cliente_id` aponta para `cliente.id`. |
| **Tabelas associativas** | Não têm coluna `id`. A chave primária é composta pelas duas chaves estrangeiras. Ex.: (`obra_id`, `equipe_id`). |
| **Valores em dinheiro** | `DECIMAL`, e **nunca** `FLOAT` ou `DOUBLE`. `FLOAT` guarda valores aproximados (por exemplo, 0,1 + 0,2 pode resultar em 0,30000000000000004), o que causa erros de centavos em somas. `DECIMAL` guarda o valor exato. |
| **Datas** | `DATE` (só a data, sem hora), no formato `AAAA-MM-DD`. |
| **CPF, CNPJ e telefone** | Gravados **só com números**, sem pontos, traços, barras ou parênteses. A formatação é feita nas telas. O telefone inclui o DDD. |
| **UF** | Sigla do estado com 2 letras maiúsculas, por exemplo `GO`, `SP`. |
| **Valores de domínio** | Gravados em minúsculas e sem acentos (`monofasica`, `modulo`, `pf`), e garantidos com `CHECK`. As telas exibem os nomes formatados. |

**Legenda das colunas abaixo:** *PK* = chave primária, *FK* = chave estrangeira, *UK* = valor único. "Nulo: Não" significa que o preenchimento é obrigatório (`NOT NULL`).

---

## Hierarquia de pessoas

### pessoa
Dados comuns a todas as pessoas do sistema: clientes, engenheiros e colaboradores. Toda linha desta tabela tem exatamente uma linha correspondente em `cliente`, `engenheiro` ou `colaborador` (RN16).

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador da pessoa. |
| categoria | VARCHAR(12) | Não | | `CHECK` em (`cliente`, `engenheiro`, `colaborador`) | Papel da pessoa no sistema. Indica em qual tabela de especialização estão os dados específicos. |
| nome | VARCHAR(100) | Não | | | Nome completo. Para clientes pessoa jurídica, é o nome fantasia. |
| telefone | VARCHAR(20) | Não | | Só números, com DDD | Telefone de contato. Ex.: `62999998888`. |
| email | VARCHAR(100) | Sim | | | E-mail de contato. Opcional. |
| logradouro | VARCHAR(100) | Não | | | Rua, avenida etc. |
| numero | VARCHAR(10) | Não | | | Número do endereço. É texto para aceitar valores como `S/N` ou `120-A`. |
| bairro | VARCHAR(60) | Não | | | Bairro. |
| cidade | VARCHAR(60) | Não | | | Cidade. |
| uf | CHAR(2) | Não | | 2 letras maiúsculas | Sigla do estado. |

### cliente
Especialização de `pessoa` para quem contrata obras. É especializada em `cliente_pf` ou `cliente_pj`.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK, FK | | Identificador do cliente. É o mesmo `id` da tabela `pessoa`. |
| tipo | CHAR(2) | Não | | `CHECK` em (`pf`, `pj`) | Indica se o cliente é pessoa física ou jurídica. Não pode ser alterado depois do cadastro (RN16). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| id | pessoa (id) | `CASCADE` |

### cliente_pf
Especialização de `cliente` para pessoas físicas.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK, FK | | Identificador do cliente. |
| cpf | CHAR(11) | Não | UK | Só números | CPF do cliente (RN01). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| id | cliente (id) | `CASCADE` |

### cliente_pj
Especialização de `cliente` para pessoas jurídicas.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK, FK | | Identificador do cliente. |
| cnpj | CHAR(14) | Não | UK | Só números | CNPJ da empresa (RN01). |
| razao_social | VARCHAR(150) | Não | | | Nome jurídico da empresa, como consta no CNPJ. |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| id | cliente (id) | `CASCADE` |

### engenheiro
Especialização de `pessoa` para os engenheiros responsáveis pelas obras.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK, FK | | Identificador do engenheiro. |
| crea | VARCHAR(20) | Não | UK | | Número de registro no CREA (RN02). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| id | pessoa (id) | `CASCADE` |

### colaborador
Especialização de `pessoa` para os membros das equipes de instalação.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK, FK | | Identificador do colaborador. |
| equipe_id | INT | Não | FK | | Equipe da qual o colaborador faz parte (RN13). |
| cpf | CHAR(11) | Não | UK | Só números | CPF do colaborador (RN01). |
| funcao | VARCHAR(10) | Não | | `CHECK` em (`instalador`, `ajudante`) | Função na equipe. O instalador é o eletricista (RN13). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| id | pessoa (id) | `CASCADE` |
| equipe_id | equipe (id) | `RESTRICT` |

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

### equipe
Equipes de instalação que executam as obras. Cada equipe precisa ter no mínimo um instalador e um ajudante (RN12), regra validada pela aplicação.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador da equipe. |
| nome | VARCHAR(50) | Não | UK | | Nome que identifica a equipe. Ex.: `Equipe 01`. |

### fabricante
Marcas dos equipamentos.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador do fabricante. |
| nome | VARCHAR(60) | Não | UK | | Nome da marca. |
| pais_origem | VARCHAR(60) | Não | | | País de origem do fabricante. |

### equipamento
Catálogo de equipamentos que a empresa instala.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador do equipamento. |
| fabricante_id | INT | Não | FK | | Fabricante do equipamento. |
| tipo | VARCHAR(20) | Não | | `CHECK` em (`modulo`, `inversor`, `microinversor`, `estrutura`, `string_box`, `cabo`) | Categoria do equipamento. O cálculo do kWp usa apenas os do tipo `modulo`. |
| modelo | VARCHAR(100) | Não | | | Nome comercial do modelo. |
| potencia_w | INT | Sim | | `CHECK` > 0, quando preenchido | Potência em watts. Para módulos, é a potência de pico (Wp). Fica vazio em equipamentos sem potência, como estruturas e cabos. |
| preco_atual | DECIMAL(10,2) | Não | | `CHECK` > 0 | Preço de venda atual no catálogo, em reais. Serve de sugestão ao adicionar o equipamento a uma obra (RN07). |
| garantia_anos | INT | Não | | `CHECK` ≥ 0 | Tempo de garantia do fabricante, em anos, contado a partir da conclusão da instalação (RN10). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| fabricante_id | fabricante (id) | `RESTRICT` |

### etapa
Lista padrão das etapas pelas quais toda obra passa.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador da etapa. |
| nome | VARCHAR(50) | Não | UK | | Nome da etapa. Ex.: `Homologação`. |
| ordem | INT | Não | UK | `CHECK` > 0 | Posição da etapa na sequência da obra (1, 2, 3...). |

---

## Obras

### obra
Cada instalação de usina fotovoltaica contratada por um cliente.

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| id | INT | Não | PK | `AUTO_INCREMENT` | Identificador da obra. |
| cliente_id | INT | Não | FK | | Cliente que contratou a obra. |
| engenheiro_id | INT | Não | FK | | Engenheiro responsável técnico pela obra. |
| concessionaria_id | INT | Não | FK | | Concessionária à qual a usina será conectada. |
| numero_uc | VARCHAR(20) | Não | | | Número da unidade consumidora na concessionária. Não é único, porque uma UC pode receber uma ampliação. |
| logradouro | VARCHAR(100) | Não | | | Rua do local da instalação. |
| numero | VARCHAR(10) | Não | | | Número do local da instalação. |
| bairro | VARCHAR(60) | Não | | | Bairro do local da instalação. |
| cidade | VARCHAR(60) | Não | | | Cidade do local da instalação. |
| uf | CHAR(2) | Não | | 2 letras maiúsculas | Estado do local da instalação. |
| tipo_ligacao | VARCHAR(10) | Não | | `CHECK` em (`monofasica`, `bifasica`, `trifasica`) | Tipo de ligação da unidade consumidora (RN04). |
| data_contrato | DATE | Não | | | Data de assinatura do contrato. É a base do relatório de vendas por mês. |
| valor_contrato | DECIMAL(12,2) | Não | | `CHECK` > 0 | Valor total do contrato, em reais (RN05). |

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| cliente_id | cliente (id) | `RESTRICT` |
| engenheiro_id | engenheiro (id) | `RESTRICT` |
| concessionaria_id | concessionaria (id) | `RESTRICT` |

O endereço desta tabela é o **local da instalação**, que pode ser diferente do endereço do cliente guardado em `pessoa`.

### obra_equipe
Equipes de instalação alocadas em cada obra (relacionamento N:N entre `obra` e `equipe`).

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| obra_id | INT | Não | PK, FK | | Obra. |
| equipe_id | INT | Não | PK, FK | | Equipe alocada na obra. Só pode ser uma equipe completa (RN14). |

A chave primária composta (`obra_id`, `equipe_id`) impede que a mesma equipe seja alocada duas vezes na mesma obra (RN15).

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| obra_id | obra (id) | `RESTRICT` |
| equipe_id | equipe (id) | `RESTRICT` |

### obra_equipamento
Equipamentos utilizados em cada obra (relacionamento N:N entre `obra` e `equipamento`).

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| obra_id | INT | Não | PK, FK | | Obra. |
| equipamento_id | INT | Não | PK, FK | | Equipamento utilizado. |
| quantidade | INT | Não | | `CHECK` > 0 | Quantidade de unidades desse equipamento na obra (RN05). |
| valor_unitario | DECIMAL(10,2) | Não | | `CHECK` > 0 | Preço cobrado por unidade **nesta obra**, em reais. Não muda quando o preço do catálogo muda (RN07). |

A chave primária composta faz com que cada equipamento apareça **uma vez por obra**. Vinte módulos do mesmo modelo são uma linha com `quantidade = 20`.

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| obra_id | obra (id) | `RESTRICT` |
| equipamento_id | equipamento (id) | `RESTRICT` |

### obra_etapa
Andamento de cada etapa em cada obra (relacionamento N:N entre `obra` e `etapa`).

| Coluna | Tipo | Nulo | Chave | Restrições | Descrição |
|---|---|---|---|---|---|
| obra_id | INT | Não | PK, FK | | Obra. |
| etapa_id | INT | Não | PK, FK | | Etapa. |
| data_prevista | DATE | Não | | | Data planejada para concluir a etapa. |
| data_inicio | DATE | Sim | | | Data em que a etapa começou. Fica vazia enquanto a etapa está apenas planejada. Na homologação, é a data do protocolo na concessionária (RN09). |
| data_conclusao | DATE | Sim | | `CHECK` ≥ `data_inicio`; só pode ser preenchida se `data_inicio` estiver preenchida | Data em que a etapa terminou. Fica vazia enquanto a etapa não termina. Na homologação, é a data da aprovação (RN09). Na instalação, é o início da garantia dos equipamentos (RN10). |

Uma etapa está **atrasada** quando a data de hoje já passou de `data_prevista` e `data_conclusao` está vazia (RN11).

| Chave estrangeira | Referencia | Ao excluir |
|---|---|---|
| obra_id | obra (id) | `RESTRICT` |
| etapa_id | etapa (id) | `RESTRICT` |

---

## Informação calculada (não armazenada)

| Informação | Como é calculada | Regra |
|---|---|---|
| **Potência da obra (kWp)** | Soma de `obra_equipamento.quantidade` × `equipamento.potencia_w` dos equipamentos do tipo `modulo` da obra, dividida por 1000. | RN08 |
| **Tempo de homologação (dias)** | Diferença em dias entre `data_conclusao` e `data_inicio` da etapa de homologação da obra. | RN09 |
| **Fim da garantia de um equipamento** | `data_conclusao` da etapa de instalação da obra, somada a `equipamento.garantia_anos`. | RN10 |

Esses valores não são guardados em colunas porque dependem de outras tabelas: guardá-los criaria redundância e o risco de ficarem desatualizados.
