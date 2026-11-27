<?php
/**
 * Visão da listagem de cidades.
 *
 * Variáveis recebidas do CidadeControlador::index():
 *   $cidades  lista de cidades; cada uma com 'id', 'nome' e 'uf'
 */

/** @var array $cidades */
?>
<div class="mb-4">
    <p class="text-sm text-slate-600">
        <?= count($cidades) ?> cidade(s) cadastrada(s)
    </p>
</div>

<?php if (empty($cidades)): ?>

    <div class="rounded-lg border border-dashed border-slate-300 bg-white p-8 text-center text-slate-500">
        Nenhuma cidade cadastrada.
    </div>

<?php else: ?>

    <div class="overflow-x-auto rounded-lg border border-slate-200 bg-white shadow-sm">
        <table class="w-full text-left text-sm">
            <thead class="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
                <tr>
                    <th class="px-4 py-3 font-semibold">Nome</th>
                    <th class="w-20 px-4 py-3 font-semibold">UF</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                <?php foreach ($cidades as $cidade): ?>
                    <tr class="hover:bg-slate-50">
                        <td class="px-4 py-3 text-slate-900"><?= htmlspecialchars($cidade['nome']) ?></td>
                        <td class="px-4 py-3 text-slate-600"><?= htmlspecialchars($cidade['uf']) ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

<?php endif; ?>
