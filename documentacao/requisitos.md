# Requisitos do Sistema: Gestão Fotovoltaica

Este documento lista o que o sistema deve fazer (requisitos funcionais), as regras de negócio que ele deve respeitar e as características técnicas que ele deve ter (requisitos não funcionais). Tudo foi levantado a partir do [briefing](briefing.md).

## Atores

| Ator | Descrição |
|---|---|
| **Comercial** | Cadastra clientes e obras e registra o valor do contrato. |
| **Engenheiro** | Acompanha as etapas das obras, aloca as equipes de instalação e registra os equipamentos usados em cada obra. |
| **Diretoria** | Mantém os cadastros de apoio (engenheiros, equipes de instalação, colaboradores, concessionárias, fabricantes, equipamentos e etapas) e consulta os relatórios. |

## Requisitos funcionais

### Cadastros

Em todos os cadastros abaixo, "manter" significa **inserir, listar, editar e excluir** registros.

| Código | Requisito | Ator |
|---|---|---|
| RF01 | O sistema deve permitir manter **clientes** (nome ou razão social, CPF ou CNPJ, telefone, e-mail e cidade). | Comercial |
| RF02 | O sistema deve permitir manter **concessionárias** (nome, sigla e estado). | Diretoria |
| RF03 | O sistema deve permitir manter **engenheiros** (nome, CREA, telefone e e-mail). | Diretoria |
| RF04 | O sistema deve permitir manter **equipes de instalação** (nome da equipe). | Diretoria |
| RF05 | O sistema deve permitir manter **colaboradores** (nome, CPF, telefone, função e equipe). | Diretoria |
| RF06 | O sistema deve permitir manter **fabricantes** (nome e país de origem). | Diretoria |
| RF07 | O sistema deve permitir manter **equipamentos** (tipo, modelo, fabricante, potência, preço atual e garantia em anos). | Diretoria |
| RF08 | O sistema deve permitir manter as **etapas** padrão das obras (nome e ordem). | Diretoria |
| RF09 | O sistema deve permitir manter **obras** (cliente, engenheiro responsável, concessionária, número da UC, endereço da instalação, tipo de ligação, data do contrato e valor do contrato). | Comercial |

### Acompanhamento da obra

| Código | Requisito | Ator |
|---|---|---|
| RF10 | O sistema deve permitir registrar o **andamento de cada etapa** de uma obra, informando a data prevista, a data de início e a data de conclusão. | Engenheiro |
| RF11 | O sistema deve permitir registrar os **equipamentos usados em uma obra**, com a quantidade e o valor unitário cobrado. | Engenheiro |
| RF12 | O sistema deve permitir **alocar uma ou mais equipes de instalação em uma obra** e remover equipes alocadas. | Engenheiro |
| RF13 | O sistema deve exibir, na tela de detalhes da obra, a **potência total da usina em kWp**, calculada a partir dos módulos registrados. | Todos |

### Relatórios

Cada relatório corresponde a uma das consultas SQL exigidas no trabalho.

| Código | Relatório | Tipo de consulta |
|---|---|---|
| RF14 | Listar as obras com o nome do cliente, do engenheiro responsável e da concessionária. | Junção |
| RF15 | Listar os equipamentos instalados em cada obra, com o fabricante e o valor cobrado. | Junção |
| RF16 | Listar o andamento das etapas de cada obra, indicando as concluídas e as pendentes. | Junção |
| RF17 | Exibir a potência total instalada (kWp) por engenheiro. | Agrupamento |
| RF18 | Exibir o valor total vendido em cada mês. | Agrupamento |
| RF19 | Listar as concessionárias com mais de uma quantidade informada de obras. | Agrupamento com `HAVING` |
| RF20 | Exibir quantos dias cada obra levou para ser homologada. | Datas |
| RF21 | Listar as etapas atrasadas (que passaram da data prevista e ainda não foram concluídas). | Datas |
| RF22 | Listar os equipamentos cuja garantia vence nos próximos meses. | Datas |
| RF23 | Listar as obras com potência acima da média da empresa. | Aninhada |
| RF24 | Listar os equipamentos do catálogo que nunca foram usados em nenhuma obra. | Aninhada |
| RF25 | Exibir a concessionária com o maior tempo médio de homologação. | Aninhada |

## Regras de negócio

| Código | Regra |
|---|---|
| RN01 | Não pode haver dois clientes com o mesmo CPF ou CNPJ, nem dois colaboradores com o mesmo CPF. |
| RN02 | Não pode haver dois engenheiros com o mesmo número de CREA. |
| RN03 | Um registro que está sendo usado não pode ser excluído. Por exemplo, um cliente com obras, um engenheiro responsável por alguma obra, uma equipe com obras ou um equipamento já usado em alguma obra. |
| RN04 | O tipo de ligação da obra deve ser monofásica, bifásica ou trifásica. |
| RN05 | O valor do contrato, a quantidade e o valor unitário dos equipamentos devem ser maiores que zero. |
| RN06 | A data de conclusão de uma etapa não pode ser anterior à data de início. |
| RN07 | Ao adicionar um equipamento a uma obra, o sistema deve sugerir o preço atual do catálogo como valor unitário, mas permitir alterá-lo. Depois de salvo, esse valor não muda mesmo que o preço do catálogo mude. |
| RN08 | A potência da usina (kWp) não é digitada: ela é calculada como a soma de quantidade × potência dos módulos da obra, dividida por 1000. |
| RN09 | O tempo de homologação é contado da data de início (protocolo na concessionária) até a data de conclusão (aprovação) da etapa de homologação. |
| RN10 | A garantia de um equipamento é contada a partir da data de conclusão da etapa de instalação da obra. |
| RN11 | Uma etapa é considerada atrasada quando a data atual já passou da data prevista e a data de conclusão ainda não foi preenchida. |
| RN12 | Cada equipe de instalação deve ter **no mínimo um instalador (eletricista) e um ajudante**. Não há limite máximo de membros. O sistema não deve permitir excluir um colaborador, trocá-lo de equipe ou alterar sua função se ele for o único instalador ou o único ajudante de uma equipe que tem obras. |
| RN13 | Cada colaborador pertence a uma única equipe, e sua função deve ser "instalador" ou "ajudante". |
| RN14 | Uma equipe só pode ser alocada em uma obra se estiver completa, ou seja, com pelo menos um instalador e pelo menos um ajudante. |
| RN15 | Uma obra pode ter várias equipes alocadas, mas a mesma equipe não pode ser alocada duas vezes na mesma obra. |

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

## Fora do escopo

Para manter o trabalho num tamanho viável, os itens abaixo **não** fazem parte do sistema:

- login e controle de acesso por tipo de usuário (os atores servem para organizar os requisitos, mas o sistema não restringe quem acessa cada tela);
- emissão de documentos, como propostas comerciais, contratos e ART;
- dimensionamento técnico do sistema fotovoltaico (strings, cabeamento, proteções);
- acompanhamento da geração de energia depois da ligação.
