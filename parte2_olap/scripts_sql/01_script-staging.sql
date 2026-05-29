-- Ana Clara de Jesus Nascimento, DRE 124388471
-- Mariana Rocha de Moraes, DRE 122147926
-- Matheus Mangia Terra Suzano, DRE 123378716
-- Paulo Henrique Cotta de Assumpção, DRE 122156268
-- Pedro Nunes de Oliveira Pessanha, DRE 123177330
-- Ryan Domingos dos Santos Saraiva, DRE 123137429

DROP DATABASE IF EXISTS locadora_dw_staging;
CREATE DATABASE IF NOT EXISTS locadora_dw_staging CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE locadora_dw_staging;

-- Staging de Pátios
CREATE TABLE Stg_patio (
    Id_sistema_origem           VARCHAR(20)     NULL,
    Id_patio_origem             INT             NULL,
    Nome_patio                  VARCHAR(150)    NULL,
    Cidade                      VARCHAR(100)    NULL,
    Uf                          CHAR(2)         NULL,
    Capacidade                  INT             NULL,
    Data_Carga                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Staging de Veículos
CREATE TABLE Stg_veiculo (
    Id_sistema_origem           VARCHAR(20)     NULL,
    Id_veiculo_origem           INT             NULL,
    Placa                       VARCHAR(20)     NULL,
    Marca                       VARCHAR(100)    NULL,
    Modelo                      VARCHAR(100)    NULL,
    Grupo_categoria             VARCHAR(100)    NULL,
    Ano                         INT             NULL,
    Tipo_cambio                 VARCHAR(50)     NULL,
    Empresa_dona                VARCHAR(150)    NULL,
    Data_Carga                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Staging de Clientes
CREATE TABLE Stg_cliente (
    Id_sistema_origem           VARCHAR(20)     NULL,
    Id_cliente_origem           INT             NULL,
    Tipo_cliente                VARCHAR(5)      NULL,
    Nome_cliente                VARCHAR(200)    NULL,
    Cpf_cnpj                    VARCHAR(20)     NULL,
    Cidade                      VARCHAR(100)    NULL,
    Uf                          CHAR(2)         NULL,
    Data_Carga                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Staging de Motoristas
CREATE TABLE Stg_motorista (
    Id_sistema_origem           VARCHAR(20)     NULL,
    Id_motorista_origem         INT             NULL,
    Nome_motorista              VARCHAR(200)    NULL,
    Categoria_cnh               VARCHAR(10)     NULL,
    Genero_motorista            CHAR(1)         NULL,
    Data_nascimento             DATE            NULL,
    Data_Carga                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Staging de Locações (A Fato Transacional)
CREATE TABLE Stg_locacao (
    Id_sistema_origem           VARCHAR(20)     NULL,
    Id_locacao_origem           INT             NULL,
    Id_patio_retirada_origem    INT             NULL,
    Id_patio_devolucao_origem   INT             NULL,
    Id_veiculo_origem           INT             NULL,
    Id_cliente_origem           INT             NULL,
    Id_motorista_origem         INT             NULL,
    Data_retirada               DATETIME        NULL,
    Data_devolucao              DATETIME        NULL,
    Km_retirada                 INT             NULL,
    Km_devolucao                INT             NULL,
    Valor_total                 DECIMAL(10,2)   NULL,
    Data_Carga                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);