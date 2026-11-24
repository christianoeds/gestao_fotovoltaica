# Modelo Conceitual: Gestão Fotovoltaica

O modelo conceitual mostra **quais dados o sistema guarda e como eles se relacionam**, sem se preocupar ainda com tabelas, chaves estrangeiras ou tipos de dados. Essas questões ficam para o [modelo lógico](modelo_logico.md).

O diagrama está em [`modelo_conceitual.puml`](modelo_conceitual.puml), na notação de **Peter Chen** (entidades em retângulos, relacionamentos em losangos e atributos em elipses).

## Como ler as cardinalidades

Cada lado de um relacionamento tem um par **(mínimo, máximo)**. O par que fica **ao lado de uma entidade** diz com quantas instâncias **dessa entidade** uma instância da outra se relaciona.

Exemplo: `CLIENTE (1,1) — CONTRATA — (0,N) OBRA`
- o **(0,N)** ao lado de OBRA indica que **um cliente contrata de zero a muitas obras**;
- o **(1,1)** ao lado de CLIENTE indica que **uma obra é contratada por exatamente um cliente**.

## Entidades

O atributo identificador de cada entidade está em **negrito**.

| Entidade | Atributos | Descrição |
|---|---|---|
| **CLIENTE** | **id_cliente**, nome, cpf_cnpj, telefone, email, cidade | Pessoa física ou jurídica que contrata uma obra. |
| **CONCESSIONARIA** | **id_concessionaria**, nome, sigla, uf | Distribuidora de energia que aprova a conexão da usina à rede. |
| **ENGENHEIRO** | **id_engenheiro**, nome, crea, telefone, email | Responsável técnico pelas obras. |
| **EQUIPE** | **id_equipe**, nome | Equipe de instalação que executa as obras em campo. |
| **COLABORADOR** | **id_colaborador**, nome, cpf, telefone, funcao | Membro de uma equipe, com a função de instalador ou ajudante. |
| **FABRICANTE** | **id_fabricante**, nome, pais_origem | Marca dos equipamentos. |
| **EQUIPAMENTO** | **id_equipamento**, tipo, modelo, potencia_w, preco_atual, garantia_anos | Item do catálogo: módulo, inversor, estrutura etc. |
| **ETAPA** | **id_etapa**, nome, ordem | Etapa padrão pela qual toda obra passa. |
| **OBRA** | **id_obra**, numero_uc, endereco *(composto)*, tipo_ligacao, data_contrato, valor_contrato, potencia_kwp *(derivado)* | Instalação de uma usina fotovoltaica para um cliente. |

## Relacionamentos

| Relacionamento | Entidades e cardinalidades | Leitura | Atributos |
|---|---|---|---|
| **CONTRATA** | CLIENTE (1,1) — (0,N) OBRA | Um cliente contrata nenhuma ou várias obras. Cada obra pertence a um único cliente. | — |
| **RESPONSAVEL_POR** | ENGENHEIRO (1,1) — (0,N) OBRA | Um engenheiro é responsável por nenhuma ou várias obras. Cada obra tem um único engenheiro responsável. | — |
| **EXECUTA** | EQUIPE (0,N) — (0,N) OBRA | Uma equipe executa nenhuma ou várias obras. Uma obra pode ser executada por nenhuma ou várias equipes. | — |
| **CONECTA** | CONCESSIONARIA (1,1) — (0,N) OBRA | Uma concessionária atende nenhuma ou várias obras. Cada obra é conectada à rede de uma única concessionária. | — |
| **COMPOE** | EQUIPE (1,1) — (2,N) COLABORADOR | Uma equipe é formada por no mínimo dois colaboradores. Cada colaborador faz parte de uma única equipe. | — |
| **FABRICA** | FABRICANTE (1,1) — (0,N) EQUIPAMENTO | Um fabricante fabrica nenhum ou vários equipamentos. Cada equipamento tem um único fabricante. | — |
| **UTILIZA** | OBRA (0,N) — (0,N) EQUIPAMENTO | Uma obra utiliza nenhum ou vários equipamentos. Um equipamento pode ser utilizado em nenhuma ou várias obras. | quantidade, valor_unitario |
| **PASSA_POR** | OBRA (0,N) — (0,N) ETAPA | Uma obra passa por nenhuma ou várias etapas. Uma etapa é registrada em nenhuma ou várias obras. | data_prevista, data_inicio, data_conclusao |

## Decisões de modelagem

**1. A potência da obra (kWp) é um atributo derivado.**
Ela aparece no diagrama porque é uma informação importante da obra, mas é marcada como derivada: é calculada pela soma de quantidade × potência dos módulos utilizados (RN08). Por isso **não vai virar coluna** no modelo lógico. Guardar esse valor criaria redundância e o risco de ele ficar diferente dos equipamentos registrados.

**2. O endereço da obra é um atributo composto.**
O endereço é formado por logradouro, número, bairro, cidade e UF. No modelo lógico, cada parte vira uma coluna própria, o que atende à 1ª Forma Normal (valores atômicos) e permite consultas por cidade ou por estado.

**3. Os relacionamentos N:N têm atributos próprios.**
- Em **UTILIZA**, a quantidade e o valor unitário não pertencem nem à obra nem ao equipamento: dependem da combinação dos dois. O valor unitário fica aqui, e não apenas no equipamento, porque o preço do catálogo muda com o tempo e o valor cobrado em cada obra precisa ser preservado (RN07).
- Em **PASSA_POR**, as datas de cada etapa também dependem da combinação obra + etapa.

No modelo lógico, cada um desses relacionamentos vira uma tabela associativa.

**4. Uma obra pode ter várias equipes.**
Usinas maiores precisam de várias equipes trabalhando juntas, por isso EXECUTA é um relacionamento N:N. O mínimo do lado da equipe é zero, porque a obra é cadastrada na assinatura do contrato e só recebe equipes depois do projeto e da homologação. No modelo lógico, EXECUTA também vira uma tabela associativa, mesmo sem atributos próprios.

**5. O tipo do equipamento e a função do colaborador são atributos com valores fixos.**
O tipo do equipamento (módulo, inversor, estrutura...) e a função do colaborador (instalador ou ajudante) têm poucos valores possíveis, que não mudam e não têm outras informações associadas. Por isso foram modelados como atributos com domínio restrito, e não como entidades separadas. No modelo físico, o domínio será garantido com uma restrição `CHECK`.

**6. A etapa é uma entidade, e não apenas um atributo da obra.**
As etapas têm nome e ordem e se repetem em todas as obras. Se cada obra guardasse colunas como "data_homologacao" e "data_instalacao", haveria um grupo repetido de atributos, o que fere a 1ª Forma Normal. Além disso, incluir uma etapa nova exigiria alterar a estrutura da tabela. Com a etapa como entidade, basta cadastrar uma nova linha.

## Restrições que o diagrama não consegue representar

A cardinalidade **(2,N)** em COMPOE garante que a equipe tenha no mínimo dois colaboradores, mas não garante que **um deles seja instalador e o outro ajudante** (RN12). Essa regra depende do valor do atributo `funcao`. Por isso ela será validada na camada de Modelo da aplicação, e não pela estrutura do banco.
