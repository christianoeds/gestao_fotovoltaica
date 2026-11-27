<?php

/**
 * Classe base dos controladores.
 *
 * Todo controlador do sistema herda desta classe para usar os métodos comuns.
 * Por enquanto, só o renderizar(), que monta a tela dentro do layout.
 *
 * Uso dentro de um controlador:
 *   $this->renderizar('cidades/index', [
 *       'titulo'  => 'Cidades',
 *       'cidades' => $listaDeCidades,
 *   ]);
 */
abstract class Controlador
{
    /**
     * Mostra uma visão (tela) dentro do layout comum.
     *
     * @param string $visao caminho da visão dentro de aplicacao/Visoes, sem ".php"
     *                      (ex.: 'cidades/index' → aplicacao/Visoes/cidades/index.php)
     * @param array  $dados variáveis para a visão e o layout: cada chave vira uma
     *                      variável (ex.: 'titulo' => 'Cidades' vira $titulo)
     */
    protected function renderizar(string $visao, array $dados = []): void
    {
        $arquivoVisao = RAIZ . "/aplicacao/Visoes/$visao.php";

        if (!is_file($arquivoVisao)) {
            throw new RuntimeException("Visão não encontrada: $visao");
        }

        // Transforma cada chave do array em uma variável.
        // EXTR_SKIP: não sobrescreve variáveis que já existem aqui ($visao, $arquivoVisao...).
        extract($dados, EXTR_SKIP);

        // Executa a visão guardando o HTML numa variável, em vez de mandar direto
        // para o navegador. Esse HTML vira o $conteudo que o layout exibe.
        ob_start();
        try {
            require $arquivoVisao;
        } catch (Throwable $erro) {
            // Se a visão der erro, descarta o HTML pela metade e repassa o erro.
            ob_end_clean();
            throw $erro;
        }
        $conteudo = ob_get_clean();

        require RAIZ . '/aplicacao/Visoes/comum/layout.php';
    }
}
