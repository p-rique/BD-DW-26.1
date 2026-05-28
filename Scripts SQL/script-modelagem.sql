/* Script do Modelo Fisico do Banco de Dados
Utilizado para controle e pesquisa dos dados adquiridos.

Por: Ana Clara de Jesus, Mariana Rocha, Matheus Mangia, Paulo Cotta, Pedro Nunes e Ryan Domingos
DRE: 124388471, 122147926, 123378716, 122156268, 123177330, 123137429
*/

-- Criação do banco de dados

create database locadora;
use locadora;

-- Descrição das unidades físicas
create table patio (
    id_patio int primary key auto_increment,
    nome_patio varchar(100) not null,
    endereco_patio varchar(200) not null,
    capacidade int
);

-- Catalogação das vagas em cada pátio
create table vaga (
    id_vaga int primary key auto_increment,
    id_patio int not null,
    codigo_vaga varchar(8) not null, -- ex.: GIG-123,
    disponibilidade_vaga char(1) default 'L' check (disponibilidade in ('L', 'O')), -- Livre ou Ocupada
    foreign key (id_patio) references patio(id_patio)
);

-- Tabela de base dos locatários, com informações comuns a PF e PJ
create table cliente (
    id_cliente int primary key auto_increment,
    tipo_cliente char(2) not null check (tipo_cliente in ('PF', 'PJ')), -- PF ou PJ
    email_cliente varchar(100) unique not null,
    telefone_cliente varchar(11),
    bairro varchar(50),
    cidade varchar(50),
    estado char(2)
);

-- Tipos de clientes: Pessoa Física e Pessoa Jurídica
create table cliente_pf (
    id_cliente int primary key,
    nome_cliente varchar(100) not null,
    cpf_cliente varchar(11) not null unique,
    data_nascimento date,
    foreign key (id_cliente) references cliente(id_cliente)
);

create table cliente_pj (
    id_cliente int primary key,
    razao_social varchar(100) not null,
    nome_fantasia varchar(100) not null,
    cnpj varchar(14) not null unique,
    foreign key (id_cliente) references cliente(id_cliente)
);

-- Dados dos motoristas vinculados aos clientes
create table motorista (
    id_motorista int primary key auto_increment,
    id_cliente int not null,
    nome_motorista varchar(100) not null,
    numero_cnh varchar(20) not null unique,
    categoria_cnh char(3) not null check (categoria_cnh in ('A', 'B', 'C', 'D', 'E', 'ACC')),
    validade_cnh date not null,
    email_motorista varchar(100) unique not null,
    telefone_motorista varchar(11),
    genero char(1) not null check (genero in ('M', 'F', 'O')), -- Masculino, Feminino ou Outro
    data_nascimento date not null,
    relacao_motorista_cliente varchar(20) not null, -- ex.: contratado, familiar, amigo, etc.
    foreign key (id_cliente) references cliente(id_cliente)
);

-- Catalogação dos preços por categoria
create table categoria (
    id_categoria int primary key auto_increment,
    nome_categoria varchar(50),
    valor_diaria decimal(10,2)
);

-- Dados da frota disponível para locação
create table veiculo (
    id_veiculo int primary key auto_increment,
    id_categoria int not null,
    placa varchar(7) not null unique, -- ex.: ABC1D23
    marca varchar(50) not null,
    modelo varchar(50) not null,
    ano int not null,
    cor varchar(20),
    km_atual int, -- Quilometragem atual do veículo
    foto text, -- URL da foto do veículo
    status_veiculo VARCHAR(20) DEFAULT 'Disponível' CHECK (status_veiculo IN ('Disponível', 'Alugado', 'Manutenção', 'Vendido')),
    foreign key (id_categoria) references categoria(id_categoria)
);

-- Acessórios disponíveis para os veículos
create table acessorios (
    id_acessorio int primary key,
    nome_acessorio varchar(50) not null
);

-- Ligação veículo-acessório (N:N)
create table veiculo_acessorios (
    id_veiculo int,
    id_acessorio int,
    primary key (id_veiculo, id_acessorio),
    foreign key (id_veiculo) references veiculo(id_veiculo),
    foreign key (id_acessorio) references acessorios(id_acessorio)
);

-- Manutenção dos veículos
create table manutencao (
    id_manutencao int primary key auto_increment,
    id_veiculo int not null,
    data_revisao date,
    pressao_pneus varchar(20),
    nivel_oleo varchar(20),
    km_manutencao int,
    descricao text,
    foreign key (id_veiculo) references veiculo(id_veiculo)
);

-- Dados das reservas
create table reserva (
    id_reserva int primary key auto_increment,
    id_cliente int not null,
    id_categoria int not null,
    id_patio_retirada int not null,
    data_reserva timestamp default current_timestamp,
    data_previsao_retirada datetime not null,
    data_previsao_devolucao datetime not null,
    valor_previsto decimal(10,2),
    status_reserva char(1) default 'A' check (status_reserva in ('A', 'C', 'F')), -- Verifica se a reserva está Ativa, Cancelada ou Finalizada
    foreign key (id_cliente) references cliente(id_cliente),
    foreign key (id_categoria) references categoria(id_categoria),
    foreign key (id_patio_retirada) references patio(id_patio)
);

-- Dados sobre a transação de locação
create table locacao (
    id_locacao int primary key auto_increment,
    id_reserva int not null,
    id_veiculo int not null,
    id_motorista int not null,
    id_patio_retirada int not null,
    id_patio_devolucao int, -- Preencher após devolução
    data_retirada datetime not null,
    data_devolucao datetime, -- Preencher após devolução
    km_retirada int not null,
    km_devolucao int, -- Preencher após devolução
    combustivel_retirada varchar(20) not null,
    combustivel_devolucao varchar(20), -- Preencher após devolução
    valor_total decimal(10,2), -- Preencher após devolução
    status_locacao char(1) default 'A' check (status_locacao in ('A', 'C', 'F')), -- Verifica se a locação está Ativa, Cancelada ou Finalizada
    foreign key (id_reserva) references reserva(id_reserva),
    foreign key (id_veiculo) references veiculo(id_veiculo),
    foreign key (id_motorista) references motorista(id_motorista),
    foreign key (id_patio_retirada) references patio(id_patio),
    foreign key (id_patio_devolucao) references patio(id_patio)
);