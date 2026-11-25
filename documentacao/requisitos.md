# Requisitos do Sistema: Gestão Fotovoltaica

Este documento lista o que o sistema deve fazer (requisitos funcionais), as regras de negócio que ele deve respeitar e as características técnicas que ele deve ter (requisitos não funcionais). Tudo foi levantado a partir do [briefing](briefing.md).

## Atores

| Ator | Descrição |
|---|---|
| **Comercial** | Cadastra clientes e obras e registra o valor do contrato. |
| **Engenheiro** | Registra o andamento das obras (homologação e conclusão) e os equipamentos usados em cada obra. |
| **Diretoria** | Mantém os cadastros de apoio (engenheiros, cidades, concessionárias, fabricantes e equipamentos) e consulta os relatórios. |

## Requisitos funcionais

### Cadastros

Em todos os cadastros abaixo, "manter" significa **inserir, listar, editar e excluir** registros.

| Código | Requisito | Ator |
|---|---|---|
| RF01 | O sistema deve permitir manter **clientes** (nome, CPF ou CNPJ, telefone, e-mail e endereço). | Comercial |
| RF02 | O sistema deve permitir manter **engenheiros** (nome, CREA, telefone, e-mail e endereço). | Diretoria |
| RF03 | O sistema deve permitir manter **cidades** (nome e UF). | Diretoria |
| RF04 | O sistema deve permitir manter **concessionárias** (nome, sigla e estado). | Diretoria |
| RF05 | O sistema deve permitir manter **fabricantes** (nome e país de origem). | Diretoria |
| RF06 | O sistema deve permitir manter **equipamentos** (tipo, modelo, fabricante, potência, preço atual e garantia em anos). | Diretoria |
| RF07 | O sistema deve permitir manter **obras** (cliente, engenheiro responsável, concessionária, número da UC, endereço da instalação, tipo de ligação, data do contrato, valor do contrato e data prevista de conclusão). | Comercial |

### Acompanhamento da obra

| Código | Requisito | Ator |
|---|---|---|
| RF08 | O sistema deve permitir registrar o **andamento da obra**: a data de protocolo e a data de aprovação da homologação, e a data de conclusão da instalação. | Engenheiro |
| RF09 | O sistema deve permitir registrar os **equipamentos usados em uma obra**, com a quantidade e o valor unitário cobrado. | Engenheiro |
| RF10 | O sistema deve exibir, na tela de detalhes da obra, a **potência total da usina em kWp**, calculada a partir dos módulos registrados. | Todos |

### Relatórios

Cada relatório corresponde a uma das consultas SQL exigidas no trabalho.

| Código | Relatório | Tipo de consulta |
|---|---|---|
| RF11 | Listar as obras com o nome do cliente, do engenheiro responsável, da concessionária e da cidade. | Junção |
| RF12 | Listar os equipamentos instalados em cada obra, com o fabricante e o valor cobrado. | Junção |
| RF13 | Listar os clientes com a cidade onde moram e a quantidade de obras de cada um. | Junção |
| RF14 | Exibir a potência total instalada (kWp) por engenheiro. | Agrupamento |
| RF15 | Exibir o valor total vendido em cada mês. | Agrupamento |
| RF16 | Listar as concessionárias com mais de uma quantidade informada de obras. | Agrupamento com `HAVING` |
| RF17 | Exibir quantos dias cada obra levou para ser homologada. | Datas |
| RF18 | Listar as obras atrasadas (que passaram da data prevista e ainda não foram concluídas). | Datas |
| RF19 | Listar os equipamentos cuja garantia vence nos próximos meses. | Datas |
| RF20 | Listar as obras com valor de contrato acima da média da empresa. | Aninhada |
| RF21 | Listar os equipamentos do catálogo que nunca foram usados em nenhuma obra. | Aninhada |
| RF22 | Exibir a concessionária com o maior tempo médio de homologação. | Aninhada |

## Regras de negócio

| Código | Regra |
|---|---|
| RN01 | Não pode haver dois clientes com o mesmo CPF ou CNPJ. O documento do cliente deve ter 11 dígitos (CPF) ou 14 dígitos (CNPJ). |
| RN02 | Não pode haver dois engenheiros com o mesmo número de CREA. |
| RN03 | Um registro que está sendo usado não pode ser excluído. Por exemplo, um cliente ou engenheiro com obras, uma cidade usada em algum endereço, um fabricante com equipamentos ou um equipamento já usado em alguma obra. Ao excluir uma obra, os equipamentos registrados nela são excluídos junto. |
| RN04 | O tipo de ligação da obra deve ser monofásica, bifásica ou trifásica. |
| RN05 | O valor do contrato, o preço dos equipamentos, a quantidade e o valor unitário dos equipamentos da obra devem ser maiores que zero. |
| RN06 | A data de aprovação só pode ser informada se a data de protocolo também estiver, e não pode ser anterior a ela. A data de protocolo, a data prevista e a data de conclusão não podem ser anteriores à data do contrato. |
| RN07 | Ao adicionar um equipamento a uma obra, o sistema deve sugerir o preço atual do catálogo como valor unitário, mas permitir alterá-lo. Depois de salvo, esse valor não muda mesmo que o preço do catálogo mude. |
| RN08 | A potência da usina (kWp) não é digitada: ela é calculada como a soma de quantidade × potência dos módulos da obra, dividida por 1000. |
| RN09 | O tempo de homologação é o número de dias entre a data de protocolo e a data de aprovação. |
| RN10 | A garantia de um equipamento é contada a partir da data de conclusão da obra. |
| RN11 | Uma obra está atrasada quando a data atual já passou da data prevista e a data de conclusão ainda não foi preenchida. |
| RN12 | Toda pessoa cadastrada é cliente, engenheiro ou os dois. Os dados da pessoa são cadastrados uma só vez, mesmo que ela tenha os dois papéis. Ao excluir um cliente ou um engenheiro, os dados da pessoa só são excluídos se ela não tiver mais nenhum papel. |
| RN13 | Não pode haver duas cidades com o mesmo nome no mesmo estado. |

## Requisitos não funcionais

| Código | Categoria | Requisito |
|---|---|---|
| RNF01 | Tecnologia | O sistema deve ser desenvolvido em PHP puro (versão 8.2 ou superior), sem uso de frameworks. |
| RNF02 | Tecnologia | O banco de dados deve ser o MariaDB 10.4 (compatível com MySQL), acessado pela extensão `mysqli`. |
| RNF03 | Portabilidade | O sistema deve rodar no XAMPP, sem exigir a instalação de outros programas ou bibliotecas. |
| RNF04 | Arquitetura | O código deve ser organizado em camadas no padrão MVC (Modelos, Visões e Controladores). |
| RNF05 | Segurança | Todas as consultas que recebem dados do usuário devem usar prepared statements, para evitar SQL injection. |
| RNF06 | Segurança | Todo dado exibido nas telas deve ser escapado, para evitar a injeção de HTML ou JavaScript (XSS). |
| RNF07 | Segurança | As credenciais do banco de dados devem ficar no arquivo `.env`, fora do controle de versão. |
| RNF08 | Dados | O banco deve usar a codificação `utf8mb4`, para armazenar corretamente acentos e caracteres especiais. |
| RNF09 | Dados | O banco deve estar normalizado até a terceira forma normal (3FN) e garantir a integridade referencial com chaves estrangeiras. |
| RNF10 | Dados | O banco deve ser entregue povoado, com no mínimo 10 registros em cada tabela. |
| RNF11 | Usabilidade | A interface deve ser em português, com um menu que dê acesso a todos os cadastros e relatórios. |
| RNF12 | Usabilidade | O sistema deve mostrar mensagens claras de sucesso e de erro após cada operação, inclusive quando uma exclusão for bloqueada pela RN03. |
| RNF13 | Dados | As operações que gravam em mais de uma tabela ao mesmo tempo (como o cadastro de um cliente, que grava em `pessoa` e em `cliente`) devem usar transação, para que nada fique gravado pela metade em caso de erro. |

## Fora do escopo

Para manter o trabalho num tamanho viável, os itens abaixo **não** fazem parte do sistema:

- login e controle de acesso por tipo de usuário (os atores servem para organizar os requisitos, mas o sistema não restringe quem acessa cada tela);
- controle das equipes de instalação e dos colaboradores que vão a campo;
- acompanhamento detalhado de cada etapa da obra (vistoria, projeto, vistoria da concessionária etc.): o sistema registra apenas a homologação e a conclusão da instalação;
- emissão de documentos, como propostas comerciais, contratos e ART;
- dimensionamento técnico do sistema fotovoltaico (strings, cabeamento, proteções);
- acompanhamento da geração de energia depois da ligação.
