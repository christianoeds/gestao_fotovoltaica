<?php

/**
 * Abre a conexão com o banco de dados (mysqli) e a reaproveita durante
 * toda a requisição. Os dados de acesso vêm do .env, pela classe Ambiente.
 *
 * Uso:
 *   $bd = Conexao::obter();
 *   $resultado = $bd->query('SELECT ...');
 */
class Conexao
{
    /** A conexão aberta, ou null enquanto ainda não foi aberta. */
    private static ?mysqli $conexao = null;

    /**
     * Devolve a conexão com o banco. Na primeira chamada, abre a conexão;
     * nas seguintes, devolve a mesma que já está aberta.
     */
    public static function obter(): mysqli
    {
        if (self::$conexao === null) {
            // Faz o mysqli lançar exceções quando der erro, em vez de só
            // devolver false e deixar o sistema continuar sem perceber.
            mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

            self::$conexao = new mysqli(
                Ambiente::obter('DB_HOST'),
                Ambiente::obter('DB_USERNAME'),
                Ambiente::obter('DB_PASSWORD'),
                Ambiente::obter('DB_DATABASE'),
                (int) Ambiente::obter('DB_PORT')
            );

            // Acentos e caracteres especiais (RNF08).
            self::$conexao->set_charset('utf8mb4');
        }

        return self::$conexao;
    }
}
