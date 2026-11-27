<?php

/**
 * Controlador da página inicial.
 *
 * URL: index.php?pagina=inicio (ou só index.php, que abre o início por padrão)
 */
class InicioControlador extends Controlador
{
    /**
     * Mostra a página inicial: a visão inicio/index dentro do layout.
     */
    public function index(): void
    {
        $this->renderizar('inicio/index', [
            'titulo' => 'Início',
        ]);
    }
}
