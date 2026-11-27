<?php

/**
 * Controlador das cidades (CRUD da tabela "cidade").
 *
 * URL: index.php?pagina=cidades&acao=...
 *   index → lista as cidades
 */
class CidadeControlador extends Controlador
{
    /**
     * Lista todas as cidades.
     */
    public function index(): void
    {
        // 1. Pede os dados ao modelo.
        $cidades = Cidade::listar();

        // 2. Entrega os dados para a visão mostrar.
        $this->renderizar('cidades/index', [
            'titulo'  => 'Cidades',
            'cidades' => $cidades,
        ]);
    }
}
