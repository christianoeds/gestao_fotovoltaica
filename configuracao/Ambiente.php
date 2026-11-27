<?php

/**
 * Lê as configurações do arquivo .env
 * Uso:
 *   Ambiente::carregar(__DIR__ . '/../.env');
 *   $host = Ambiente::obter('DB_HOST');
 */
class Ambiente
{
    private static array $valores = [];

    /**
     * Lê o arquivo .env e guarda os valores.
     * Linhas vazias e linhas que começam com # (comentários) são ignoradas.
     */
    public static function carregar(string $caminho): void
    {
        if (!is_file($caminho)) {
            throw new RuntimeException(
                "Arquivo de configuração não encontrado: $caminho. " .
                'Copie o .env.example com o nome .env e preencha os dados do banco.'
            );
        }

        $linhas = file($caminho, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

        foreach ($linhas as $linha) {
            $linha = trim($linha);

            // Pula linhas em branco e comentários.
            if ($linha === '' || str_starts_with($linha, '#')) {
                continue;
            }

            // Pula linhas sem "=", que não são configurações.
            if (!str_contains($linha, '=')) {
                continue;
            }

            // Corta só no primeiro "=", porque o valor pode conter "=".
            [$chave, $valor] = explode('=', $linha, 2);

            self::$valores[trim($chave)] = trim($valor);
        }
    }

    /**
     * Devolve o valor de uma configuração.
     * Um valor vazio (ex.: DB_PASSWORD=) é válido e devolve ''.
     */
    public static function obter(string $chave): string
    {
        if (!array_key_exists($chave, self::$valores)) {
            throw new RuntimeException("Configuração '$chave' não encontrada no arquivo .env.");
        }

        return self::$valores[$chave];
    }
}
