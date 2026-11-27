<?php

/**
 * Ponto de entrada do sistema: toda requisição passa por aqui.
 *
 * As páginas são escolhidas pela URL:
 *   index.php?pagina=cidades&acao=editar&id=3
 *     pagina → qual controlador (ex.: cidades → CidadeControlador)
 *     acao   → qual metodo do controlador (ex.: editar)
 * Sem "pagina", abre a página inicial. Sem "acao", abre a ação "index".
 */

// Pasta raiz do projeto (a pasta acima de "publico").
define('RAIZ', dirname(__DIR__));

// 1. Carregamento automático das classes
// Quando o código usa uma classe que ainda não foi carregada (ex.: Conexao),
// o PHP chama esta função, que procura o arquivo Conexao.php nas pastas abaixo.
spl_autoload_register(function (string $classe): void {
    $pastas = [
        'configuracao',
        'aplicacao/Nucleo',
        'aplicacao/Modelos',
        'aplicacao/Controladores',
    ];

    foreach ($pastas as $pasta) {
        $arquivo = RAIZ . "/$pasta/$classe.php";

        if (is_file($arquivo)) {
            require $arquivo;
            return;
        }
    }
});

// 2. Rotas: as páginas que existem e as ações permitidas em cada uma
// Só o que está nesta lista pode ser acessado pela URL.
$rotas = [
    'inicio'  => ['InicioControlador', ['index']],
    'cidades' => ['CidadeControlador', ['index']],
];

// 3. Execução da página pedida
try {
    Ambiente::carregar(RAIZ . '/.env');

    $pagina = $_GET['pagina'] ?? 'inicio';
    $acao   = $_GET['acao']   ?? 'index';

    // is_string: a URL pode trazer um array (ex.: ?pagina[]=x), que não é página.
    if (!is_string($pagina) || !isset($rotas[$pagina])) {
        http_response_code(404);
        echo 'Página não encontrada.';
        exit;
    }

    [$classeControlador, $acoesPermitidas] = $rotas[$pagina];

    if (!in_array($acao, $acoesPermitidas, true)) {
        http_response_code(404);
        echo 'Ação não encontrada.';
        exit;
    }

    $controlador = new $classeControlador();
    $controlador->$acao();

} catch (Throwable $erro) {
    http_response_code(500);
    echo '<h1>Ocorreu um erro</h1>';
    echo '<p>' . htmlspecialchars($erro->getMessage()) . '</p>';
}
