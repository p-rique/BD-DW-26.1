-- Ana Clara de Jesus Nascimento, DRE 124388471
-- Mariana Rocha de Moraes, DRE 122147926
-- Matheus Mangia Terra Suzano, DRE 123378716
-- Paulo Henrique Cotta de Assumpção, DRE 122156268
-- Pedro Nunes de Oliveira Pessanha, DRE 123177330
-- Ryan Domingos dos Santos Saraiva, DRE 123137429

DROP DATABASE IF EXISTS locadora_dw_analitico;
CREATE DATABASE IF NOT EXISTS locadora_dw_analitico CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE locadora_dw_analitico;

-- 1. TABELAS DIMENSÃO

CREATE TABLE dim_tempo (
    sk_tempo            INT             PRIMARY KEY, -- Chave inteligente (Ex: 20260529)
    data_completa       DATE            NOT NULL,    -- Data real (Ex: 2026-05-29)
    ano                 INT             NOT NULL,
    mes                 INT             NOT NULL,
    nome_mes            VARCHAR(15)     NOT NULL,
    dia                 INT             NOT NULL,
    dia_semana          INT             NOT NULL,    -- 1 a 7
    nome_dia_semana     VARCHAR(15)     NOT NULL,    -- 'Sexta-feira'
    trimestre           INT             NOT NULL,
    tipo_dia            VARCHAR(15)     NOT NULL,    -- 'Dia Útil' ou 'Fim de Semana'
    INDEX idx_data_completa (data_completa)
);

CREATE TABLE dim_patio (
    sk_patio            INT             NOT NULL AUTO_INCREMENT,
    sistema_origem      VARCHAR(50)     NOT NULL,    -- Adicionado para evitar colisão de chaves
    id_patio_oltp       INT             NOT NULL,
    nome_patio          VARCHAR(100)    NOT NULL,
    cidade              VARCHAR(100)    NOT NULL,
    uf                  CHAR(2)         NOT NULL,
    capacidade          INT             NULL,

    CONSTRAINT pk_dim_patio PRIMARY KEY (sk_patio)
);

CREATE TABLE dim_categoria (
    sk_categoria        INT             NOT NULL AUTO_INCREMENT,
    nome_categoria      VARCHAR(50)     NOT NULL,

    CONSTRAINT pk_dim_categoria PRIMARY KEY (sk_categoria)
);

CREATE TABLE dim_veiculo (
    sk_veiculo          INT             NOT NULL AUTO_INCREMENT,
    sistema_origem      VARCHAR(50)     NOT NULL,    -- Adicionado para evitar colisão de chaves
    id_veiculo_oltp     INT             NOT NULL,
    placa               VARCHAR(10)     NOT NULL,
    marca               VARCHAR(50)     NOT NULL,
    modelo              VARCHAR(50)     NOT NULL,
    categoria_nome      VARCHAR(50)     NOT NULL, 
    ano                 INT             NOT NULL,
    tipo_cambio         VARCHAR(20)     NULL,
    empresa_dona        VARCHAR(100)    NOT NULL, 

    CONSTRAINT pk_dim_veiculo PRIMARY KEY (sk_veiculo)
);

CREATE TABLE dim_cliente (
    sk_cliente          INT             NOT NULL AUTO_INCREMENT,
    sistema_origem      VARCHAR(50)     NOT NULL,    -- Adicionado para evitar colisão de chaves
    id_cliente_oltp     INT             NOT NULL,
    tipo_cliente        CHAR(2)         NOT NULL, 
    nome_ou_razao_social VARCHAR(100)   NOT NULL,
    cidade              VARCHAR(100)    NULL,
    uf                  CHAR(2)         NULL,

    CONSTRAINT pk_dim_cliente PRIMARY KEY (sk_cliente),
    CONSTRAINT chk_tipo_cliente_dw CHECK (tipo_cliente IN ('PF', 'PJ'))
);

CREATE TABLE dim_motorista (
    sk_motorista        INT             NOT NULL AUTO_INCREMENT,
    sistema_origem      VARCHAR(50)     NOT NULL,    -- Adicionado para evitar colisão de chaves
    id_motorista_oltp   INT             NOT NULL,
    nome_motorista      VARCHAR(100)    NOT NULL,
    categoria_cnh       VARCHAR(3)      NOT NULL,
    genero_motorista    VARCHAR(20)     NULL,        -- Ajustado para comportar 'Masculino'/'Feminino'
    faixa_etaria        VARCHAR(20)     NULL, 

    CONSTRAINT pk_dim_motorista PRIMARY KEY (sk_motorista)
);

-- 2. TABELAS FATO

CREATE TABLE fato_locacao (
    sk_locacao          INT             AUTO_INCREMENT PRIMARY KEY,
    sistema_origem      VARCHAR(50)     NOT NULL, -- Para rastrear a empresa dona da locação
    id_locacao_oltp     INT             NOT NULL,
    sk_cliente          INT             NOT NULL,
    sk_motorista        INT             NOT NULL, 
    sk_veiculo          INT             NOT NULL,
    sk_patio_retirada   INT             NOT NULL,
    sk_patio_devolucao  INT             NULL,       -- NULL até a devolução
    sk_tempo_retirada   INT             NOT NULL,
    sk_tempo_devolucao  INT             NULL,       -- Null até a devolução
    
    qtd_locacao         INT             DEFAULT 1,
    km_rodados          INT             NULL,    
    valor_total         DECIMAL(10,2)   NULL,
    
    -- Constraints de Chave Estrangeira
    CONSTRAINT fk_fato_cliente      FOREIGN KEY (sk_cliente)         REFERENCES dim_cliente(sk_cliente),
    CONSTRAINT fk_fato_motorista    FOREIGN KEY (sk_motorista)       REFERENCES dim_motorista(sk_motorista),
    CONSTRAINT fk_fato_veiculo      FOREIGN KEY (sk_veiculo)         REFERENCES dim_veiculo(sk_veiculo),
    CONSTRAINT fk_fato_patio_ret    FOREIGN KEY (sk_patio_retirada)  REFERENCES dim_patio(sk_patio),
    CONSTRAINT fk_fato_patio_dev    FOREIGN KEY (sk_patio_devolucao) REFERENCES dim_patio(sk_patio),
    CONSTRAINT fk_fato_tempo_ret    FOREIGN KEY (sk_tempo_retirada)  REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_fato_tempo_dev    FOREIGN KEY (sk_tempo_devolucao) REFERENCES dim_tempo(sk_tempo),

    -- Índices de Performance para Consultas OLAP/BI
    INDEX idx_fato_tempo_ret   (sk_tempo_retirada),
    INDEX idx_fato_tempo_dev   (sk_tempo_devolucao),
    INDEX idx_fato_patio_ret   (sk_patio_retirada),
    INDEX idx_fato_patio_dev   (sk_patio_devolucao),
    INDEX idx_fato_veiculo     (sk_veiculo),
    INDEX idx_fato_cliente     (sk_cliente),
    INDEX idx_fato_motorista   (sk_motorista)
);

CREATE TABLE fato_reserva (
    sk_reserva              INT             AUTO_INCREMENT PRIMARY KEY,
    sistema_origem          VARCHAR(50)     NOT NULL,   -- Adicionado para rastrear a empresa dona da reserva
    id_reserva_oltp         INT             NOT NULL,
    sk_cliente              INT             NOT NULL,
    sk_categoria            INT             NOT NULL,
    sk_patio_retirada       INT             NOT NULL,
    sk_patio_devolucao      INT             NULL,       -- NULL até a devolução
    sk_tempo_reserva        INT             NULL,       -- NULL até a confirmação da reserva
    sk_tempo_prev_retirada  INT             NOT NULL,
    sk_tempo_prev_devolucao INT             NULL,       -- NULL até a devolução
    
    -- Métricas / Fatos
    qtd_reserva             INT             DEFAULT 1,
    duracao_prevista_dias   INT             NULL,
    valor_previsto          DECIMAL(10,2)   NULL,
    
    -- Dimensão Degenerada
    status_reserva          VARCHAR(30)     NULL,
    
    -- Constraints de Chave Estrangeira
    CONSTRAINT fk_fato_res_cliente      FOREIGN KEY (sk_cliente)              REFERENCES dim_cliente(sk_cliente),
    CONSTRAINT fk_fato_res_categoria    FOREIGN KEY (sk_categoria)            REFERENCES dim_categoria(sk_categoria),
    CONSTRAINT fk_fato_res_patio_ret    FOREIGN KEY (sk_patio_retirada)       REFERENCES dim_patio(sk_patio),
    CONSTRAINT fk_fato_res_patio_dev    FOREIGN KEY (sk_patio_devolucao)      REFERENCES dim_patio(sk_patio),
    CONSTRAINT fk_fato_res_tempo_res    FOREIGN KEY (sk_tempo_reserva)        REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_fato_res_tempo_pret   FOREIGN KEY (sk_tempo_prev_retirada)  REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_fato_res_tempo_pdev   FOREIGN KEY (sk_tempo_prev_devolucao) REFERENCES dim_tempo(sk_tempo),

    -- Índices de Performance para Consultas OLAP/BI
    INDEX idx_fato_res_tempo_pret  (sk_tempo_prev_retirada),
    INDEX idx_fato_res_patio_ret   (sk_patio_retirada),
    INDEX idx_fato_res_categoria   (sk_categoria),
    INDEX idx_fato_res_cliente     (sk_cliente)
);

-- 3. POPULAÇÃO DA DIM_TEMPO

DELIMITER $$
CREATE PROCEDURE popular_dim_tempo(IN data_inicio DATE, IN data_fim DATE)
BEGIN
    DECLARE data_atual DATE;
    SET data_atual = data_inicio;
    SET lc_time_names = 'pt_BR';

    WHILE data_atual <= data_fim DO
        INSERT INTO dim_tempo (
            sk_tempo, data_completa, ano, mes, nome_mes, dia, dia_semana, nome_dia_semana, trimestre, tipo_dia
        ) VALUES (
            CAST(DATE_FORMAT(data_atual, '%Y%m%d') AS UNSIGNED), 
            data_atual,
            YEAR(data_atual),
            MONTH(data_atual),
            MONTHNAME(data_atual),
            DAY(data_atual),
            DAYOFWEEK(data_atual),
            DAYNAME(data_atual),
            QUARTER(data_atual),
            IF(DAYOFWEEK(data_atual) IN (1, 7), 'Fim de Semana', 'Dia Útil')
        );
        SET data_atual = DATE_ADD(data_atual, INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

-- Executa o preenchimento automático
START TRANSACTION;
CALL popular_dim_tempo('2020-01-01', '2030-12-31');
COMMIT;