-- Ana Clara de Jesus Nascimento, DRE 124388471
-- Mariana Rocha de Moraes, DRE 122147926
-- Matheus Mangia Terra Suzano, DRE 123378716
-- Paulo Henrique Cotta de Assumpção, DRE 122156268
-- Pedro Nunes de Oliveira Pessanha, DRE 123177330
-- Ryan Domingos dos Santos Saraiva, DRE 123137429

USE locadora_dw;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE locacao; TRUNCATE TABLE reserva; TRUNCATE TABLE veiculo; 
TRUNCATE TABLE motorista; TRUNCATE TABLE cliente_pf; TRUNCATE TABLE cliente_pj; 
TRUNCATE TABLE cliente; TRUNCATE TABLE patio; TRUNCATE TABLE endereco; 
TRUNCATE TABLE categoria; TRUNCATE TABLE empresa;

INSERT INTO endereco (Id_endereco, Cidade, Uf) VALUES (1, 'Rio de Janeiro', 'RJ'), (2, 'São Paulo', 'SP'), (3, 'Belo Horizonte', 'MG');
INSERT INTO categoria (Id_categoria, Nome_categoria) VALUES (1, 'SUV Compacto'), (2, 'Econômico');
INSERT INTO empresa (Id_empresa, Nome_empresa, Id_endereco) VALUES (1, 'Alpha Locadora Matriz', 1);
INSERT INTO patio (Id_patio, Nome_patio, Id_endereco, Capacidade, Id_empresa) VALUES (1, 'Agência Aeroporto Galeão', 1, 150, 1), (2, 'Agência Aeroporto Congonhas', 2, 200, 1);
INSERT INTO veiculo (Id_veiculo, Placa, Marca, Modelo, Id_categoria, Ano, Tipo_cambio, Id_empresa) VALUES (1, 'ABC1234', 'Jeep', 'Renegade', 1, 2024, 'Automático', 1), (2, 'XYZ9876', 'Fiat', 'Argo', 2, 2025, 'Manual', 1), (3, 'DEF5678', 'VW', 'T-Cross', 1, 2023, 'Automático', 1);
INSERT INTO cliente (Id_cliente, Tipo_cliente, Id_endereco) VALUES (1, 'PF', 1), (2, 'PJ', 2);
INSERT INTO cliente_pf (Id_cliente, Nome_cliente) VALUES (1, 'Ana Clara Nascimento');
INSERT INTO cliente_pj (Id_cliente, Razao_social) VALUES (2, 'Tech Solutions LTDA');
INSERT INTO motorista (Id_motorista, Nome_motorista, Categoria_cnh, Genero_motorista, Data_nascimento_motorista, Id_cliente) VALUES (1, 'Carlos Eduardo', 'B', 'M', '1995-05-15', 1), (2, 'Mariana Silva', 'AB', 'F', '2004-10-20', 2);
INSERT INTO reserva (Id_reserva, Id_cliente, Id_categoria, Id_patio_previsto_retirada, Id_patio_previsto_devolucao, Data_hora_reserva, Data_previsao_retirada, Data_previsao_devolucao, Valor_previsto, Status_reserva) VALUES 
(1, 1, 1, 1, 1, '2026-05-01 14:00:00', '2026-05-10 10:00:00', '2026-05-15 14:00:00', 1500.00, 'Concluída'), 
(2, 2, 2, 1, 2, '2026-05-05 09:30:00', '2026-05-12 08:00:00', '2026-05-18 18:00:00', 850.00, 'Concluída'), 
(3, 1, 1, 2, 1, '2026-05-15 11:15:00', '2026-05-20 09:00:00', '2026-05-25 10:00:00', 2100.00, 'Concluída');
INSERT INTO locacao (Id_locacao, Id_reserva, Id_veiculo, Id_motorista, Id_patio_real_retirada, Id_patio_real_devolucao, Data_hora_retirada_real, Data_hora_devolucao_real, Km_retirada, Km_devolucao, Valor_total_final, Status_locacao) VALUES 
(1, 1, 1, 1, 1, 1, '2026-05-10 10:00:00', '2026-05-15 14:00:00', 10000, 10500, 1500.00, 'Finalizada'),
(2, 2, 2, 2, 1, 2, '2026-05-12 08:00:00', '2026-05-18 18:00:00', 5000, 5600, 850.00, 'Finalizada'),
(3, 3, 3, 1, 2, 1, '2026-05-20 09:00:00', '2026-05-25 10:00:00', 20000, 20450, 2100.00, 'Finalizada');

SET FOREIGN_KEY_CHECKS = 1;