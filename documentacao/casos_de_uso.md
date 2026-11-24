# Casos de Uso: Gestão Fotovoltaica

Este documento descreve como cada ator usa o sistema. Os casos de uso foram levantados a partir dos [requisitos](requisitos.md), e cada um indica os requisitos funcionais (RF) e as regras de negócio (RN) que atende.

O diagrama está em [`casos_de_uso.puml`](casos_de_uso.puml), no formato PlantUML.

Nos casos de uso do tipo **"Manter"**, o ator pode **listar, inserir, editar e excluir** registros. São as quatro operações do CRUD.

## Atores

| Ator | Descrição |
|---|---|
| **Comercial** | Cadastra clientes e obras. |
| **Engenheiro** | Acompanha o andamento das etapas e registra os equipamentos das obras. |
| **Diretoria** | Mantém os cadastros de apoio e consulta os relatórios. |

## Lista de casos de uso

| Código | Caso de uso | Ator | Requisitos |
|---|---|---|---|
| UC01 | Manter clientes | Comercial | RF01 |
| UC02 | Manter obras | Comercial | RF09 |
| UC03 | Manter concessionárias | Diretoria | RF02 |
| UC04 | Manter engenheiros | Diretoria | RF03 |
| UC05 | Manter equipes de instalação | Diretoria | RF04 |
| UC06 | Manter colaboradores | Diretoria | RF05 |
| UC07 | Manter fabricantes | Diretoria | RF06 |
| UC08 | Manter equipamentos | Diretoria | RF07 |
| UC09 | Manter etapas | Diretoria | RF08 |
| UC10 | Registrar andamento das etapas | Engenheiro | RF10 |
| UC11 | Registrar equipamentos da obra | Engenheiro | RF11 |
| UC12 | Consultar detalhes da obra | Comercial, Engenheiro, Diretoria | RF13 |
| UC13 | Emitir relatórios | Diretoria | RF14 a RF25 |
| UC14 | Alocar equipes na obra | Engenheiro | RF12 |

Os casos de uso UC10, UC11 e UC14 partem da tela de detalhes da obra (UC12). No diagrama, eles aparecem como extensões (`<<extend>>`) do UC12.

## Descrição dos principais casos de uso

Os casos de uso UC03, UC04, UC07, UC08 e UC09 são cadastros simples e seguem o mesmo fluxo do UC01. Por isso, abaixo estão descritos apenas o UC01, que serve de modelo para os demais, e os casos de uso com regras mais importantes.

---

### UC01: Manter clientes

| | |
|---|---|
| **Ator** | Comercial |
| **Requisitos** | RF01, RN01, RN03 |
| **Pré-condição** | Nenhuma. |
| **Pós-condição** | O cadastro de clientes fica atualizado. |

**Fluxo principal (listar)**
1. O ator acessa o menu **Clientes**.
2. O sistema exibe a lista de clientes cadastrados, com as opções de inserir, editar e excluir.

**Fluxo alternativo A1: inserir cliente**
1. O ator clica em **Novo cliente**.
2. O sistema exibe o formulário em branco.
3. O ator preenche os dados e clica em **Salvar**.
4. O sistema valida os dados, grava o cliente e volta para a lista com uma mensagem de sucesso.

**Fluxo alternativo A2: editar cliente**
1. O ator clica em **Editar** em um cliente da lista.
2. O sistema exibe o formulário preenchido com os dados atuais.
3. O ator altera os dados e clica em **Salvar**.
4. O sistema valida os dados, grava as alterações e volta para a lista com uma mensagem de sucesso.

**Fluxo alternativo A3: excluir cliente**
1. O ator clica em **Excluir** em um cliente da lista.
2. O sistema pede uma confirmação.
3. O ator confirma.
4. O sistema exclui o cliente e volta para a lista com uma mensagem de sucesso.

**Fluxos de exceção**
- **E1, CPF/CNPJ já cadastrado (RN01):** em A1 ou A2, o sistema não grava e avisa que o documento já pertence a outro cliente.
- **E2, campo obrigatório vazio:** em A1 ou A2, o sistema não grava e indica o campo que precisa ser preenchido.
- **E3, cliente com obras (RN03):** em A3, o sistema não exclui e avisa que o cliente tem obras cadastradas.

---

### UC02: Manter obras

| | |
|---|---|
| **Ator** | Comercial |
| **Requisitos** | RF09, RN03, RN04, RN05 |
| **Pré-condição** | Devem existir clientes, engenheiros e concessionárias cadastrados. |
| **Pós-condição** | A obra fica cadastrada e pode ter suas etapas, equipes e equipamentos registrados. |

**Fluxo principal (listar)**
1. O ator acessa o menu **Obras**.
2. O sistema exibe a lista de obras com o cliente, o engenheiro, a concessionária e a data do contrato.

**Fluxo alternativo A1: inserir obra**
1. O ator clica em **Nova obra**.
2. O sistema exibe o formulário, com listas de seleção para cliente, engenheiro, concessionária e tipo de ligação.
3. O ator preenche os dados e clica em **Salvar**.
4. O sistema valida os dados, grava a obra e volta para a lista com uma mensagem de sucesso.

**Fluxo alternativo A2: editar obra**
Igual ao A2 do UC01, usando o formulário de obra.

**Fluxo alternativo A3: excluir obra**
Igual ao A3 do UC01.

**Fluxos de exceção**
- **E1, valor do contrato inválido (RN05):** em A1 ou A2, se o valor for zero ou negativo, o sistema não grava e avisa o erro.
- **E2, obra com etapas, equipes ou equipamentos registrados (RN03):** em A3, o sistema não exclui e avisa que a obra já tem registros ligados a ela.

---

### UC06: Manter colaboradores

| | |
|---|---|
| **Ator** | Diretoria |
| **Requisitos** | RF05, RN01, RN12, RN13 |
| **Pré-condição** | Deve existir pelo menos uma equipe de instalação cadastrada. |
| **Pós-condição** | O cadastro de colaboradores fica atualizado e todas as equipes com obras continuam completas. |

**Fluxo principal (listar)**
1. O ator acessa o menu **Colaboradores**.
2. O sistema exibe a lista de colaboradores com a função e a equipe de cada um.

**Fluxo alternativo A1: inserir colaborador**
1. O ator clica em **Novo colaborador**.
2. O sistema exibe o formulário, com a lista de equipes e as opções de função "instalador" e "ajudante".
3. O ator preenche os dados e clica em **Salvar**.
4. O sistema valida os dados, grava o colaborador e volta para a lista com uma mensagem de sucesso.

**Fluxo alternativo A2: editar colaborador**
Igual ao A2 do UC01, usando o formulário de colaborador.

**Fluxo alternativo A3: excluir colaborador**
Igual ao A3 do UC01.

**Fluxos de exceção**
- **E1, CPF já cadastrado (RN01):** em A1 ou A2, o sistema não grava e avisa que o CPF já pertence a outro colaborador.
- **E2, equipe ficaria incompleta (RN12):** em A2 ou A3, se o colaborador for o único instalador ou o único ajudante de uma equipe que tem obras, o sistema não permite trocar a equipe, alterar a função ou excluir. O sistema avisa que a equipe ficaria incompleta.

---

### UC10: Registrar andamento das etapas

| | |
|---|---|
| **Ator** | Engenheiro |
| **Requisitos** | RF10, RN06, RN09, RN11 |
| **Pré-condição** | A obra deve estar cadastrada e as etapas padrão devem existir. |
| **Pós-condição** | As datas das etapas da obra ficam atualizadas. |

**Fluxo principal**
1. O ator abre os detalhes de uma obra (UC12) e clica em **Etapas**.
2. O sistema exibe todas as etapas padrão, na ordem, com a data prevista, a data de início e a data de conclusão de cada uma. As etapas atrasadas aparecem destacadas (RN11).
3. O ator preenche ou altera as datas de uma etapa e clica em **Salvar**.
4. O sistema valida as datas, grava o andamento e exibe uma mensagem de sucesso.

**Fluxos de exceção**
- **E1, datas inconsistentes (RN06):** no passo 4, se a data de conclusão for anterior à data de início, o sistema não grava e avisa o erro.

---

### UC11: Registrar equipamentos da obra

| | |
|---|---|
| **Ator** | Engenheiro |
| **Requisitos** | RF11, RN05, RN07 |
| **Pré-condição** | A obra e os equipamentos devem estar cadastrados. |
| **Pós-condição** | Os equipamentos da obra ficam registrados e a potência da obra (kWp) é recalculada. |

**Fluxo principal**
1. O ator abre os detalhes de uma obra (UC12) e clica em **Equipamentos**.
2. O sistema exibe os equipamentos já registrados na obra e um formulário para adicionar um novo.
3. O ator seleciona um equipamento.
4. O sistema preenche o valor unitário com o preço atual do catálogo (RN07).
5. O ator informa a quantidade, altera o valor unitário se quiser e clica em **Adicionar**.
6. O sistema valida e grava o equipamento na obra, atualiza a lista e exibe uma mensagem de sucesso.

**Fluxo alternativo A1: remover equipamento da obra**
1. O ator clica em **Remover** em um equipamento da lista.
2. O sistema pede uma confirmação.
3. O ator confirma.
4. O sistema remove o equipamento da obra e atualiza a lista.

**Fluxos de exceção**
- **E1, quantidade ou valor inválido (RN05):** no passo 6, se a quantidade ou o valor unitário for zero ou negativo, o sistema não grava e avisa o erro.

---

### UC14: Alocar equipes na obra

| | |
|---|---|
| **Ator** | Engenheiro |
| **Requisitos** | RF12, RN14, RN15 |
| **Pré-condição** | A obra deve estar cadastrada e deve existir pelo menos uma equipe completa. |
| **Pós-condição** | A obra fica com as equipes de instalação que vão executá-la. |

**Fluxo principal**
1. O ator abre os detalhes de uma obra (UC12) e clica em **Equipes**.
2. O sistema exibe as equipes já alocadas na obra, com seus membros, e uma lista das equipes que podem ser adicionadas.
3. O ator seleciona uma equipe e clica em **Alocar**.
4. O sistema valida a equipe, grava a alocação, atualiza a lista e exibe uma mensagem de sucesso.

**Fluxo alternativo A1: remover equipe da obra**
1. O ator clica em **Remover** em uma equipe alocada.
2. O sistema pede uma confirmação.
3. O ator confirma.
4. O sistema remove a equipe da obra e atualiza a lista.

**Fluxos de exceção**
- **E1, equipe incompleta (RN14):** no passo 4, se a equipe não tiver pelo menos um instalador e um ajudante, o sistema não grava e avisa que a equipe está incompleta.
- **E2, equipe já alocada (RN15):** no passo 4, se a equipe já estiver alocada nessa obra, o sistema não grava e avisa que ela já faz parte da obra.

---

### UC12: Consultar detalhes da obra

| | |
|---|---|
| **Ator** | Comercial, Engenheiro, Diretoria |
| **Requisitos** | RF13, RN08 |
| **Pré-condição** | A obra deve estar cadastrada. |
| **Pós-condição** | Nenhuma (apenas consulta). |

**Fluxo principal**
1. O ator clica em uma obra na lista de obras.
2. O sistema exibe os dados da obra, o cliente, o engenheiro, as equipes alocadas com seus membros, a concessionária e a **potência total da usina em kWp**, calculada a partir dos módulos registrados (RN08).
3. O sistema exibe os atalhos para **Etapas** (UC10), **Equipamentos** (UC11) e **Equipes** (UC14).

---

### UC13: Emitir relatórios

| | |
|---|---|
| **Ator** | Diretoria |
| **Requisitos** | RF14 a RF25 |
| **Pré-condição** | O banco de dados deve ter dados cadastrados. |
| **Pós-condição** | Nenhuma (apenas consulta). |

**Fluxo principal**
1. O ator acessa o menu **Relatórios**.
2. O sistema exibe a lista dos relatórios disponíveis, cada um com uma frase explicando o que ele mostra.
3. O ator escolhe um relatório.
4. O sistema executa a consulta e exibe o resultado em uma tabela.

**Fluxo alternativo A1: relatório com parâmetro**
1. No passo 3, se o relatório precisar de um valor informado pelo ator (a quantidade mínima de obras no RF19 ou o número de meses no RF22), o sistema exibe um campo para esse valor.
2. O ator informa o valor e clica em **Gerar**.
3. O sistema executa a consulta com o valor informado e exibe o resultado.

**Fluxos de exceção**
- **E1, nenhum resultado:** no passo 4, se a consulta não retornar nenhuma linha, o sistema exibe a mensagem "Nenhum registro encontrado" em vez de uma tabela vazia.
- **E2, parâmetro inválido:** em A1, se o valor informado não for um número inteiro positivo, o sistema não executa a consulta e avisa o erro.
