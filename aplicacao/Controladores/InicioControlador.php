<?php

/**
 * Página inicial do sistema.
 * Provisória: na Parte 1.4 ela passa a usar o layout (cabeçalho, menu e rodapé).
 */
class InicioControlador
{
    public function index(): void
    {
        echo '<h1>Gestão Fotovoltaica</h1>';
        echo '<p>O sistema está funcionando.</p>';
    }
}
