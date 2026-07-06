-- Ana Clara de Jesus Nascimento, DRE 124388471
-- Mariana Rocha de Moraes, DRE 122147926
-- Matheus Mangia Terra Suzano, DRE 123378716
-- Paulo Henrique Cotta de Assumpção, DRE 122156268
-- Pedro Nunes de Oliveira Pessanha, DRE 123177330
-- Ryan Domingos dos Santos Saraiva, DRE 123137429

USE locadora_dw_analitico;

-- Garante que a coluna tem tamanho suficiente para a palavra inteira
ALTER TABLE dim_motorista MODIFY COLUMN genero_motorista VARCHAR(20);

-- Desativa chaves estrangeiras temporariamente para limpar o DW e recarregar
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE fato_locacao;
TRUNCATE TABLE fato_reserva;
TRUNCATE TABLE dim_cliente;
TRUNCATE TABLE dim_motorista;
TRUNCATE TABLE dim_patio;
TRUNCATE TABLE dim_veiculo;
TRUNCATE TABLE dim_categoria;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Carga Dimensão Pátio (Agora com Sistema_Origem)
INSERT INTO dim_patio (sistema_origem, id_patio_oltp, nome_patio, cidade, uf, capacidade)
SELECT Sistema_Origem, Id_patio_oltp, Nome_patio, Cidade, Uf, Capacidade 
FROM locadora_dw_staging.Stg_patio;

-- 2. Carga Dimensão Categoria (Dimensão unificada, não precisa de sistema_origem)
INSERT INTO dim_categoria (nome_categoria)
SELECT DISTINCT Categoria_Nome 
FROM locadora_dw_staging.Stg_veiculo 
WHERE Categoria_Nome IS NOT NULL
UNION
SELECT DISTINCT Categoria_Nome 
FROM locadora_dw_staging.Stg_reserva 
WHERE Categoria_Nome IS NOT NULL;

-- 3. Carga Dimensão Veículo (Agora com Sistema_Origem)
INSERT INTO dim_veiculo (sistema_origem, id_veiculo_oltp, placa, marca, modelo, categoria_nome, ano, tipo_cambio, empresa_dona)
SELECT Sistema_Origem, Id_veiculo_oltp, Placa, Marca, Modelo, Categoria_Nome, Ano, Tipo_Cambio, Empresa_Dona 
FROM locadora_dw_staging.Stg_veiculo;

-- 4. Carga Dimensão Cliente (Agora com Sistema_Origem)
INSERT INTO dim_cliente (sistema_origem, id_cliente_oltp, tipo_cliente, nome_ou_razao_social, cidade, uf)
SELECT Sistema_Origem, Id_cliente_oltp, Tipo_Cliente, Nome_ou_Razao_Social, Cidade, Uf 
FROM locadora_dw_staging.Stg_cliente;

-- 5. Carga Dimensão Motorista (Agora com Sistema_Origem)
INSERT INTO dim_motorista (sistema_origem, id_motorista_oltp, nome_motorista, categoria_cnh, genero_motorista, faixa_etaria)
SELECT 
    Sistema_Origem, Id_motorista_oltp, Nome_motorista, Categoria_Cnh,
    CASE Genero_motorista WHEN 'M' THEN 'Masculino' WHEN 'F' THEN 'Feminino' ELSE 'Não Informado' END,
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, Data_Nascimento, CURDATE()) BETWEEN 18 AND 25 THEN '18-25 anos'
        WHEN TIMESTAMPDIFF(YEAR, Data_Nascimento, CURDATE()) BETWEEN 26 AND 35 THEN '26-35 anos'
        WHEN TIMESTAMPDIFF(YEAR, Data_Nascimento, CURDATE()) BETWEEN 36 AND 50 THEN '36-50 anos'
        WHEN TIMESTAMPDIFF(YEAR, Data_Nascimento, CURDATE()) > 50 THEN 'Acima de 50 anos'
        ELSE 'Indefinido'
    END
FROM locadora_dw_staging.Stg_motorista;

-- 6. Carga Tabela Fato Locação (Buscando o SK correto usando ID_OLTP + Sistema_Origem)
INSERT INTO fato_locacao (
    sistema_origem, id_locacao_oltp, sk_cliente, sk_motorista, sk_veiculo, sk_patio_retirada, sk_patio_devolucao, sk_tempo_retirada, sk_tempo_devolucao, km_rodados, valor_total
)
SELECT 
    L.Sistema_Origem, L.Id_locacao_oltp, C.sk_cliente, M.sk_motorista, V.sk_veiculo,
    P_RET.sk_patio AS sk_patio_retirada, P_DEV.sk_patio AS sk_patio_devolucao,
    CAST(DATE_FORMAT(L.Data_Retirada, '%Y%m%d') AS UNSIGNED) AS sk_tempo_retirada,
    CAST(DATE_FORMAT(L.Data_Devolucao, '%Y%m%d') AS UNSIGNED) AS sk_tempo_devolucao,
    (L.Km_Devolucao - L.Km_Retirada) AS km_rodados, L.Valor_Total
FROM locadora_dw_staging.Stg_locacao L
JOIN dim_cliente C ON L.Id_cliente_oltp = C.id_cliente_oltp AND L.Sistema_Origem = C.sistema_origem
JOIN dim_motorista M ON L.Id_motorista_oltp = M.id_motorista_oltp AND L.Sistema_Origem = M.sistema_origem
JOIN dim_veiculo V ON L.Id_veiculo_oltp = V.id_veiculo_oltp AND L.Sistema_Origem = V.sistema_origem
JOIN dim_patio P_RET ON L.Id_patio_retirada_oltp = P_RET.id_patio_oltp AND L.Sistema_Origem = P_RET.sistema_origem
LEFT JOIN dim_patio P_DEV ON L.Id_patio_devolucao_oltp = P_DEV.id_patio_oltp AND L.Sistema_Origem = P_DEV.sistema_origem;

-- 7. Carga Tabela Fato Reserva (Buscando o SK correto usando ID_OLTP + Sistema_Origem)
INSERT INTO fato_reserva (
    id_reserva_oltp, sk_cliente, sk_categoria, sk_patio_retirada, sk_patio_devolucao, 
    sk_tempo_reserva, sk_tempo_prev_retirada, sk_tempo_prev_devolucao, 
    duracao_prevista_dias, valor_previsto, status_reserva
)
SELECT 
    R.Id_reserva_oltp, 
    C.sk_cliente, 
    CAT.sk_categoria, 
    P_RET.sk_patio AS sk_patio_retirada, 
    P_DEV.sk_patio AS sk_patio_devolucao,
    CAST(DATE_FORMAT(R.Data_Reserva, '%Y%m%d') AS UNSIGNED) AS sk_tempo_reserva,
    CAST(DATE_FORMAT(R.Data_Prev_Retirada, '%Y%m%d') AS UNSIGNED) AS sk_tempo_prev_retirada,
    CAST(DATE_FORMAT(R.Data_Prev_Devolucao, '%Y%m%d') AS UNSIGNED) AS sk_tempo_prev_devolucao,
    TIMESTAMPDIFF(DAY, R.Data_Prev_Retirada, R.Data_Prev_Devolucao) AS duracao_prevista_dias,
    R.Valor_Previsto, 
    R.Status_Reserva
FROM locadora_dw_staging.Stg_reserva R
LEFT JOIN dim_cliente C ON R.Id_cliente_oltp = C.id_cliente_oltp AND R.Sistema_Origem = C.sistema_origem
LEFT JOIN dim_categoria CAT ON R.Categoria_Nome = CAT.nome_categoria -- Categoria é dimensão unificada
LEFT JOIN dim_patio P_RET ON R.Id_patio_retirada_oltp = P_RET.id_patio_oltp AND R.Sistema_Origem = P_RET.sistema_origem
LEFT JOIN dim_patio P_DEV ON R.Id_patio_devolucao_oltp = P_DEV.id_patio_oltp AND R.Sistema_Origem = P_DEV.sistema_origem;