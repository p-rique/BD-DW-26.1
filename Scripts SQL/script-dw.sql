-- Ana Clara de Jesus Nascimento, DRE 124388471
-- Mariana Rocha de Moraes, DRE 122147926
-- Matheus Mangia Terra Suzano, DRE 123378716
-- Paulo Henrique Cotta de Assumpção, DRE 122156268
-- Pedro Nunes de Oliveira Pessanha, DRE 123177330
-- Ryan Domingos dos Santos Saraiva, DRE 123137429

DROP DATABASE IF EXISTS locadora_dw_analitico;
CREATE DATABASE IF NOT EXISTS locadora_dw_analitico CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE locadora_dw_analitico;

-- TABELAS DIMENSÃO

CREATE TABLE Dim_Tempo (
    Id_tempo        INT             NOT NULL, -- YYYYMMDD
    Data_completa   DATE            NOT NULL,
    Ano             INT             NOT NULL,
    Mes             INT             NOT NULL,
    Dia             INT             NOT NULL,
    Trimestre       INT             NOT NULL,
    Dia_Semana      VARCHAR(20)     NOT NULL,

    CONSTRAINT PK_Dim_Tempo PRIMARY KEY (Id_tempo)
);

CREATE TABLE Dim_Patio (
    Id_patio_sk     INT             NOT NULL AUTO_INCREMENT, -- Surrogate Key analítica
    Id_patio_oltp   INT             NOT NULL,                -- ID de origem operacional
    Nome_patio      VARCHAR(100)    NOT NULL,
    Cidade          VARCHAR(100)    NOT NULL,
    Uf              CHAR(2)         NOT NULL,
    Capacidade      INT             NULL,

    CONSTRAINT PK_Dim_Patio PRIMARY KEY (Id_patio_sk)
);

CREATE TABLE Dim_Veiculo (
    Id_veiculo_sk   INT             NOT NULL AUTO_INCREMENT,
    Id_veiculo_oltp INT             NOT NULL,
    Placa           VARCHAR(7)      NOT NULL,                --ABC1D23
    Marca           VARCHAR(50)     NOT NULL,
    Modelo          VARCHAR(50)     NOT NULL,
    Categoria_Nome  VARCHAR(50)     NOT NULL,
    Ano             INT             NOT NULL,                --YYYY
    Tipo_Cambio     VARCHAR(20)     NULL,
    Empresa_Dona    VARCHAR(100)    NOT NULL,                -- Identifica a qual das 6 empresas o veículo pertence

    CONSTRAINT PK_Dim_Veiculo PRIMARY KEY (Id_veiculo_sk)
);

CREATE TABLE Dim_Cliente (
    Id_cliente_sk        INT             NOT NULL AUTO_INCREMENT,
    Id_cliente_oltp      INT             NOT NULL,
    Tipo_Cliente         CHAR(2)         NOT NULL,                -- Restrição ('PF' ou 'PJ')
    Nome_ou_Razao_Social VARCHAR(100)    NOT NULL,
    Cidade               VARCHAR(100)    NULL,
    Uf                   CHAR(2)         NULL,

    CONSTRAINT PK_Dim_Cliente     PRIMARY KEY (Id_cliente_sk),
    CONSTRAINT CHK_Tipo_Cliente_DW CHECK (Tipo_Cliente IN ('PF', 'PJ'))
);

CREATE TABLE Dim_Motorista (
    Id_motorista_sk   INT             NOT NULL AUTO_INCREMENT,
    Id_motorista_oltp INT             NOT NULL,
    Nome_motorista    VARCHAR(100)    NOT NULL,
    Categoria_Cnh     VARCHAR(3)      NOT NULL,
    Genero_motorista  CHAR(1)         NULL,
    Faixa_Etaria      VARCHAR(20)     NULL,                    -- Calculada no processo de ETL (ex: '25-34 anos')

    CONSTRAINT PK_Dim_Motorista PRIMARY KEY (Id_motorista_sk)
);

-- TABELA FATO

CREATE TABLE Fato_Locacao (
    Id_locacao_oltp     INT             NOT NULL,
    Fk_Tempo_Retirada   INT             NOT NULL,
    Fk_Tempo_Devolucao  INT             NULL,     -- NULL até devolução
    Fk_Patio_Retirada   INT             NOT NULL, -- Estado Inicial (Origem)
    Fk_Patio_Devolucao  INT             NULL,     -- Estado Final (Destino), NULL até devolução
    Fk_Veiculo          INT             NOT NULL,
    Fk_Cliente          INT             NOT NULL,
    Fk_Motorista        INT             NOT NULL,
    
    Qtd_Diarias         INT             NULL,     -- Calculado no pipeline de carga (ETL)
    Km_Rodados          INT             NULL,     -- Métrica: Km_devolucao - Km_retirada
    Valor_Total         DECIMAL(10,2)   NULL,     

    CONSTRAINT PK_Fato_Locacao      PRIMARY KEY (Id_locacao_oltp),
    CONSTRAINT FK_Fato_Tempo_Ret    FOREIGN KEY (Fk_Tempo_Retirada)  REFERENCES Dim_Tempo(Id_tempo),
    CONSTRAINT FK_Fato_Tempo_Dev    FOREIGN KEY (Fk_Tempo_Devolucao) REFERENCES Dim_Tempo(Id_tempo),
    CONSTRAINT FK_Fato_Patio_Ret    FOREIGN KEY (Fk_Patio_Retirada)  REFERENCES Dim_Patio(Id_patio_sk),
    CONSTRAINT FK_Fato_Patio_Dev    FOREIGN KEY (Fk_Patio_Devolucao) REFERENCES Dim_Patio(Id_patio_sk),
    CONSTRAINT FK_Fato_Veiculo      FOREIGN KEY (Fk_Veiculo)         REFERENCES Dim_Veiculo(Id_veiculo_sk),
    CONSTRAINT FK_Fato_Cliente      FOREIGN KEY (Fk_Cliente)         REFERENCES Dim_Cliente(Id_cliente_sk)
);