<?php

/**
 * Modelo da tabela "cidade": todo o SQL das cidades fica aqui.
 *
 * Colunas: id, nome, uf
 * Regra: não pode haver duas cidades com o mesmo nome na mesma UF
 * (chave única uk_cidade_nome_uf).
 *
 * Uso:
 *   $cidades = Cidade::listar();
 */
class Cidade
{
    /**
     * Devolve todas as cidades, ordenadas por UF e depois por nome.
     *
     * @return array lista de cidades; cada uma é um array com
     *               as chaves 'id', 'nome' e 'uf'
     */
    public static function listar(): array
    {
        $bd = Conexao::obter();

        $sql = 'SELECT id, nome, uf
                FROM cidade
                ORDER BY uf, nome';

        $resultado = $bd->query($sql);

        return $resultado->fetch_all(MYSQLI_ASSOC);
    }

    /**
     * Cadastra uma cidade nova.
     *
     * Se já existir uma cidade com o mesmo nome na mesma UF, o banco recusa
     * (chave única) e o mysqli lança uma mysqli_sql_exception com o código 1062.
     *
     * @param string $nome nome da cidade
     * @param string $uf   sigla do estado, com 2 letras (ex.: 'MG')
     * @return int id gerado para a cidade nova
     */
    public static function inserir(string $nome, string $uf): int
    {
        $bd = Conexao::obter();

        // Os "?" marcam onde os valores vão entrar. O SQL vai para o banco
        // sem os valores, e eles são enviados depois, separados.
        $sql = 'INSERT INTO cidade (nome, uf)
                VALUES (?, ?)';

        $comando = $bd->prepare($sql);

        // "ss": os dois valores são strings (texto), na ordem dos "?".
        $comando->bind_param('ss', $nome, $uf);
        $comando->execute();

        // id que o AUTO_INCREMENT gerou para esta cidade.
        return $comando->insert_id;
    }
}
