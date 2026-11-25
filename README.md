# Gestão Fotovoltaica

Sistema web para gerenciamento de obras de instalação de usinas solares fotovoltaicas, desenvolvido como trabalho final da disciplina de Banco de Dados. Permite cadastrar clientes, engenheiros, cidades, concessionárias, fabricantes, equipamentos e obras, acompanhar a homologação e a conclusão de cada obra e emitir relatórios a partir de consultas SQL.

O sistema foi feito em **PHP puro, sem frameworks**, organizado em camadas no padrão **MVC** (Modelo, Visão e Controlador).

## Integrantes

- Christiano Eduardo Dutra e Silva

## Tecnologias

| Tecnologia | Versão |
|---|---|
| PHP | 8.2 ou superior |
| MariaDB | 10.4 (a que vem no XAMPP) |
| Servidor | Apache, via XAMPP |
| Acesso ao banco | mysqli (extensão `mysqli`) |

## Requisitos do trabalho

| Requisito | Onde encontrar |
|---|---|
| Requisitos, casos de uso, modelagem conceitual e lógica, dicionário de dados | `documentacao/` |
| Banco de dados físico | `banco_de_dados/01_estrutura.sql` |
| Povoamento (mínimo de 10 registros por tabela) | `banco_de_dados/02_povoamento.sql` |
| 12 consultas (3 com junção, 3 com agrupamento, 3 com datas, 3 aninhadas) | `banco_de_dados/03_consultas.sql` e menu **Relatórios** do sistema |
| CRUD (inserção, listagem, atualização e exclusão) | Menus de cadastro do sistema |

## Estrutura de pastas

```
gestao_fotovoltaica/
├── aplicacao/
│   ├── Controladores/      → recebem as requisições e decidem o que exibir
│   ├── Modelos/            → acesso ao banco de dados (todo o SQL fica aqui)
│   ├── Nucleo/             → conexão com o banco, roteamento e classes base
│   └── Visoes/             → telas em HTML
│       ├── comum/          → cabeçalho, menu e rodapé
│       └── relatorios/     → telas dos relatórios
├── banco_de_dados/         → scripts SQL de estrutura, povoamento e consultas
├── configuracao/           → leitura das configurações do arquivo .env
├── documentacao/           → documentação do projeto
├── publico/                → ponto de entrada do sistema (index.php), CSS e JS
├── .env.example            → modelo do arquivo de configuração
└── README.md
```

## Como executar no XAMPP

1. **Copie o projeto** para a pasta `htdocs` do XAMPP (por exemplo, `C:\xampp\htdocs\gestao_fotovoltaica`).
2. **Inicie o Apache e o MySQL** pelo painel de controle do XAMPP.
3. **Crie o banco de dados** executando os arquivos da pasta `banco_de_dados/` **nesta ordem**:
   1. `01_estrutura.sql` (cria o banco `gestao_fotovoltaica` e as tabelas)
   2. `02_povoamento.sql` (insere os dados de exemplo)

   Escolha uma das opções abaixo.

   **Opção A: MySQL Workbench**
   1. Crie uma conexão com host `localhost`, porta `3306` e usuário `root`, sem senha. Depois abra a conexão.
   2. abra o `01_estrutura.sql` e execute.
   3. abra o `02_povoamento.sql` e execute.

   **Opção B: phpMyAdmin**
   1. Acesse `http://localhost/phpmyadmin`.
   2. Na aba **Importar**, importe o `01_estrutura.sql` e depois o `02_povoamento.sql`.
4. **Configure a conexão:** faça uma cópia do arquivo `.env.example` com o nome `.env`, na raiz do projeto. Com a instalação padrão do XAMPP, use:

   ```
   DB_HOST=localhost
   DB_PORT=3306
   DB_DATABASE=gestao_fotovoltaica
   DB_USERNAME=root
   DB_PASSWORD=
   ```

   No XAMPP, o usuário `root` vem **sem senha**, por isso `DB_PASSWORD` fica vazio.
5. **Acesse o sistema** em `http://localhost/gestao_fotovoltaica/`.

## Consultas (relatórios)

As consultas SQL estão em `banco_de_dados/03_consultas.sql`. Cada uma tem um comentário explicando o que faz. Também é possível executá-las pelo menu **Relatórios** do sistema.

Para testar uma consulta no MySQL Workbench, abra o arquivo em **File → Open SQL Script...**, coloque o cursor sobre a consulta e pressione `Ctrl+Enter`. Esse atalho executa só a consulta onde está o cursor.

| Tipo | Quantidade |
|---|---|
| Consultas com junção | 3 |
| Consultas com `GROUP BY`, funções agregadas e/ou `HAVING` | 3 |
| Consultas com funções de data | 3 |
| Consultas aninhadas (subconsultas) | 3 |
