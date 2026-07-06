-- Ana Clara de Jesus Nascimento, DRE 124388471
-- Mariana Rocha de Moraes, DRE 122147926
-- Matheus Mangia Terra Suzano, DRE 123378716
-- Paulo Henrique Cotta de Assumpção, DRE 122156268
-- Pedro Nunes de Oliveira Pessanha, DRE 123177330
-- Ryan Domingos dos Santos Saraiva, DRE 123137429

USE locadora_dw_analitico;

-- 12.a Controle de pátio: quantitativo por grupo, origem, marca, modelo e mecanização
SELECT 
    PR.nome_patio AS Patio_Retirada,
    V.categoria_nome AS Grupo_Veiculo,
    V.marca AS Marca,
    V.modelo AS Modelo,
    V.tipo_cambio AS Mecanizacao,
    V.empresa_dona AS Origem_Veiculo,
    SUM(F.qtd_locacao) AS Total_Locacoes_Historicas
FROM fato_locacao F
JOIN dim_patio PR ON F.sk_patio_retirada = PR.sk_patio
JOIN dim_veiculo V ON F.sk_veiculo = V.sk_veiculo
GROUP BY PR.nome_patio, V.categoria_nome, V.marca, V.modelo, V.tipo_cambio, V.empresa_dona
ORDER BY PR.nome_patio, Total_Locacoes_Historicas DESC;


-- 12.b Controle das locações (CORRIGIDO): quantitativo por grupo, tempo de locação e disponibilidade
SELECT 
    V.categoria_nome AS Grupo_Veiculo,
    -- Calcula o tempo de locação já realizado em dias
    DATEDIFF(COALESCE(TD.data_completa, CURDATE()), TR.data_completa) AS Tempo_Locacao_Dias,
    -- Indica se o carro já foi devolvido ou se ainda está rodando (pendente de devolução)
    CASE 
        WHEN F.sk_tempo_devolucao IS NULL THEN 'Alugado (Aguardando Devolução)'
        ELSE 'Disponível (Devolvido)' 
    END AS Status_Disponibilidade,
    SUM(F.qtd_locacao) AS Volume_Locacoes
FROM fato_locacao F
JOIN dim_veiculo V ON F.sk_veiculo = V.sk_veiculo
JOIN dim_tempo TR ON F.sk_tempo_retirada = TR.sk_tempo
LEFT JOIN dim_tempo TD ON F.sk_tempo_devolucao = TD.sk_tempo
GROUP BY V.categoria_nome, Tempo_Locacao_Dias, Status_Disponibilidade
ORDER BY Volume_Locacoes DESC, Tempo_Locacao_Dias DESC;


-- 12.c Controle de reservas: reservas por grupo, pátio, tempo de retirada, duração e cidade
SELECT 
    C.nome_categoria AS Grupo_Veiculo,
    P.nome_patio AS Patio_Desejado_Retirada,
    T.ano AS Ano_Retirada_Futura,
    T.nome_mes AS Mes_Retirada_Futura,
    F.duracao_prevista_dias AS Duracao_Locacao_Dias,
    CLI.cidade AS Cidade_Origem_Cliente,
    SUM(F.qtd_reserva) AS Total_Reservas
FROM fato_reserva F
JOIN dim_categoria C ON F.sk_categoria = C.sk_categoria
JOIN dim_patio P ON F.sk_patio_retirada = P.sk_patio
JOIN dim_tempo T ON F.sk_tempo_prev_retirada = T.sk_tempo
JOIN dim_cliente CLI ON F.sk_cliente = CLI.sk_cliente
GROUP BY C.nome_categoria, P.nome_patio, T.ano, T.nome_mes, F.duracao_prevista_dias, CLI.cidade
ORDER BY Ano_Retirada_Futura DESC, Mes_Retirada_Futura DESC, Total_Reservas DESC;


-- 12.d Grupos de veículos mais alugados cruzados com a origem dos clientes
SELECT 
    V.categoria_nome AS Grupo_Veiculo,
    CLI.cidade AS Cidade_Origem_Cliente,
    CLI.uf AS Estado_Origem_Cliente,
    SUM(F.qtd_locacao) AS Total_Locacoes
FROM fato_locacao F
JOIN dim_veiculo V ON F.sk_veiculo = V.sk_veiculo
JOIN dim_cliente CLI ON F.sk_cliente = CLI.sk_cliente
GROUP BY V.categoria_nome, CLI.cidade, CLI.uf
ORDER BY Total_Locacoes DESC, Grupo_Veiculo ASC;


-- 13 MATRIZ: Percentuais de Movimentação entre Pátios (Cadeia de Markov)
WITH MovimentacoesBrutas AS (
    SELECT 
        PR.nome_patio AS Patio_Origem,
        PD.nome_patio AS Patio_Destino,
        SUM(F.qtd_locacao) AS Qtd_Veiculos_Movidos
    FROM fato_locacao F
    JOIN dim_patio PR ON F.sk_patio_retirada = PR.sk_patio
    JOIN dim_patio PD ON F.sk_patio_devolucao = PD.sk_patio
    WHERE F.sk_tempo_devolucao IS NOT NULL
    GROUP BY PR.nome_patio, PD.nome_patio
),
TotalSaidasPorPatio AS (
    SELECT 
        Patio_Origem, 
        SUM(Qtd_Veiculos_Movidos) AS Total_Saidas
    FROM MovimentacoesBrutas
    GROUP BY Patio_Origem
)
SELECT 
    M.Patio_Origem AS Pátio de Retirada (Origem),
    M.Patio_Destino AS Pátio de Devolução (Destino),
    M.Qtd_Veiculos_Movidos AS Qtd de Veículos Movidos,
    T.Total_Saidas AS Total de Saídas da Origem,
    CONCAT(ROUND((M.Qtd_Veiculos_Movidos / T.Total_Saidas) * 100, 2), '%') AS Percentual de Movimentação
FROM MovimentacoesBrutas M
JOIN TotalSaidasPorPatio T ON M.Patio_Origem = T.Patio_Origem
ORDER BY M.Patio_Origem ASC, Percentual de Movimentação DESC;