-- Ana Clara de Jesus Nascimento, DRE 124388471
-- Mariana Rocha de Moraes, DRE 122147926
-- Matheus Mangia Terra Suzano, DRE 123378716
-- Paulo Henrique Cotta de Assumpção, DRE 122156268
-- Pedro Nunes de Oliveira Pessanha, DRE 123177330
-- Ryan Domingos dos Santos Saraiva, DRE 123137429

USE locadora_dw_staging;

-- LIMPEZA DA STAGING AREA

TRUNCATE TABLE Stg_patio;
TRUNCATE TABLE Stg_veiculo;
TRUNCATE TABLE Stg_cliente;
TRUNCATE TABLE Stg_motorista;
TRUNCATE TABLE Stg_locacao;

-- PROCESSOS DE EXTRAÇÃO (ETL)

-- Grupo 01

INSERT INTO Stg_patio (
    Sistema_Origem,
    Id_patio_oltp, 
    Nome_patio, 
    Cidade, 
    Uf, 
    Capacidade
)
SELECT DISTINCT
    'Grupo 01', -- Identificação da base de dados de origem (nossa equipe)
    P.Id_patio, 
    P.Nome_patio, 
    E.Cidade, 
    E.Uf, 
    P.Capacidade
FROM locadora_dw.Patio P
JOIN locadora_dw.Endereco E ON P.Id_endereco = E.Id_endereco;

INSERT INTO Stg_veiculo (
    Sistema_Origem,
    Id_veiculo_oltp, 
    Placa, 
    Marca, 
    Modelo, 
    Categoria_Nome, 
    Ano, 
    Tipo_Cambio, 
    Empresa_Dona
)
SELECT DISTINCT
    'Grupo 01',
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

INSERT INTO Stg_cliente (
    Sistema_Origem,
    Id_cliente_oltp, 
    Tipo_Cliente, 
    Nome_ou_Razao_Social, 
    Cidade, 
    Uf
)
SELECT DISTINCT
    'Grupo 01',
    C.Id_cliente, 
    C.Tipo_cliente,
    COALESCE(PF.Nome_cliente, PJ.Razao_social),
    E.Cidade, 
    E.Uf
FROM locadora_dw.Cliente C
JOIN locadora_dw.Endereco E ON C.Id_endereco = E.Id_endereco
LEFT JOIN locadora_dw.Cliente_pf PF ON C.Id_cliente = PF.Id_cliente
LEFT JOIN locadora_dw.Cliente_pj PJ ON C.Id_cliente = PJ.Id_cliente;

INSERT INTO Stg_motorista (
    Sistema_Origem,
    Id_motorista_oltp, 
    Nome_motorista, 
    Categoria_Cnh, 
    Genero_motorista, 
    Data_Nascimento
)
SELECT DISTINCT
    'Grupo 01',
    Id_motorista, 
    Nome_motorista, 
    Categoria_cnh, 
    Genero_motorista, 
    Data_nascimento_motorista
FROM locadora_dw.Motorista;

INSERT INTO Stg_locacao (
    Sistema_Origem,
    Id_locacao_oltp, 
    Id_patio_retirada_oltp, 
    Id_patio_devolucao_oltp, 
    Id_veiculo_oltp, 
    Id_cliente_oltp, 
    Id_motorista_oltp, 
    Data_Retirada, 
    Data_Devolucao, 
    Km_Retirada, 
    Km_Devolucao, 
    Valor_Total
)
SELECT 
    'Grupo 01',
    L.id_locacao, 
    L.id_patio_retirada,       
    L.id_patio_devolucao,  
    L.id_veiculo, 
    R.id_cliente, 
    L.id_motorista,
    L.data_hora_retirada_real, 
    L.data_hora_devolucao_real,
    L.km_retirada, 
    L.km_devolucao, 
    L.valor_total_final
FROM locadora_dw.locacao L
JOIN locadora_dw.reserva R ON L.id_reserva = R.id_reserva;

-- Grupo 02

INSERT INTO Stg_patio (
    Sistema_Origem,
    Id_patio_oltp, 
    Nome_patio, 
    Cidade, 
    Uf, 
    Capacidade
)
SELECT 
    'Grupo 02', 
    id_patio, 
    nome_patio, 
    localizacao, -- O modelo deles não separa cidadeo
    NULL,        -- O modelo deles não possui UF separada para o pátio
    NULL         -- O modelo deles não armazena a capacidade de vagas
FROM db_grupo_02.PATIO;

INSERT INTO Stg_veiculo (
    Sistema_Origem,
    Id_veiculo_oltp, 
    Placa, 
    Marca, 
    Modelo, 
    Categoria_Nome, 
    Ano, 
    Tipo_Cambio, 
    Empresa_Dona
)
SELECT 
    'Grupo 02', 
    V.id_veiculo, 
    V.placa, 
    V.marca, 
    V.modelo, 
    GV.nome_grupo,   -- Nome do grupo vem da tabela GRUPO_VEICULO
    NULL,            -- O modelo deles não possui o Ano do veículo
    V.mecanizacao,   -- Mapeamos "mecanizacao" para a nossa coluna "Tipo_Cambio"
    E.nome_empresa   -- Trazendo o nome da dona através do JOIN
FROM db_grupo_02.VEICULO V
JOIN db_grupo_02.GRUPO_VEICULO GV ON V.id_grupo = GV.id_grupo
JOIN db_grupo_02.EMPRESA E ON V.id_empresa = E.id_empresa;

INSERT INTO Stg_cliente (
    Sistema_Origem, 
    Id_cliente_oltp, 
    Tipo_Cliente, 
    Nome_ou_Razao_Social, 
    Cidade, 
    Uf
)
SELECT 
    'Grupo 02', 
    id_cliente, 
    tipo_cliente, 
    nome_razao_social, 
    cidade, 
    estado
FROM db_grupo_02.CLIENTE;

INSERT INTO Stg_motorista (
    Sistema_Origem, 
    Id_motorista_oltp, 
    Nome_motorista, 
    Categoria_Cnh, 
    Genero_motorista, 
    Data_Nascimento
)
SELECT 
    'Grupo 02', 
    id_condutor, 
    nome_condutor, 
    categoria_cnh, 
    NULL, -- O modelo deles não armazena o Gênero
    NULL  -- O modelo deles não armazena a Data de Nascimento
FROM db_grupo_02.CONDUTOR;

INSERT INTO Stg_locacao (
    Sistema_Origem, 
    Id_locacao_oltp,
    Id_patio_retirada_oltp, 
    Id_patio_devolucao_oltp, 
    Id_veiculo_oltp, 
    Id_cliente_oltp, 
    Id_motorista_oltp, 
    Data_Retirada, 
    Data_Devolucao, 
    Km_Retirada, 
    Km_Devolucao, 
    Valor_Total
)
SELECT 
    'Grupo 02', 
    id_locacao, 
    id_patio_retirada, 
    id_patio_devolucao_real, 
    id_veiculo, 
    id_cliente, 
    id_condutor, 
    data_hora_retirada, 
    data_hora_real_devolucao, 
    NULL, -- O modelo deles não armazena quilometragem
    NULL, -- O modelo deles não armazena quilometragem
    valor_final
FROM db_grupo_02.LOCACAO;

-- Grupo 03

INSERT INTO Stg_patio (
    Sistema_Origem, 
    Id_patio_oltp, 
    Nome_patio, 
    Cidade, 
    Uf, 
    Capacidade
)
SELECT 
    'Grupo 03', 
    P.Id_patio, 
    P.Nome_patio, 
    E.Cidade, 
    E.UF, 
    NULL -- O modelo deles não possui capacidade total na tabela de Pátio
FROM db_grupo_03.Patio P
JOIN db_grupo_03.Endereco E ON P.Id_endereco = E.Id_endereco;

INSERT INTO Stg_veiculo (
    Sistema_Origem, 
    Id_veiculo_oltp, 
    Placa, 
    Marca, 
    Modelo, 
    Categoria_Nome,
    Ano, 
    Tipo_Cambio, 
    Empresa_Dona
)
SELECT 
    'Grupo 03', 
    V.Id_veiculo, 
    V.Placa, 
    V.Marca, 
    V.Modelo, 
    V.Categoria, 
    CAST(V.Ano AS UNSIGNED), -- Garantindo a tipagem de CHAR(4) para INT
    CASE WHEN SC.Direcao_automatica = 1 THEN 'Automático' ELSE 'Manual' END, -- Mapeando o campo de direção automática para o tipo de câmbio
    'Grupo 03 S.A.' -- O veículo deles não tem ligação direta com a empresa, assumimos uma empresa genérica para todos os veículos do grupo
FROM db_grupo_03.Veiculo V
JOIN db_grupo_03.Especificacoes_const SC ON V.Id_spec_const = SC.Id_spec_const;


INSERT INTO Stg_cliente (
    Sistema_Origem, 
    Id_cliente_oltp, 
    Tipo_Cliente, 
    Nome_ou_Razao_Social, 
    Cidade, 
    Uf
)
SELECT 
    'Grupo 03', 
    C.Id_cliente, 
    'PF', -- No modelo deles, todos os clientes são Pessoas Físicas - PF
    C.Nome_completo, 
    E.Cidade, 
    E.UF
FROM db_grupo_03.Cliente C
JOIN db_grupo_03.Endereco E ON C.Id_endereco = E.Id_endereco;

INSERT INTO Stg_motorista (
    Sistema_Origem, 
    Id_motorista_oltp, 
    Nome_motorista, 
    Categoria_Cnh, 
    Genero_motorista, 
    Data_Nascimento
)
SELECT 
    'Grupo 03', 
    C.Id_cliente, -- Como eles não separam motorista, o cliente vira o motorista
    C.Nome_completo, 
    'ND', -- "Não Declarado": O grupo não armazena a Categoria
    LEFT(C.Genero, 1), -- Pega apenas a primeira letra do gênero para se adequar ao nosso modelo
    C.Data_nascimento
FROM db_grupo_03.Cliente C;

INSERT INTO Stg_locacao (
    Sistema_Origem, Id_locacao_oltp, Id_patio_retirada_oltp, Id_patio_devolucao_oltp, 
    Id_veiculo_oltp, Id_cliente_oltp, Id_motorista_oltp, Data_Retirada, Data_Devolucao, 
    Km_Retirada, Km_Devolucao, Valor_Total
)
SELECT 
    'Grupo 03', 
    L.Id_locacao, 
    L.Id_patio, -- Pátio real de retirada
    COALESCE(Vag.Id_patio, R.Id_patio_fim), -- Pátio real de devolução (via Vaga) ou o previsto na Reserva caso não devolvido
    L.Id_veiculo, 
    R.Id_cliente, 
    R.Id_cliente, -- Motorista é o próprio cliente
    L.Data_locacao, 
    D.Data_devolucao, 
    NULL, -- O modelo deles não controla quilometragem
    NULL, 
    R.Preco_final
FROM db_grupo_03.Locacao L
JOIN db_grupo_03.Reserva R ON L.Id_reserva = R.Id_reserva
LEFT JOIN db_grupo_03.Devolucao D ON L.Id_locacao = D.Id_locacao
LEFT JOIN db_grupo_03.Vaga Vag ON D.Id_vaga = Vag.Id_vaga;

-- Grupo 04

INSERT INTO Stg_patio (
    Sistema_Origem, 
    Id_patio_oltp, 
    Nome_patio, 
    Cidade, 
    Uf, 
    Capacidade
)
SELECT 
    'Grupo 04', 
    id_patio, 
    endereco, -- Usando o endereço como nome para não ficar em branco
    endereco, -- Jogamos a string inteira na cidade, pois não há separação
    NULL, 
    n_vagas -- O modelo deles armazena a capacidade como número de vagas
FROM db_grupo_04.patio;

-- Muita informação faltando aqui, mas preenchemos o que temos e deixamos o resto como NULL.
INSERT INTO Stg_veiculo (
    Sistema_Origem, 
    Id_veiculo_oltp, 
    Placa, 
    Marca, 
    Modelo, 
    Categoria_Nome, 
    Ano, 
    Tipo_Cambio, 
    Empresa_Dona
)
SELECT 
    'Grupo 04', 
    id_veiculo, 
    placa, 
    NULL, -- Não há marca no modelo
    modelo, 
    NULL, -- Categoria só existe na tabela de Reserva deles, não no veículo
    NULL, -- Não há ano
    NULL, -- Não há tipo de câmbio
    'Grupo 04 S.A.' 
FROM db_grupo_04.veiculo;

INSERT INTO Stg_cliente (
    Sistema_Origem, 
    Id_cliente_oltp, 
    Tipo_Cliente, 
    Nome_ou_Razao_Social, 
    Cidade, 
    Uf
)
SELECT 
    'Grupo 04', 
    id_cliente, 
    CASE WHEN CHAR_LENGTH(REPLACE(REPLACE(REPLACE(cpf_cnpj, '.', ''), '-', ''), '/', '')) > 11 THEN 'PJ' ELSE 'PF' END, 
    nome, 
    NULL, -- Endereço do cliente não é armazenado no modelo deles
    NULL
FROM db_grupo_04.cliente;

-- Assim como no Grupo 03, o cliente é o próprio motorista.
INSERT INTO Stg_motorista (
    Sistema_Origem, 
    Id_motorista_oltp, 
    Nome_motorista, 
    Categoria_Cnh, 
    Genero_motorista, 
    Data_Nascimento
)
SELECT 
    'Grupo 04', 
    id_cliente, 
    nome, 
    NULL, -- Eles têm o número da CNH, mas não a Categoria (A, B, C...)
    NULL, -- Não armazenam Gênero
    data_nascimento
FROM db_grupo_04.cliente;

-- Precisamos fazer um JOIN com a tabela de pagamento deles para conseguir o "Valor_Total".
INSERT INTO Stg_locacao (
    Sistema_Origem, 
    Id_locacao_oltp, 
    Id_patio_retirada_oltp, 
    Id_patio_devolucao_oltp, 
    Id_veiculo_oltp, 
    Id_cliente_oltp, 
    Id_motorista_oltp, 
    Data_Retirada, 
    Data_Devolucao, 
    Km_Retirada, 
    Km_Devolucao, 
    Valor_Total
)
SELECT 
    'Grupo 04', 
    L.id_locacao, 
    L.id_patio_retirada, 
    L.id_patio_devolucao, 
    L.id_veiculo, 
    L.id_cliente, 
    L.id_cliente, -- O motorista é o cliente
    L.data_retirada, 
    L.data_devolucao, 
    NULL, 
    NULL, 
    P.valor -- Trazendo o valor da tabela de pagamento
FROM db_grupo_04.locacao L
LEFT JOIN (
    SELECT id_locacao, SUM(valor) AS valor_total 
    FROM db_grupo_04.pagamento 
    GROUP BY id_locacao
) P ON L.id_locacao = P.id_locacao;