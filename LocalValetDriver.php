<?php

/**
 * Driver do Valet Linux para este projeto (só para desenvolvimento local;
 * no XAMPP este arquivo é ignorado).
 *
 * O Valet procura, por padrão, a pasta "public". Este projeto usa "publico",
 * então o driver diz ao Valet para:
 *   - servir os arquivos estáticos (CSS, JS, imagens) da pasta publico/;
 *   - mandar todo o resto para publico/index.php.
 * Nada fora de publico/ (como o .env) fica acessível pelo navegador.
 */
class LocalValetDriver extends ValetDriver
{
    public function serves($sitePath, $siteName, $uri)
    {
        return file_exists($sitePath . '/publico/index.php');
    }

    public function isStaticFile($sitePath, $siteName, $uri)
    {
        $arquivo = $sitePath . '/publico' . $uri;

        if ($uri !== '/' && is_file($arquivo) && !str_ends_with($uri, '.php')) {
            return $arquivo;
        }

        return false;
    }

    public function frontControllerPath($sitePath, $siteName, $uri)
    {
        return $sitePath . '/publico/index.php';
    }
}
