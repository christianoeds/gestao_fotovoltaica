# Briefing: Derivar Energia Solar

## Sobre a empresa

A **Derivar** é uma empresa integradora de energia solar. Ela vende, projeta e instala sistemas fotovoltaicos conectados à rede, principalmente em casas, comércios e pequenas indústrias. Os engenheiros eletricistas da empresa assinam os projetos e acompanham as obras.

Cada venda vira uma **obra**. Depois da assinatura do contrato, o engenheiro faz o projeto e pede a **homologação** na concessionária de energia, que precisa aprovar a conexão da usina à rede. Em paralelo, a obra é **instalada**. Quando a instalação termina, começa a contar a garantia dos equipamentos.

## Qual é o problema?

Hoje o acompanhamento das obras é feito em planilhas e grupos de WhatsApp. Isso causa vários problemas:

- ninguém sabe com certeza quais obras estão atrasadas;
- a homologação depende da concessionária e às vezes demora muito, mas a empresa não tem números para saber qual concessionária costuma atrasar mais;
- não existe um registro organizado de quais equipamentos foram instalados em cada cliente, então fica difícil saber quando a garantia de um inversor está acabando;
- no fim do mês, a diretoria precisa montar na mão quanto foi vendido e quantos kWp foram instalados.

A ideia é ter um sistema simples, que rode no navegador, para centralizar esses dados e gerar relatórios.

## Quem vai usar o sistema

- **Comercial / administrativo:** cadastra clientes e obras e registra o valor do contrato.
- **Engenheiro:** registra o andamento das obras pelas quais é responsável (homologação e conclusão) e os equipamentos usados.
- **Diretoria (administrador):** cadastra engenheiros, cidades, concessionárias, fabricantes e equipamentos, e acompanha os relatórios.

## O que a empresa precisa guardar

**Cidades:** as cidades onde moram os clientes e engenheiros e onde ficam as obras, com o nome e o estado (UF).

**Pessoas:** clientes e engenheiros têm dados em comum: nome, telefone, e-mail e endereço (rua, número, bairro e cidade). Uma pessoa pode ser cliente, engenheiro ou os dois ao mesmo tempo: por exemplo, um engenheiro da Derivar que instala uma usina na própria casa. Nesse caso, os dados dela são cadastrados uma só vez.

**Clientes:** quem contrata a obra. Pode ser pessoa física ou jurídica. Além dos dados comuns de pessoa, guardamos um único documento: o **CPF**, se for pessoa física, ou o **CNPJ**, se for empresa. Para empresas, o nome guardado é o nome usado no dia a dia. Um cliente pode ter várias obras, por exemplo uma na casa e outra no comércio.

**Engenheiros:** além dos dados comuns de pessoa, guardamos o número do CREA. Cada obra tem um engenheiro responsável.

**Concessionárias:** as distribuidoras de energia que aprovam a conexão do sistema à rede. Guardamos o nome, a sigla e o estado onde atuam.

**Obras:** cada obra pertence a um cliente, tem um engenheiro responsável e é ligada a uma concessionária. Guardamos:
- o número da unidade consumidora (UC) e o endereço da instalação, que pode ser diferente do endereço do cliente;
- o tipo de ligação (monofásica, bifásica ou trifásica);
- a data de assinatura e o valor do contrato;
- a **data de protocolo** do pedido de homologação na concessionária e a **data de aprovação**;
- a **data prevista** para concluir a instalação e a **data em que ela foi concluída**.

As datas de protocolo, aprovação e conclusão ficam em branco até que cada coisa aconteça.

**Fabricantes:** as marcas dos equipamentos, com nome e país de origem.

**Equipamentos:** o catálogo do que a empresa instala: módulos fotovoltaicos, inversores, estruturas de fixação etc. Para cada um guardamos o tipo, o modelo, o fabricante, a potência (em watts, quando se aplica), o preço atual e o tempo de garantia em anos.

**Equipamentos da obra:** quais equipamentos foram usados em cada obra, com a quantidade e o **valor unitário cobrado naquela obra**. O preço do catálogo muda com o tempo (e muda bastante no mercado solar), e o histórico das obras antigas não pode mudar junto.

A **potência da usina (kWp) não é digitada**. Ela é calculada pela soma dos módulos instalados (quantidade × potência de cada módulo). Assim ela nunca fica diferente dos equipamentos registrados.

## Relatórios que a diretoria quer ver

- Uma lista das obras mostrando o cliente, o engenheiro responsável, a concessionária e a cidade.
- Os equipamentos instalados em cada obra, com o fabricante e o valor cobrado.
- Os clientes com a cidade onde moram e quantas obras cada um contratou.
- A potência total instalada (kWp) por engenheiro.
- O valor total vendido em cada mês.
- As concessionárias que têm mais de um certo número de obras.
- O tempo que cada obra levou para ser homologada, em dias, para comparar as concessionárias.
- As obras atrasadas, ou seja, que passaram da data prevista e ainda não foram concluídas.
- Os equipamentos com a garantia vencendo nos próximos meses, para a empresa entrar em contato com o cliente.
- As obras com valor de contrato acima da média da empresa.
- Os equipamentos do catálogo que nunca foram usados em nenhuma obra.
- A concessionária com o maior tempo médio de homologação.

## O que se espera do sistema

- Funcionar no navegador, sem precisar instalar nada além do XAMPP.
- Permitir cadastrar, listar, editar e excluir todos os dados acima.
- Mostrar os relatórios em telas fáceis de ler.
- Não deixar excluir um registro que está sendo usado. Por exemplo, um cliente com obras cadastradas ou um equipamento que já foi usado em alguma obra não pode ser apagado.
