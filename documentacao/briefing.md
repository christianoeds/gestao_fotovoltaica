# Briefing: Derivar Energia Solar

## Sobre a empresa

A **Derivar** é uma empresa integradora de energia solar. Ela vende, projeta e instala sistemas fotovoltaicos conectados à rede, principalmente em casas, comércios e pequenas indústrias. A equipe tem alguns engenheiros eletricistas, que assinam os projetos e acompanham as obras, e equipes de instalação que vão a campo montar os sistemas.

Cada venda vira uma **obra**, que passa por várias etapas até o sistema começar a gerar energia: vistoria técnica no local, elaboração do projeto, pedido de homologação na concessionária, instalação, vistoria da concessionária e, por fim, a troca do medidor e a ligação do sistema.

## Qual é o problema?

Hoje o acompanhamento das obras é feito em planilhas e grupos de WhatsApp. Isso causa vários problemas:

- ninguém sabe com certeza em que etapa cada obra está, nem quais estão atrasadas;
- a homologação depende da concessionária e às vezes demora muito, mas a empresa não tem números para saber qual concessionária costuma atrasar mais;
- não existe um registro organizado de quais equipamentos foram instalados em cada cliente, então fica difícil saber quando a garantia de um inversor está acabando;
- no fim do mês, a diretoria precisa montar na mão quanto foi vendido e quantos kWp foram instalados.

A ideia é ter um sistema simples, que rode no navegador, para centralizar esses dados e gerar relatórios.

## Quem vai usar o sistema

- **Comercial / administrativo:** cadastra clientes e obras e registra o valor do contrato.
- **Engenheiro:** acompanha as etapas das obras pelas quais é responsável e registra os equipamentos usados.
- **Diretoria (administrador):** cadastra engenheiros, equipes de instalação, equipamentos e concessionárias, e acompanha os relatórios.

## O que a empresa precisa guardar

**Clientes:** quem contrata a obra. Pode ser pessoa física ou jurídica, então guardamos nome ou razão social, CPF ou CNPJ, telefone, e-mail e cidade. Um cliente pode ter várias obras, por exemplo uma na casa e outra no comércio.

**Concessionárias:** as distribuidoras de energia que aprovam a conexão do sistema à rede. Guardamos o nome, a sigla e o estado onde atuam.

**Engenheiros:** nome, número do CREA, telefone e e-mail. Cada obra tem um engenheiro responsável.

**Equipes de instalação:** a Derivar trabalha com equipes fixas. Cada equipe tem **no mínimo** um instalador (eletricista) e um ajudante. Equipes que atendem obras maiores podem ter mais instaladores e mais ajudantes. Para cada equipe guardamos um nome que a identifique (por exemplo, "Equipe 01").

**Colaboradores:** as pessoas que fazem parte das equipes. Guardamos nome, CPF, telefone, função (instalador ou ajudante) e a equipe a que pertencem. Cada colaborador faz parte de uma única equipe.

**Obras:** cada obra pertence a um cliente, tem um engenheiro responsável, é ligada a uma concessionária e é executada por uma ou mais equipes de instalação. Obras pequenas normalmente têm uma só equipe, mas usinas maiores precisam de várias equipes trabalhando juntas. As equipes são definidas depois do projeto e da homologação, quando a obra está perto de ir a campo. Uma mesma equipe faz várias obras ao longo do tempo. Guardamos o número da unidade consumidora (UC), o endereço da instalação, o tipo de ligação (monofásica, bifásica ou trifásica), a data de assinatura do contrato e o valor do contrato.

**Etapas:** a lista padrão de etapas que toda obra percorre (vistoria técnica, projeto, homologação, instalação, vistoria da concessionária, ligação), em ordem.

**Andamento das etapas:** para cada obra e cada etapa, registramos a **data prevista**, a **data de início** e a **data de conclusão**. Na homologação, por exemplo, a data de início é o dia do protocolo na concessionária, e a data de conclusão é o dia da aprovação.

**Fabricantes:** as marcas dos equipamentos, com nome e país de origem.

**Equipamentos:** o catálogo do que a empresa instala: módulos fotovoltaicos, inversores, estruturas de fixação etc. Para cada um guardamos o tipo, o modelo, o fabricante, a potência (em watts, quando se aplica), o preço atual e o tempo de garantia em anos.

**Equipamentos da obra:** quais equipamentos foram usados em cada obra, com a quantidade e o **valor unitário cobrado naquela obra**. O preço do catálogo muda com o tempo (e muda bastante no mercado solar), e o histórico das obras antigas não pode mudar junto.

A **potência da usina (kWp) não é digitada**. Ela é calculada pela soma dos módulos instalados (quantidade × potência de cada módulo). Assim ela nunca fica diferente dos equipamentos registrados.

## Relatórios que a diretoria quer ver

- Uma lista das obras mostrando o cliente, o engenheiro responsável e a concessionária.
- Os equipamentos instalados em cada obra, com o fabricante e o valor cobrado.
- O andamento das etapas de cada obra, mostrando o que já foi concluído e o que está pendente.
- A potência total instalada (kWp) por engenheiro.
- O valor total vendido em cada mês.
- As concessionárias que têm mais de um certo número de obras.
- O tempo que cada obra levou para ser homologada, em dias, para comparar as concessionárias.
- As etapas que estão atrasadas, ou seja, que passaram da data prevista e ainda não foram concluídas.
- Os equipamentos com a garantia vencendo nos próximos meses, para a empresa entrar em contato com o cliente.
- As obras com potência acima da média da empresa.
- Os equipamentos do catálogo que nunca foram usados em nenhuma obra.
- A concessionária com o maior tempo médio de homologação.

## O que se espera do sistema

- Funcionar no navegador, sem precisar instalar nada além do XAMPP.
- Permitir cadastrar, listar, editar e excluir todos os dados acima.
- Mostrar os relatórios em telas fáceis de ler.
- Não deixar excluir um registro que está sendo usado. Por exemplo, um cliente com obras cadastradas ou um equipamento que já foi usado em alguma obra não pode ser apagado.
