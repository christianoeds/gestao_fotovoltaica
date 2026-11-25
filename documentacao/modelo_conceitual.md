# Modelo Conceitual: Gestão Fotovoltaica

O modelo conceitual mostra **quais dados o sistema guarda e como eles se relacionam**, sem se preocupar ainda com tabelas, chaves estrangeiras ou tipos de dados. Essas questões ficam para o [modelo lógico](modelo_logico.md).

O diagrama está em [`modelo_conceitual.puml`](modelo_conceitual.puml), na notação de **Peter Chen** (entidades em retângulos, relacionamentos em losangos e atributos em elipses).

## Como ler as cardinalidades

Cada lado de um relacionamento tem um par **(mínimo, máximo)**. O par que fica **ao lado de uma entidade** diz com quantas instâncias **dessa entidade** uma instância da outra se relaciona.

Exemplo: `CLIENTE (1,1) — CONTRATA — (0,N) OBRA`
- o **(0,N)** ao lado de OBRA indica que **um cliente contrata de zero a muitas obras**;
- o **(1,1)** ao lado de CLIENTE indica que **uma obra é contratada por exatamente um cliente**.

## Generalização e especialização (herança)

Clientes, engenheiros e colaboradores têm dados em comum: nome, telefone, e-mail e endereço. Em vez de repetir esses atributos em três entidades, eles ficam numa entidade genérica, **PESSOA**, e cada papel vira uma **especialização** que herda esses atributos e acrescenta os seus.

```
                    PESSOA
       (nome, telefone, email, endereço)
                      │  total, exclusiva
         ┌────────────┼──────────────┐
      CLIENTE     ENGENHEIRO     COLABORADOR
    (cpf_cnpj)      (crea)       (cpf, funcao)
```

| Especialização | Total ou parcial | Exclusiva ou sobreposta |
|---|---|---|
| PESSOA → CLIENTE, ENGENHEIRO, COLABORADOR | **Total**: toda pessoa cadastrada tem um papel. Não existe "pessoa" solta no sistema. | **Exclusiva**: cada pessoa cadastrada tem um único papel. |

No diagrama, a **linha dupla** indica especialização total e a letra **"d"** (de *disjoint*) indica especialização exclusiva.

**Por que a especialização é exclusiva.** Na prática, um colaborador pode um dia contratar uma obra. Se a especialização fosse sobreposta, essa pessoa teria o CPF guardado duas vezes (em COLABORADOR e em CLIENTE), o que é redundância. Como esse caso é raro, optou-se pela especialização exclusiva: se acontecer, a pessoa é cadastrada uma vez como colaborador e outra vez como cliente.

**Onde fica o documento.** O documento não está em PESSOA porque os engenheiros são identificados pelo CREA. O cliente tem um único atributo, **cpf_cnpj**, que guarda o CPF de uma pessoa física ou o CNPJ de uma empresa. O tipo de cliente não precisa ser guardado: ele é deduzido pela quantidade de dígitos (11 para CPF, 14 para CNPJ). O colaborador, que é sempre pessoa física, tem o atributo **cpf**.

**Por que PF e PJ não são especializações.** Seria possível especializar CLIENTE em CLIENTE_PF e CLIENTE_PJ. Mas a única diferença entre eles seria o documento, e a especialização acrescentaria duas tabelas e um nível a mais de herança sem ganho real. Por isso foi mantido um único tipo de cliente.

## Entidades

O atributo identificador de cada entidade está em **negrito**. As especializações não têm identificador próprio: herdam o de PESSOA.

| Entidade | Atributos | Descrição |
|---|---|---|
| **PESSOA** | **id**, nome, telefone, email, endereco *(composto)* | Dados comuns a todas as pessoas do sistema. |
| **CLIENTE** | cpf_cnpj | Pessoa física ou jurídica que contrata obras. |
| **ENGENHEIRO** | crea | Responsável técnico pelas obras. |
| **COLABORADOR** | cpf, funcao | Membro de uma equipe, com a função de instalador ou ajudante. |
| **CONCESSIONARIA** | **id**, nome, sigla, uf | Distribuidora de energia que aprova a conexão da usina à rede. |
| **EQUIPE** | **id**, nome | Equipe de instalação que executa as obras em campo. |
| **FABRICANTE** | **id**, nome, pais_origem | Marca dos equipamentos. |
| **EQUIPAMENTO** | **id**, tipo, modelo, potencia_w, preco_atual, garantia_anos | Item do catálogo: módulo, inversor, estrutura etc. |
| **ETAPA** | **id**, nome, ordem | Etapa padrão pela qual toda obra passa. |
| **OBRA** | **id**, numero_uc, endereco_instalacao *(composto)*, tipo_ligacao, data_contrato, valor_contrato, potencia_kwp *(derivado)* | Instalação de uma usina fotovoltaica para um cliente. |

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

Os relacionamentos ligam as especializações certas: a obra se relaciona com **CLIENTE** e com **ENGENHEIRO**, e a equipe com **COLABORADOR**. Nenhum relacionamento liga diretamente em PESSOA.

## Decisões de modelagem

**1. A potência da obra (kWp) é um atributo derivado.**
Ela aparece no diagrama porque é uma informação importante da obra, mas é marcada como derivada: é calculada pela soma de quantidade × potência dos módulos utilizados (RN08). Por isso **não vai virar coluna** no modelo lógico. Guardar esse valor criaria redundância e o risco de ele ficar diferente dos equipamentos registrados.

**2. Os endereços são atributos compostos, e existem dois diferentes.**
Tanto o endereço da pessoa quanto o endereço de instalação da obra são formados por logradouro, número, bairro, cidade e UF. No modelo lógico, cada parte vira uma coluna própria, o que atende à 1ª Forma Normal (valores atômicos) e permite consultas por cidade ou por estado.
Os dois endereços **não são redundantes**: o endereço da pessoa é onde o cliente mora ou tem sede, e o endereço da obra é onde a usina é instalada. Uma empresa com sede na capital pode instalar uma usina numa fazenda no interior.

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

**7. Clientes, engenheiros e colaboradores são especializações de PESSOA.**
Os atributos comuns ficam num só lugar, e cada especialização guarda apenas o que é dela. Os detalhes e as justificativas estão na seção "Generalização e especialização", acima.

## Restrições que o diagrama não consegue representar

- A cardinalidade **(2,N)** em COMPOE garante que a equipe tenha no mínimo dois colaboradores, mas não garante que **um deles seja instalador e o outro ajudante** (RN12). Essa regra depende do valor do atributo `funcao`. Por isso ela será validada na camada de Modelo da aplicação, e não pela estrutura do banco.