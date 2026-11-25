# Modelo Lógico: Gestão Fotovoltaica

O modelo lógico transforma o [modelo conceitual](modelo_conceitual.md) em **tabelas**, com chaves primárias, chaves estrangeiras e tipos de dados. Ele já considera o banco que será usado (MariaDB 10.4), mas ainda não é o script SQL. O script fica para o modelo físico, em `banco_de_dados/01_estrutura.sql`.

O diagrama está em [`modelo_logico.puml`](modelo_logico.puml), na notação **pé de galinha** (*crow's foot*).

## Como o modelo conceitual virou tabelas

| No modelo conceitual | No modelo lógico |
|---|---|
| Cada **entidade** | Uma tabela, com o identificador como chave primária (`id`, autoincremento). |
| **Especialização** (herança) | Uma tabela para cada entidade da hierarquia. A chave primária da especialização é também chave estrangeira para a tabela mãe. Detalhes na próxima seção. |
| Relacionamento **1:N** (CONTRATA, RESPONSAVEL_POR, CONECTA, COMPOE, FABRICA) | Uma **chave estrangeira** na tabela do lado N. Ex.: `obra.cliente_id` aponta para `cliente`. |
| Relacionamento **N:N** (EXECUTA, UTILIZA, PASSA_POR) | Uma **tabela associativa**, com chave primária composta pelas duas chaves estrangeiras e com os atributos do relacionamento. |
| **Atributo composto** (endereços) | Uma coluna para cada parte: `logradouro`, `numero`, `bairro`, `cidade`, `uf`. |
| **Atributo derivado** (potência em kWp) | **Não vira coluna.** É calculado nas consultas a partir de `obra_equipamento` e `equipamento` (RN08). |

## Mapeamento da herança

Existem três estratégias comuns para levar uma especialização para tabelas:

| Estratégia | Como fica | Por que não (ou por que sim) |
|---|---|---|
| Tabela única | Uma tabela `pessoa` com todas as colunas de todas as especializações (`cpf_cnpj`, `crea`, `cpf`, `funcao`, `equipe_id`). | Cada linha teria várias colunas sempre vazias, e não daria para tornar `crea` obrigatório só para engenheiros. |
| Só as especializações | Tabelas `cliente`, `engenheiro` e `colaborador`, cada uma repetindo nome, telefone, e-mail e endereço. | Repete as colunas comuns em três tabelas. |
| **Uma tabela por entidade** ✔ | `pessoa` com os dados comuns e uma tabela para cada especialização, ligadas pela chave. | **Escolhida.** Não repete colunas e não deixa colunas vazias. |

Na estratégia escolhida:
- a chave primária de cada especialização **é a mesma** da pessoa: o cliente com `id = 7` tem uma linha em `pessoa` e uma em `cliente`, as duas com `id = 7`. Nas especializações, a coluna `id` é ao mesmo tempo chave primária e chave estrangeira;
- por isso a relação entre a tabela mãe e cada especialização é **1:1**;
- para montar os dados completos de um cliente, de um engenheiro ou de um colaborador, as consultas fazem um **JOIN** com `pessoa`.

**Coluna discriminadora.** A tabela `pessoa` tem a coluna `categoria` (`cliente`, `engenheiro` ou `colaborador`), que diz em qual especialização estão os dados de cada pessoa.

Tecnicamente essa informação poderia ser descoberta verificando em qual tabela filha a linha existe. A coluna é uma **redundância controlada**, mantida por dois motivos: deixa as listagens e validações mais simples, e ajuda a aplicação a garantir que a especialização é exclusiva.

**PF e PJ.** O cliente não tem uma coluna de tipo. Se ele é pessoa física ou jurídica, isso é deduzido pela quantidade de dígitos de `cpf_cnpj` (11 ou 14). Guardar o tipo numa coluna separada seria redundância, com o risco de um "pf" ter um CNPJ.

## Esquema relacional

Notação: a chave primária está em **negrito** e as chaves estrangeiras estão em *itálico*.

**Herança**

- pessoa (**id**, categoria, nome, telefone, email, logradouro, numero, bairro, cidade, uf)
- cliente (***id***, cpf_cnpj)
  - *id* referencia pessoa
- engenheiro (***id***, crea)
  - *id* referencia pessoa
- colaborador (***id***, *equipe_id*, cpf, funcao)
  - *id* referencia pessoa
  - *equipe_id* referencia equipe

**Tabelas independentes**

- concessionaria (**id**, nome, sigla, uf)
- equipe (**id**, nome)
- fabricante (**id**, nome, pais_origem)
- etapa (**id**, nome, ordem)

**Tabelas com chave estrangeira**

- equipamento (**id**, *fabricante_id*, tipo, modelo, potencia_w, preco_atual, garantia_anos)
  - *fabricante_id* referencia fabricante
- obra (**id**, *cliente_id*, *engenheiro_id*, *concessionaria_id*, numero_uc, logradouro, numero, bairro, cidade, uf, tipo_ligacao, data_contrato, valor_contrato)
  - *cliente_id* referencia cliente (id)
  - *engenheiro_id* referencia engenheiro (id)
  - *concessionaria_id* referencia concessionaria

**Tabelas associativas (N:N)**

- obra_equipe (***obra_id***, ***equipe_id***)
  - *obra_id* referencia obra
  - *equipe_id* referencia equipe
- obra_equipamento (***obra_id***, ***equipamento_id***, quantidade, valor_unitario)
  - *obra_id* referencia obra
  - *equipamento_id* referencia equipamento
- obra_etapa (***obra_id***, ***etapa_id***, data_prevista, data_inicio, data_conclusao)
  - *obra_id* referencia obra
  - *etapa_id* referencia etapa

No total são **13 tabelas**: 4 da hierarquia de pessoas, 6 das demais entidades e 3 associativas.

## Restrições de integridade

### Chaves únicas
| Tabela | Coluna(s) | Motivo |
|---|---|---|
| cliente | cpf_cnpj | RN01 |
| colaborador | cpf | RN01 |
| engenheiro | crea | RN02 |
| concessionaria | sigla | Duas concessionárias não têm a mesma sigla. |
| equipe | nome | Evita duas equipes com o mesmo nome. |
| fabricante | nome | Evita cadastrar a mesma marca duas vezes. |
| etapa | nome, ordem (cada uma) | Cada etapa aparece uma vez e ocupa uma posição única na sequência. |

As chaves primárias compostas das tabelas associativas também funcionam como restrição: a mesma equipe não pode ser alocada duas vezes na mesma obra (RN15), e o mesmo equipamento ou a mesma etapa não se repetem dentro de uma obra.

### Domínios (CHECK)
| Tabela | Regra | Origem |
|---|---|---|
| pessoa | `categoria` deve ser `cliente`, `engenheiro` ou `colaborador` | RN16 |
| cliente | `cpf_cnpj` deve ter exatamente 11 ou 14 dígitos, só números | RN01 |
| colaborador | `funcao` deve ser `instalador` ou `ajudante` | RN13 |
| obra | `tipo_ligacao` deve ser `monofasica`, `bifasica` ou `trifasica` | RN04 |
| obra | `valor_contrato` > 0 | RN05 |
| equipamento | `tipo` deve ser `modulo`, `inversor`, `microinversor`, `estrutura`, `string_box` ou `cabo` | Decisão 5 do modelo conceitual |
| equipamento | `preco_atual` > 0, `garantia_anos` ≥ 0 e `potencia_w` > 0 (quando informada) | Consistência dos dados |
| etapa | `ordem` > 0 | A sequência das etapas começa em 1. |
| obra_equipamento | `quantidade` > 0 e `valor_unitario` > 0 | RN05 |
| obra_etapa | `data_conclusao` ≥ `data_inicio` | RN06 |
| obra_etapa | `data_conclusao` só pode ser preenchida se `data_inicio` também estiver | Uma etapa não termina sem ter começado. |

Os valores de domínio são gravados **sem acentos e em minúsculas** (`monofasica`, `modulo`, `ajudante`). Isso evita erros de comparação nas consultas, como `WHERE tipo = 'modulo'` no cálculo do kWp. As telas exibem os nomes formatados.

### Chaves estrangeiras
Há duas regras de exclusão, conforme o tipo de ligação:

| Ligação | Regra | Efeito |
|---|---|---|
| **Herança** (especialização → tabela mãe) | `ON DELETE CASCADE` | Ao excluir uma pessoa, as linhas dela em `cliente`, `engenheiro` ou `colaborador` são excluídas junto. A aplicação só precisa excluir de `pessoa`. |
| **Todas as outras** | `ON DELETE RESTRICT` | O banco recusa a exclusão de um registro que ainda é referenciado. Isso implementa a RN03 no próprio banco. |

As duas regras trabalham juntas. Se a aplicação tentar excluir a pessoa de um cliente que tem obras, o `CASCADE` tenta excluir a linha de `cliente`, mas o `RESTRICT` de `obra.cliente_id` impede, e **a exclusão inteira é cancelada**. O cliente com obras continua intacto, e a aplicação mostra a mensagem de erro.

### Campos opcionais (aceitam NULL)
| Coluna | Por quê |
|---|---|
| pessoa.email | Nem toda pessoa informa e-mail. |
| equipamento.potencia_w | Estruturas e cabos não têm potência. |
| obra_etapa.data_inicio | A etapa pode estar apenas planejada. |
| obra_etapa.data_conclusao | A etapa pode estar em andamento. É o que identifica uma etapa atrasada (RN11). |

### Regras que ficam na aplicação
Algumas regras dependem de contar ou comparar linhas de outras tabelas, ou de comparar o valor antigo com o novo, o que não dá para fazer com `CHECK`. Elas serão validadas na camada de Modelo do PHP:
- **RN12:** a equipe deve ter no mínimo um instalador e um ajudante;
- **RN14:** só uma equipe completa pode ser alocada em uma obra;
- **RN16:** cada pessoa tem exatamente uma especialização, coerente com a `categoria`;
- **RN07:** sugerir o preço do catálogo como valor unitário.

Para garantir a RN16, **toda inserção de pessoa é feita numa transação**. Por exemplo, para um cliente: `INSERT` em `pessoa`, depois em `cliente`, e só então `COMMIT`. Se qualquer etapa falhar, um `ROLLBACK` desfaz tudo, e não sobra uma pessoa sem especialização (RNF13).

## Normalização

### 1ª Forma Normal: valores atômicos e sem grupos repetidos
- Os endereços da pessoa e da obra foram divididos em colunas.
- As etapas da obra ficam em **linhas** de `obra_etapa`, e não em colunas como `data_projeto`, `data_homologacao`, `data_instalacao`.
- As equipes da obra ficam em linhas de `obra_equipe`, e os membros da equipe em linhas de `colaborador`. Não existem colunas como `equipe1`, `equipe2` ou `ajudante1`, `ajudante2`.
- A coluna `cliente.cpf_cnpj` também é atômica: ela guarda **um único valor**, o documento de identificação do cliente, que pode ser um CPF ou um CNPJ. Não guarda os dois ao mesmo tempo, nem uma lista de documentos.

### 2ª Forma Normal: sem dependência parcial da chave
A 2FN só pode ser violada em tabelas com chave primária composta, que aqui são as três associativas:
- em `obra_equipamento`, a quantidade e o valor unitário dependem da **obra e do equipamento juntos**. O modelo do equipamento, por exemplo, depende só de `equipamento_id`, por isso fica na tabela `equipamento`, e não aqui;
- em `obra_etapa`, as datas dependem da **obra e da etapa juntas**. O nome da etapa depende só de `etapa_id` e fica em `etapa`;
- `obra_equipe` não tem colunas além da chave.

### 3ª Forma Normal: sem dependência transitiva
Nenhuma coluna não chave depende de outra coluna não chave:
- `obra` guarda apenas `cliente_id`, e não o nome ou o telefone do cliente;
- `colaborador` guarda apenas `equipe_id`, e não o nome da equipe;
- `equipamento` guarda apenas `fabricante_id`, e não o país do fabricante;
- os dados comuns das pessoas ficam só em `pessoa`, sem cópia nas especializações;
- a potência da obra **não é armazenada**, porque depende dos equipamentos e seria uma dependência transitiva (e uma redundância).

**Sobre `cidade` e `uf`** (em `pessoa` e em `obra`): pode parecer que a UF depende da cidade, mas o nome de uma cidade não determina o estado (existem cidades com o mesmo nome em estados diferentes, como "Bom Jesus"). Por isso as duas colunas não formam uma dependência transitiva. Para eliminar essa discussão por completo, seria preciso criar uma tabela de municípios, o que foge do escopo deste trabalho.

## Observações de modelagem

- **A UC não é única.** Uma mesma unidade consumidora pode receber uma segunda obra, por exemplo na ampliação de um sistema que já existe. Por isso `numero_uc` não tem restrição de unicidade.
- **O mesmo equipamento aparece uma vez por obra.** Como a chave de `obra_equipamento` é (obra, equipamento), se a obra usa 20 módulos do mesmo modelo, isso é **uma linha com quantidade 20**, e não 20 linhas.
- **COMPOE aparece como "um para um ou muitos"** no diagrama (`||--|{`). A notação pé de galinha não consegue mostrar o mínimo de 2 colaboradores do modelo conceitual. Essa regra é garantida pela aplicação (RN12).
- **Padrão de nomes das chaves.** Toda chave primária se chama `id`, e toda chave estrangeira se chama `nometabela_id`, indicando a tabela para onde aponta: `obra.cliente_id` aponta para `cliente.id`, e `colaborador.equipe_id` aponta para `equipe.id`. Há duas situações especiais:
  - nas **especializações** (`cliente`, `engenheiro`, `colaborador`), a chave primária também é chave estrangeira para a tabela mãe. Ela segue a regra da chave primária e se chama `id`;
  - nas **tabelas associativas**, não existe coluna `id`: a chave primária é composta pelas duas chaves estrangeiras, que seguem a regra `nometabela_id` (por exemplo, `obra_id` e `equipe_id`).
- **Povoamento.** Com a herança, `pessoa` recebe uma linha para cada cliente, engenheiro e colaborador. Para cumprir o mínimo de 10 registros por tabela, são necessários pelo menos 10 clientes, 10 engenheiros e 20 colaboradores (10 equipes com um instalador e um ajudante), ou seja, **40 pessoas ou mais**. Vale misturar clientes com CPF e com CNPJ.
