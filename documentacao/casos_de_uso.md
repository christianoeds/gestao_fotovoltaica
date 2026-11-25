# Casos de Uso: Gestão Fotovoltaica

Este documento descreve como cada ator usa o sistema. Os casos de uso foram levantados a partir dos [requisitos](requisitos.md), e cada um indica os requisitos funcionais (RF) e as regras de negócio (RN) que atende.

O diagrama está em [`casos_de_uso.puml`](casos_de_uso.puml), no formato PlantUML.

Nos casos de uso do tipo **"Manter"**, o ator pode **listar, inserir, editar e excluir** registros. São as quatro operações do CRUD.

## Atores

| Ator | Descrição |
|---|---|
| **Comercial** | Cadastra clientes e obras. |
| **Engenheiro** | Registra o andamento das obras e os equipamentos usados. |
| **Diretoria** | Mantém os cadastros de apoio e consulta os relatórios. |

## Lista de casos de uso

| Código | Caso de uso | Ator | Requisitos |
|---|---|---|---|
| UC01 | Manter clientes | Comercial | RF01 |
| UC02 | Manter obras | Comercial | RF07 |
| UC03 | Manter engenheiros | Diretoria | RF02 |
| UC04 | Manter cidades | Diretoria | RF03 |
| UC05 | Manter concessionárias | Diretoria | RF04 |
| UC06 | Manter fabricantes | Diretoria | RF05 |
| UC07 | Manter equipamentos | Diretoria | RF06 |
| UC08 | Registrar andamento da obra | Engenheiro | RF08 |
| UC09 | Registrar equipamentos da obra | Engenheiro | RF09 |
| UC10 | Consultar detalhes da obra | Comercial, Engenheiro, Diretoria | RF10 |
| UC11 | Emitir relatórios | Diretoria | RF11 a RF22 |

Os casos de uso UC08 e UC09 partem da tela de detalhes da obra (UC10). No diagrama, eles aparecem como extensões (`<<extend>>`) do UC10.

## Descrição dos principais casos de uso

Os casos de uso UC04, UC05, UC06 e UC07 são cadastros simples e seguem o mesmo fluxo do UC01. O UC03 (engenheiros) também é igual ao UC01, trocando o CPF/CNPJ pelo CREA. Por isso, abaixo estão descritos apenas o UC01, que serve de modelo para os demais, e os casos de uso com regras mais importantes.

---

### UC01: Manter clientes

| | |
|---|---|
| **Ator** | Comercial |
| **Requisitos** | RF01, RN01, RN03, RN12 |
| **Pré-condição** | Deve existir pelo menos uma cidade cadastrada. |
| **Pós-condição** | O cadastro de clientes fica atualizado. |

**Fluxo principal (listar)**
1. O ator acessa o menu **Clientes**.
2. O sistema exibe a lista de clientes cadastrados, com a cidade de cada um e as opções de inserir, editar e excluir.

**Fluxo alternativo A1: inserir cliente**
1. O ator clica em **Novo cliente**.
2. O sistema exibe o formulário em branco, com os campos nome, CPF ou CNPJ, telefone, e-mail, endereço e uma lista de seleção de cidades.
3. O ator preenche os dados e clica em **Salvar**.
4. O sistema valida os dados, grava o cliente de uma só vez (dados de pessoa e de cliente, numa transação) e volta para a lista com uma mensagem de sucesso.

**Fluxo alternativo A2: editar cliente**
1. O ator clica em **Editar** em um cliente da lista.
2. O sistema exibe o formulário preenchido com os dados atuais.
3. O ator altera os dados e clica em **Salvar**.
4. O sistema valida os dados, grava as alterações e volta para a lista com uma mensagem de sucesso.

**Fluxo alternativo A3: excluir cliente**
1. O ator clica em **Excluir** em um cliente da lista.
2. O sistema pede uma confirmação.
3. O ator confirma.
4. O sistema exclui o cliente (e os dados de pessoa dele) e volta para a lista com uma mensagem de sucesso.

**Fluxos de exceção**
- **E1, CPF/CNPJ já cadastrado ou inválido (RN01):** em A1 ou A2, se o documento já pertencer a outro cliente ou não tiver 11 dígitos (CPF) nem 14 dígitos (CNPJ), o sistema não grava e avisa o erro.
- **E2, campo obrigatório vazio:** em A1 ou A2, o sistema não grava e indica o campo que precisa ser preenchido.
- **E3, cliente com obras (RN03):** em A3, o sistema não exclui e avisa que o cliente tem obras cadastradas.

---

### UC02: Manter obras

| | |
|---|---|
| **Ator** | Comercial |
| **Requisitos** | RF07, RN03, RN04, RN05, RN06 |
| **Pré-condição** | Devem existir clientes, engenheiros, concessionárias e cidades cadastrados. |
| **Pós-condição** | A obra fica cadastrada e pode ter seu andamento e seus equipamentos registrados. |

**Fluxo principal (listar)**
1. O ator acessa o menu **Obras**.
2. O sistema exibe a lista de obras com o cliente, o engenheiro, a concessionária, a cidade e a data do contrato.

**Fluxo alternativo A1: inserir obra**
1. O ator clica em **Nova obra**.
2. O sistema exibe o formulário, com listas de seleção para cliente, engenheiro, concessionária, cidade e tipo de ligação.
3. O ator preenche os dados, incluindo a data prevista de conclusão, e clica em **Salvar**.
4. O sistema valida os dados, grava a obra e volta para a lista com uma mensagem de sucesso.

**Fluxo alternativo A2: editar obra**
Igual ao A2 do UC01, usando o formulário de obra.

**Fluxo alternativo A3: excluir obra**
1. O ator clica em **Excluir** em uma obra da lista.
2. O sistema pede uma confirmação, avisando que os equipamentos registrados na obra também serão excluídos (RN03).
3. O ator confirma.
4. O sistema exclui a obra e os equipamentos dela e volta para a lista com uma mensagem de sucesso.

**Fluxos de exceção**
- **E1, valor do contrato inválido (RN05):** em A1 ou A2, se o valor for zero ou negativo, o sistema não grava e avisa o erro.
- **E2, data prevista inválida (RN06):** em A1 ou A2, se a data prevista for anterior à data do contrato, o sistema não grava e avisa o erro.

---

### UC08: Registrar andamento da obra

| | |
|---|---|
| **Ator** | Engenheiro |
| **Requisitos** | RF08, RN06, RN09, RN11 |
| **Pré-condição** | A obra deve estar cadastrada. |
| **Pós-condição** | As datas de homologação e de conclusão da obra ficam atualizadas. |

**Fluxo principal**
1. O ator abre os detalhes de uma obra (UC10) e clica em **Andamento**.
2. O sistema exibe a data do contrato, a data prevista e os campos de data de protocolo, data de aprovação e data de conclusão. Se a obra estiver atrasada, o sistema mostra um aviso (RN11).
3. O ator preenche as datas que já aconteceram e clica em **Salvar**.
4. O sistema valida as datas, grava o andamento e exibe uma mensagem de sucesso. Se a homologação já foi aprovada, o sistema mostra quantos dias ela levou (RN09).

**Fluxos de exceção**
- **E1, datas inconsistentes (RN06):** no passo 4, se a data de aprovação for informada sem a data de protocolo, se for anterior a ela, ou se alguma data for anterior à data do contrato, o sistema não grava e avisa o erro.

---

### UC09: Registrar equipamentos da obra

| | |
|---|---|
| **Ator** | Engenheiro |
| **Requisitos** | RF09, RN05, RN07 |
| **Pré-condição** | A obra e os equipamentos devem estar cadastrados. |
| **Pós-condição** | Os equipamentos da obra ficam registrados e a potência da obra (kWp) é recalculada. |

**Fluxo principal**
1. O ator abre os detalhes de uma obra (UC10) e clica em **Equipamentos**.
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
- **E2, equipamento já registrado:** no passo 6, se o equipamento já estiver na obra, o sistema não grava e sugere editar a quantidade do registro existente.

---

### UC10: Consultar detalhes da obra

| | |
|---|---|
| **Ator** | Comercial, Engenheiro, Diretoria |
| **Requisitos** | RF10, RN08 |
| **Pré-condição** | A obra deve estar cadastrada. |
| **Pós-condição** | Nenhuma (apenas consulta). |

**Fluxo principal**
1. O ator clica em uma obra na lista de obras.
2. O sistema exibe os dados da obra, o cliente, o engenheiro, a concessionária, as datas do andamento e a **potência total da usina em kWp**, calculada a partir dos módulos registrados (RN08).
3. O sistema exibe os atalhos para **Andamento** (UC08) e **Equipamentos** (UC09).

---

### UC11: Emitir relatórios

| | |
|---|---|
| **Ator** | Diretoria |
| **Requisitos** | RF11 a RF22 |
| **Pré-condição** | O banco de dados deve ter dados cadastrados. |
| **Pós-condição** | Nenhuma (apenas consulta). |

**Fluxo principal**
1. O ator acessa o menu **Relatórios**.
2. O sistema exibe a lista dos relatórios disponíveis, cada um com uma frase explicando o que ele mostra.
3. O ator escolhe um relatório.
4. O sistema executa a consulta e exibe o resultado em uma tabela.

**Fluxo alternativo A1: relatório com parâmetro**
1. No passo 3, se o relatório precisar de um valor informado pelo ator (a quantidade mínima de obras no RF16 ou o número de meses no RF19), o sistema exibe um campo para esse valor.
2. O ator informa o valor e clica em **Gerar**.
3. O sistema executa a consulta com o valor informado e exibe o resultado.

**Fluxos de exceção**
- **E1, nenhum resultado:** no passo 4, se a consulta não retornar nenhuma linha, o sistema exibe a mensagem "Nenhum registro encontrado" em vez de uma tabela vazia.
- **E2, parâmetro inválido:** em A1, se o valor informado não for um número inteiro positivo, o sistema não executa a consulta e avisa o erro.
