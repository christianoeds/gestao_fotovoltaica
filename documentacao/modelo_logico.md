# Modelo Lógico: Gestão Fotovoltaica

O modelo lógico transforma o [modelo conceitual](modelo_conceitual.md) em **tabelas**, com chaves primárias, chaves estrangeiras e tipos de dados. Ele já considera o banco que será usado (MariaDB 10.4), mas ainda não é o script SQL. O script fica para o modelo físico, em `banco_de_dados/01_estrutura.sql`.

O diagrama está em [`modelo_logico.puml`](modelo_logico.puml), na notação **pé de galinha** (*crow's foot*).

## Como o modelo conceitual virou tabelas

| No modelo conceitual | No modelo lógico |
|---|---|
| Cada **entidade** | Uma tabela, com o identificador como chave primária (`id_...`, autoincremento). |
| **Especialização** (herança) | Uma tabela para cada entidade da hierarquia. A chave primária da especialização é também chave estrangeira para a tabela mãe. Detalhes na próxima seção. |
| Relacionamento **1:N** (CONTRATA, RESPONSAVEL_POR, CONECTA, COMPOE, FABRICA) | Uma **chave estrangeira** na tabela do lado N. Ex.: `obra.id_cliente` aponta para `cliente`. |
| Relacionamento **N:N** (EXECUTA, UTILIZA, PASSA_POR) | Uma **tabela associativa**, com chave primária composta pelas duas chaves estrangeiras e com os atributos do relacionamento. |
| **Atributo composto** (endereços) | Uma coluna para cada parte: `logradouro`, `numero`, `bairro`, `cidade`, `uf`. |
| **Atributo derivado** (potência em kWp) | **Não vira coluna.** É calculado nas consultas a partir de `obra_equipamento` e `equipamento` (RN08). |

## Mapeamento da herança

Existem três estratégias comuns para levar uma especialização para tabelas:

| Estratégia | Como fica | Por que não (ou por que sim) |
|---|---|---|
| Tabela única | Uma tabela `pessoa` com todas as colunas de todas as especializações (`cpf`, `cnpj`, `crea`, `funcao`...). | Cada linha teria várias colunas sempre vazias, e não daria para tornar `crea` obrigatório só para engenheiros. |
| Só as especializações | Tabelas `cliente_pf`, `cliente_pj`, `engenheiro` e `colaborador`, cada uma repetindo nome, telefone e endereço. | Repete as colunas comuns, e a obra precisaria de duas chaves estrangeiras opcionais para o cliente (PF ou PJ). |
| **Uma tabela por entidade** ✔ | `pessoa` com os dados comuns e uma tabela para cada especialização, ligadas pela chave. | **Escolhida.** Não repete colunas, não deixa colunas vazias e mantém a obra com um único `id_cliente`. |

Na estratégia escolhida:
- a chave primária de cada especialização **é a mesma** da pessoa: o cliente com `id_pessoa = 7` tem uma linha em `pessoa`, uma em `cliente` e uma em `cliente_pf` (ou `cliente_pj`), todas com `id_pessoa = 7`;
- por isso a relação entre a tabela mãe e cada especialização é **1:1**;
- para montar os dados completos de um cliente, de um engenheiro ou de um colaborador, as consultas fazem um **JOIN** com `pessoa`.

**Colunas discriminadoras.** As tabelas mãe têm uma coluna que diz qual especialização cada linha tem:
- `pessoa.categoria`: `cliente`, `engenheiro` ou `colaborador`;
- `cliente.tipo`: `pf` ou `pj`.

Tecnicamente essa informação poderia ser descoberta verificando em qual tabela filha a linha existe. A coluna é uma **redundância controlada**, mantida por dois motivos: deixa as listagens e validações mais simples (por exemplo, para saber em qual tabela buscar o CPF ou o CNPJ), e ajuda a aplicação a garantir que a especialização é exclusiva.

## Esquema relacional

Notação: a chave primária está em **negrito** e as chaves estrangeiras estão em *itálico*.

**Herança**

- pessoa (**id_pessoa**, categoria, nome, telefone, email, logradouro, numero, bairro, cidade, uf)
- cliente (***id_pessoa***, tipo)
  - *id_pessoa* referencia pessoa
- cliente_pf (***id_pessoa***, cpf)
  - *id_pessoa* referencia cliente
- cliente_pj (***id_pessoa***, cnpj, razao_social)
  - *id_pessoa* referencia cliente
- engenheiro (***id_pessoa***, crea)
  - *id_pessoa* referencia pessoa
- colaborador (***id_pessoa***, *id_equipe*, cpf, funcao)
  - *id_pessoa* referencia pessoa
  - *id_equipe* referencia equipe

**Tabelas independentes**

- concessionaria (**id_concessionaria**, nome, sigla, uf)
- equipe (**id_equipe**, nome)
- fabricante (**id_fabricante**, nome, pais_origem)
- etapa (**id_etapa**, nome, ordem)

**Tabelas com chave estrangeira**

- equipamento (**id_equipamento**, *id_fabricante*, tipo, modelo, potencia_w, preco_atual, garantia_anos)
  - *id_fabricante* referencia fabricante
- obra (**id_obra**, *id_cliente*, *id_engenheiro*, *id_concessionaria*, numero_uc, logradouro, numero, bairro, cidade, uf, tipo_ligacao, data_contrato, valor_contrato)
  - *id_cliente* referencia cliente (id_pessoa)
  - *id_engenheiro* referencia engenheiro (id_pessoa)
  - *id_concessionaria* referencia concessionaria

**Tabelas associativas (N:N)**

- obra_equipe (***id_obra***, ***id_equipe***)
  - *id_obra* referencia obra
  - *id_equipe* referencia equipe
- obra_equipamento (***id_obra***, ***id_equipamento***, quantidade, valor_unitario)
  - *id_obra* referencia obra
  - *id_equipamento* referencia equipamento
- obra_etapa (***id_obra***, ***id_etapa***, data_prevista, data_inicio, data_conclusao)
  - *id_obra* referencia obra
  - *id_etapa* referencia etapa

No total são **15 tabelas**: 6 da hierarquia de pessoas, 6 das demais entidades e 3 associativas.

## Restrições de integridade

### Chaves únicas
| Tabela | Coluna(s) | Motivo |
|---|---|---|
| cliente_pf | cpf | RN01 |
| cliente_pj | cnpj | RN01 |
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
| cliente | `tipo` deve ser `pf` ou `pj` | RN16 |
| colaborador | `funcao` deve ser `instalador` ou `ajudante` | RN13 |
| obra | `tipo_ligacao` deve ser `monofasica`, `bifasica` ou `trifasica` | RN04 |
| obra | `valor_contrato` > 0 | RN05 |
| equipamento | `tipo` deve ser `modulo`, `inversor`, `microinversor`, `estrutura`, `string_box` ou `cabo` | Decisão 5 do modelo conceitual |
| equipamento | `preco_atual` > 0, `garantia_anos` ≥ 0 e `potencia_w` > 0 (quando informada) | Consistência dos dados |
| obra_equipamento | `quantidade` > 0 e `valor_unitario` > 0 | RN05 |
| obra_etapa | `data_conclusao` ≥ `data_inicio` | RN06 |
| obra_etapa | `data_conclusao` só pode ser preenchida se `data_inicio` também estiver | Uma etapa não termina sem ter começado. |

Os valores de domínio são gravados **sem acentos e em minúsculas** (`monofasica`, `modulo`, `pf`). Isso evita erros de comparação nas consultas, como `WHERE tipo = 'modulo'` no cálculo do kWp. As telas exibem os nomes formatados.

### Chaves estrangeiras
Há duas regras de exclusão, conforme o tipo de ligação:

| Ligação | Regra | Efeito |
|---|---|---|
| **Herança** (especialização → tabela mãe) | `ON DELETE CASCADE` | Ao excluir uma pessoa, as linhas dela em `cliente`, `cliente_pf`, `cliente_pj`, `engenheiro` ou `colaborador` são excluídas junto. A aplicação só precisa excluir de `pessoa`. |
| **Todas as outras** | `ON DELETE RESTRICT` | O banco recusa a exclusão de um registro que ainda é referenciado. Isso implementa a RN03 no próprio banco. |

As duas regras trabalham juntas. Se a aplicação tentar excluir a pessoa de um cliente que tem obras, o `CASCADE` tenta excluir a linha de `cliente`, mas o `RESTRICT` de `obra.id_cliente` impede, e **a exclusão inteira é cancelada**. O cliente com obras continua intacto, e a aplicação mostra a mensagem de erro.

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
- **RN16:** cada pessoa tem exatamente uma especialização, coerente com `categoria` e `tipo`, e o tipo do cliente não muda depois do cadastro;
- **RN07:** sugerir o preço do catálogo como valor unitário.

Para garantir a RN16, **toda inserção de pessoa é feita numa transação**. Por exemplo, para um cliente PF: `INSERT` em `pessoa`, depois em `cliente`, depois em `cliente_pf`, e só então `COMMIT`. Se qualquer etapa falhar, um `ROLLBACK` desfaz tudo, e não sobra uma pessoa sem especialização (RNF13).

## Normalização

### 1ª Forma Normal: valores atômicos e sem grupos repetidos
- Os endereços da pessoa e da obra foram divididos em colunas.
- As etapas da obra ficam em **linhas** de `obra_etapa`, e não em colunas como `data_projeto`, `data_homologacao`, `data_instalacao`.
- As equipes da obra ficam em linhas de `obra_equipe`, e os membros da equipe em linhas de `colaborador`. Não existem colunas como `equipe1`, `equipe2` ou `ajudante1`, `ajudante2`.
- Não existe uma coluna genérica `cpf_cnpj`, que guardaria dois tipos de dado diferentes no mesmo campo. O CPF fica em `cliente_pf` e o CNPJ em `cliente_pj`.

### 2ª Forma Normal: sem dependência parcial da chave
A 2FN só pode ser violada em tabelas com chave primária composta, que aqui são as três associativas:
- em `obra_equipamento`, a quantidade e o valor unitário dependem da **obra e do equipamento juntos**. O modelo do equipamento, por exemplo, depende só de `id_equipamento`, por isso fica na tabela `equipamento`, e não aqui;
- em `obra_etapa`, as datas dependem da **obra e da etapa juntas**. O nome da etapa depende só de `id_etapa` e fica em `etapa`;
- `obra_equipe` não tem colunas além da chave.

### 3ª Forma Normal: sem dependência transitiva
Nenhuma coluna não chave depende de outra coluna não chave:
- `obra` guarda apenas `id_cliente`, e não o nome ou o telefone do cliente;
- `colaborador` guarda apenas `id_equipe`, e não o nome da equipe;
- `equipamento` guarda apenas `id_fabricante`, e não o país do fabricante;
- os dados comuns das pessoas ficam só em `pessoa`, sem cópia nas especializações;
- a potência da obra **não é armazenada**, porque depende dos equipamentos e seria uma dependência transitiva (e uma redundância).

**Sobre `cidade` e `uf`** (em `pessoa` e em `obra`): pode parecer que a UF depende da cidade, mas o nome de uma cidade não determina o estado (existem cidades com o mesmo nome em estados diferentes, como "Bom Jesus"). Por isso as duas colunas não formam uma dependência transitiva. Para eliminar essa discussão por completo, seria preciso criar uma tabela de municípios, o que foge do escopo deste trabalho.

## Observações de modelagem

- **A UC não é única.** Uma mesma unidade consumidora pode receber uma segunda obra, por exemplo na ampliação de um sistema que já existe. Por isso `numero_uc` não tem restrição de unicidade.
- **O mesmo equipamento aparece uma vez por obra.** Como a chave de `obra_equipamento` é (obra, equipamento), se a obra usa 20 módulos do mesmo modelo, isso é **uma linha com quantidade 20**, e não 20 linhas.
- **COMPOE aparece como "um para um ou muitos"** no diagrama (`||--|{`). A notação pé de galinha não consegue mostrar o mínimo de 2 colaboradores do modelo conceitual. Essa regra é garantida pela aplicação (RN12).
- **Nomes das chaves estrangeiras da obra.** As colunas `obra.id_cliente` e `obra.id_engenheiro` apontam para `cliente.id_pessoa` e `engenheiro.id_pessoa`. Os nomes foram mantidos como `id_cliente` e `id_engenheiro` para deixar claro o papel de cada chave dentro da obra.
- **Povoamento.** Com a herança, `pessoa` recebe uma linha para cada cliente, engenheiro e colaborador. Para cumprir o mínimo de 10 registros por tabela, são necessários pelo menos 10 clientes PF, 10 clientes PJ, 10 engenheiros e 20 colaboradores (10 equipes com um instalador e um ajudante), ou seja, **50 pessoas ou mais**.
