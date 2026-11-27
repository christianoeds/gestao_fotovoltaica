<?php
/**
 * Visão da página inicial.
 *
 * É só o miolo da página: o Controlador::renderizar() coloca este HTML
 * dentro do layout (menu, barra do topo e rodapé).
 */

// Atalhos para as partes principais do sistema:
// 'pagina da URL' => [título, descrição, ícone do Lucide]
$atalhos = [
    'obras'        => ['Obras', 'Instalações, status e equipamentos de cada obra.', 'hard-hat'],
    'clientes'     => ['Clientes', 'Pessoas físicas e jurídicas atendidas.', 'users'],
    'equipamentos' => ['Equipamentos', 'Painéis, inversores e demais itens do catálogo.', 'zap'],
    'relatorios'   => ['Relatórios', 'Consultas e resumos sobre as obras.', 'file-text'],
];
?>
<section class="mb-6">
    <h2 class="text-2xl font-semibold text-slate-900">Bem-vindo à Gestão Fotovoltaica</h2>
    <p class="mt-1 text-slate-600">
        Sistema para acompanhar obras de energia solar: clientes, engenheiros,
        equipamentos e concessionárias. Escolha uma área abaixo ou use o menu ao lado.
    </p>
</section>

<div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
    <?php foreach ($atalhos as $pagina => [$tituloAtalho, $descricao, $icone]): ?>
        <a href="index.php?pagina=<?= $pagina ?>"
           class="group rounded-lg border border-slate-200 bg-white p-5 shadow-sm transition
                  hover:border-amber-400 hover:shadow-md">
            <div class="mb-3 inline-flex rounded-md bg-amber-100 p-2 text-amber-600
                        group-hover:bg-amber-400 group-hover:text-slate-900">
                <i data-lucide="<?= $icone ?>" class="size-6"></i>
            </div>
            <h3 class="font-semibold text-slate-900"><?= $tituloAtalho ?></h3>
            <p class="mt-1 text-sm text-slate-600"><?= $descricao ?></p>
        </a>
    <?php endforeach; ?>
</div>
