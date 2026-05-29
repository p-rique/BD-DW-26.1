-- Ana Clara de Jesus Nascimento, DRE 124388471
-- Mariana Rocha de Moraes, DRE 122147926
-- Matheus Mangia Terra Suzano, DRE 123378716
-- Paulo Henrique Cotta de Assumpção, DRE 122156268
-- Pedro Nunes de Oliveira Pessanha, DRE 123177330
-- Ryan Domingos dos Santos Saraiva, DRE 123137429

USE locadora_dw_staging;

-- ==============================================================================
-- 0. LIMPEZA DA STAGING AREA (Garantindo Idempotência do Pipeline)
-- ==============================================================================
TRUNCATE TABLE Stg_patio;
TRUNCATE TABLE Stg_veiculo;
TRUNCATE TABLE Stg_cliente;
TRUNCATE TABLE Stg_motorista;
TRUNCATE TABLE Stg_locacao;

-- ------------------------------------------------------------------------------
-- 1. EXTRAÇÃO: PÁTIOS
-- ------------------------------------------------------------------------------
INSERT INTO Stg_patio (
    Id_sistema_origem, 
    Id_patio_origem, 
    Nome_patio, 
    Cidade, 
    Uf, 
    Capacidade
)
SELECT DISTINCT
    'G1_OLTP', 
    P.Id_patio, 
    P.Nome_patio, 
    E.Cidade, 
    E.Uf, 
    P.Capacidade
FROM locadora_dw.Patio P
JOIN locadora_dw.Endereco E ON P.Id_endereco = E.Id_endereco;

-- ------------------------------------------------------------------------------
-- 2. EXTRAÇÃO: VEÍCULOS
-- ------------------------------------------------------------------------------
INSERT INTO Stg_veiculo (
    Id_sistema_origem, 
    Id_veiculo_origem, 
    Placa, 
    Marca, 
    Modelo, 
    Grupo_categoria, 
    Ano, 
    Tipo_cambio, 
    Empresa_dona
)
SELECT DISTINCT
    'G1_OLTP', 
    V.Id_veiculo, 
    V.Placa, 
    V.Marca, 
    V.Modelo, 
    C.Nome_categoria, 
    V.Ano, 
    V.Tipo_cambio, 
    Emp.Nome_empresa
FROM locadora_dw.Veiculo V
JOIN locadora_dw.Categoria C ON V.Id_categoria = C.Id_categoria
JOIN locadora_dw.Empresa Emp ON V.Id_empresa = Emp.Id_empresa;

-- ------------------------------------------------------------------------------
-- 3. EXTRAÇÃO: CLIENTES (Unificando PF e PJ)
-- ------------------------------------------------------------------------------
INSERT INTO Stg_cliente (
    Id_sistema_origem, 
    Id_cliente_origem, 
    Tipo_cliente, 
    Nome_cliente, 
    Cpf_cnpj, 
    Cidade, 
    Uf
)
SELECT DISTINCT
    'G1_OLTP', 
    C.Id_cliente, 
    C.Tipo_cliente,
    COALESCE(PF.Nome_cliente, PJ.Razao_social),
    COALESCE(PF.Cpf_cliente, PJ.Cnpj_cliente),
    E.Cidade, 
    E.Uf
FROM locadora_dw.Cliente C
JOIN locadora_dw.Endereco E ON C.Id_endereco = E.Id_endereco
LEFT JOIN locadora_dw.Cliente_pf PF ON C.Id_cliente = PF.Id_cliente
LEFT JOIN locadora_dw.Cliente_pj PJ ON C.Id_cliente = PJ.Id_cliente;

-- ------------------------------------------------------------------------------
-- 4. EXTRAÇÃO: MOTORISTAS
-- ------------------------------------------------------------------------------
INSERT INTO Stg_motorista (
    Id_sistema_origem, 
    Id_motorista_origem, 
    Nome_motorista, 
    Categoria_cnh, 
    Genero_motorista, 
    Data_nascimento
)
SELECT DISTINCT
    'G1_OLTP', 
    Id_motorista, 
    Nome_motorista, 
    Categoria_cnh, 
    Genero_motorista, 
    Data_nascimento_motorista
FROM locadora_dw.Motorista;

-- ------------------------------------------------------------------------------
-- 5. EXTRAÇÃO: LOCAÇÕES
-- ------------------------------------------------------------------------------
INSERT INTO Stg_locacao (
    Id_sistema_origem, 
    Id_locacao_origem, 
    Id_patio_retirada_origem, 
    Id_patio_devolucao_origem, 
    Id_veiculo_origem, 
    Id_cliente_origem, 
    Id_motorista_origem, 
    Data_retirada, 
    Data_devolucao, 
    Km_retirada, 
    Km_devolucao, 
    Valor_total
)
SELECT 
    'G1_OLTP', 
    L.Id_locacao, 
    L.Id_patio_real_retirada, 
    L.Id_patio_real_devolucao,
    L.Id_veiculo, 
    R.Id_cliente, 
    L.Id_motorista,
    L.Data_hora_retirada_real, 
    L.Data_hora_devolucao_real,
    L.Km_retirada, 
    L.Km_devolucao, 
    L.Valor_total_final
FROM locadora_dw.Locacao L
JOIN locadora_dw.Reserva R ON L.Id_reserva = R.Id_reserva;