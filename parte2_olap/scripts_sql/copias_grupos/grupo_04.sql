Integrantes: (TED-B MAE016)
Izabela Lima    DRE 124156557
Caio Meirelles  DRE 122071557
_______________________________________________________________________

</> SQL

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100),
    data_nascimento DATE,
    cpf_cnpj VARCHAR(20),
    cnh VARCHAR(20),
    validade_cnh DATE
);

CREATE TABLE patio (
    id_patio INT PRIMARY KEY,
    endereco VARCHAR(100),
    n_vagas INT
);

CREATE TABLE veiculo (
    id_veiculo INT PRIMARY KEY,
    id_patio INT,
    id_vaga VARCHAR(50),
    modelo VARCHAR(50),
    placa VARCHAR(20),
    FOREIGN KEY (id_patio) REFERENCES patio(id_patio)
);

CREATE TABLE movimentacao (
    id_movimentacao INT PRIMARY KEY,
    id_veiculo INT,
    id_patio_origem INT,
    id_patio_destino INT,
    data_movimentacao DATE,
    FOREIGN KEY (id_veiculo) REFERENCES veiculo(id_veiculo),
    FOREIGN KEY (id_patio_origem) REFERENCES patio(id_patio),
    FOREIGN KEY (id_patio_destino) REFERENCES patio(id_patio)
);

CREATE TABLE reserva (
    id_reserva INT PRIMARY KEY,
    id_cliente INT,
    id_patio_retirada INT,
    categoria_veiculo VARCHAR(50),
    data_inicio DATE,
    data_fim DATE,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_patio_retirada) REFERENCES patio(id_patio)
);

CREATE TABLE locacao (
    id_locacao INT PRIMARY KEY,
    id_cliente INT,
    id_veiculo INT,
    id_patio_retirada INT,
    id_patio_devolucao INT,
    data_retirada DATE,
    data_devolucao DATE,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_veiculo) REFERENCES veiculo(id_veiculo),
    FOREIGN KEY (id_patio_retirada) REFERENCES patio(id_patio),
    FOREIGN KEY (id_patio_devolucao) REFERENCES patio(id_patio)
);

CREATE TABLE pagamento (
    id_pagamento INT PRIMARY KEY,
    id_locacao INT,
    data_pagamento DATE,
    valor DECIMAL (10,2),
    FOREIGN KEY (id_locacao) REFERENCES locacao(id_locacao)
);
