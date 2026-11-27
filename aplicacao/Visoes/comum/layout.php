<?php
/**
 * Layout comum a todas as telas: barra lateral (menu) recolhível, barra do
 * topo com o título e a área de conteúdo.
 *
 * Variáveis esperadas:
 *   $titulo    título da página (aba do navegador e barra do topo)
 *   $conteudo  HTML da tela, já montado
 *
 * Estilo com Tailwind CSS e ícones com Lucide, os dois pelo CDN
 * (precisam de internet).
 *
 * Barra lateral:
 *   - no computador (tela md ou maior), encolhe para mostrar só os ícones;
 *   - no celular, fica escondida e abre por cima do conteúdo;
 *   - no computador, a escolha (aberta ou recolhida) fica guardada no
 *     navegador (localStorage) e vale para as próximas páginas.
 */

// Itens do menu: 'pagina da URL' => [rótulo, ícone do Lucide]
$itensMenu = [
    'inicio'          => ['Início', 'house'],
    'obras'           => ['Obras', 'hard-hat'],
    'clientes'        => ['Clientes', 'users'],
    'engenheiros'     => ['Engenheiros', 'user-cog'],
    'equipamentos'    => ['Equipamentos', 'zap'],
    'fabricantes'     => ['Fabricantes', 'factory'],
    'concessionarias' => ['Concessionárias', 'building-2'],
    'cidades'         => ['Cidades', 'map-pin'],
    'relatorios'      => ['Relatórios', 'file-text'],
];

// Página aberta, para destacar o item no menu.
$paginaAtual = $_GET['pagina'] ?? 'inicio';
?>
<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= htmlspecialchars($titulo ?? 'Início') ?> | Gestão Fotovoltaica</title>

    <script>
        // Aplica o estado salvo antes de a tela ser desenhada,
        // para a barra lateral não "piscar" aberta e depois recolher.
        try {
            if (localStorage.getItem('menu') === 'recolhido') {
                document.documentElement.dataset.menu = 'recolhido';
            }
        } catch (erro) {}
    </script>

    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4.1.0"></script>
    <style type="text/tailwindcss">
        /* recolhido: vale quando o <html> tem data-menu="recolhido" */
        @custom-variant recolhido (&:where([data-menu=recolhido] *));
        /* aberto: vale quando o <html> tem data-mobile="aberto" (menu aberto no celular) */
        @custom-variant aberto (&:where([data-mobile=aberto] *));
    </style>

    <script src="https://unpkg.com/lucide@0.460.0/dist/umd/lucide.min.js"></script>
</head>
<body class="bg-slate-100 text-slate-800 antialiased">
<div class="min-h-screen md:flex">

    <!-- Fundo escuro atrás do menu, só no celular -->
    <div id="fundo-menu" class="fixed inset-0 z-30 hidden bg-black/40 aberto:block md:hidden"></div>

    <!-- Barra lateral -->
    <aside class="fixed inset-y-0 left-0 z-40 flex w-64 -translate-x-full flex-col bg-slate-900 text-slate-300 transition-all duration-200
                  aberto:translate-x-0
                  md:sticky md:top-0 md:h-screen md:translate-x-0 md:recolhido:w-16">

        <div class="flex h-14 items-center gap-3 border-b border-white/10 px-4">
            <i data-lucide="sun" class="size-6 shrink-0 text-amber-400"></i>
            <span class="whitespace-nowrap font-semibold text-white md:recolhido:hidden">Gestão Fotovoltaica</span>
        </div>

        <nav class="flex-1 space-y-1 overflow-y-auto overflow-x-hidden p-2">
            <?php foreach ($itensMenu as $pagina => [$rotulo, $icone]): ?>
                <a href="index.php?pagina=<?= $pagina ?>"
                   title="<?= $rotulo ?>"
                   class="flex items-center gap-3 whitespace-nowrap rounded-md px-3 py-2 text-sm
                          <?= $pagina === $paginaAtual
                              ? 'bg-amber-400 font-semibold text-slate-900'
                              : 'hover:bg-white/10 hover:text-white' ?>">
                    <i data-lucide="<?= $icone ?>" class="size-5 shrink-0"></i>
                    <span class="md:recolhido:hidden"><?= $rotulo ?></span>
                </a>
            <?php endforeach; ?>
        </nav>
    </aside>

    <!-- Barra do topo e conteúdo -->
    <div class="flex min-w-0 flex-1 flex-col">
        <header class="sticky top-0 z-20 flex h-14 items-center gap-3 border-b border-slate-200 bg-white px-4">
            <button id="botao-menu" type="button" aria-label="Abrir ou recolher o menu"
                    class="rounded-md p-2 text-slate-600 hover:bg-slate-100">
                <i data-lucide="panel-left" class="size-5"></i>
            </button>
            <h1 class="text-lg font-semibold"><?= htmlspecialchars($titulo ?? 'Início') ?></h1>
        </header>

        <main class="flex-1 p-4 md:p-6">
            <?= $conteudo ?? '' ?>
        </main>

        <footer class="px-6 py-4 text-center text-xs text-slate-500">
            Gestão Fotovoltaica · Trabalho final de Banco de Dados
        </footer>
    </div>
</div>

<script>
    // Troca as tags <i data-lucide="..."> pelos ícones (SVG).
    lucide.createIcons();

    const raiz = document.documentElement;

    document.getElementById('botao-menu').addEventListener('click', function () {
        if (window.matchMedia('(min-width: 768px)').matches) {
            // Computador: alterna entre aberta e recolhida e guarda a escolha.
            const recolher = raiz.dataset.menu !== 'recolhido';

            if (recolher) {
                raiz.dataset.menu = 'recolhido';
            } else {
                delete raiz.dataset.menu;
            }

            try {
                localStorage.setItem('menu', recolher ? 'recolhido' : 'aberto');
            } catch (erro) {}
        } else {
            // Celular: abre ou fecha o menu por cima do conteúdo.
            if (raiz.dataset.mobile === 'aberto') {
                delete raiz.dataset.mobile;
            } else {
                raiz.dataset.mobile = 'aberto';
            }
        }
    });

    // No celular, tocar no fundo escuro fecha o menu.
    document.getElementById('fundo-menu').addEventListener('click', function () {
        delete raiz.dataset.mobile;
    });
</script>
</body>
</html>
