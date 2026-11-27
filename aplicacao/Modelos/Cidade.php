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
}
