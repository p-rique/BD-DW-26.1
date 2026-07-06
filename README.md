# 🚗 Projeto de Banco de Dados e Big Data — Consórcio de Locadoras de Veículos

## 📌 Sobre o Projeto
Este repositório reúne as três etapas do trabalho da disciplina de Banco de Dados, desenvolvidas para um consórcio de 6 empresas associadas de locação de automóveis:

1. **Parte I — OLTP:** banco de dados transacional, normalizado, para as operações centrais do negócio (clientes, frota, reservas, locações, pátios compartilhados e cobrança).
2. **Parte II — OLAP / Data Warehouse:** modelagem dimensional (esquema estrela) e pipeline de ETL para consolidar os dados operacionais em uma base analítica.
3. **Parte III — Big Data:** proposta executiva de arquitetura de Big Data, IoT e Inteligência Artificial para a nova frota de veículos conectados, com ingestão em tempo real, processamento híbrido (batch/stream) e um dashboard operacional.

---

## 🛠️ Tecnologias Utilizadas

| Camada | Tecnologias |
|---|---|
| OLTP | MySQL, ANSI SQL (SQL99+) |
| Modelagem | draw.io, MySQL Workbench |
| DW / ETL | MySQL, Staging Area, scripts SQL de extração/transformação/carga |
| Big Data (proposta) | Apache Kafka, Apache Spark, Apache Flink, Hadoop MapReduce, Cassandra, Redis, MongoDB Atlas, Delta Lake |
| IA (proposta) | OpenAI Whisper (STT), GPT-4o, OpenAI TTS, RAG com busca vetorial |

---

## 📂 Estrutura do Repositório

```text
├── parte1_oltp/                          # Módulo Transacional (Operacional)
│   ├── modelos/
│   │   ├── locadora_trabalho_bg_dw.mwb.zip   # Arquivo de modelagem do MySQL Workbench
│   │   ├── Modelo Conceitual.drawio.pdf      # Diagrama Conceitual (MER)
│   │   └── Modelo Logico.pdf                 # Diagrama Lógico Relacional
│   ├── scripts_sql/
│   │   └── script-modelagem.sql              # Script DDL de criação da base OLTP
│   └── Projeto Modelagem SBD OLTP.pdf        # Relatório descritivo do projeto operacional
│
├── parte2_olap/                          # Módulo Analítico (Data Warehouse)
│   ├── Modelo_Dimensional_Estrela.pdf        # Diagrama do esquema estrela do DW
│   ├── Desenvolvimento_Processo_ETL.pdf      # Relatório descritivo do processo de ETL
│   └── scripts_sql/
│       ├── 00_script_carregar_dados_(oltp).sql   # Carga de dados de exemplo na base OLTP
│       ├── 01_script-dw.sql                      # Criação das Dimensões e Fato do DW
│       ├── 02_script-staging.sql                 # Criação das tabelas da Staging Area
│       ├── 03_script-extract.sql                 # Extração dos dados do OLTP para a Staging
│       ├── 04_transformacao_e_carga.sql          # Transformação e carga da Staging para o DW
│       └── 05_script_relatorios_e_matriz.sql     # Consultas analíticas e relatórios sobre o DW
│
├── parte3_bigdata/                       # Proposta Executiva de Big Data (Parte III)
│   ├── Proposta_Executiva_BigData_Parte3.tex     # Fonte LaTeX da proposta (compilável no Overleaf)
│   ├── Proposta_Executiva_BigData_Parte3.pdf     # Proposta executiva compilada (PDF final)
│   └── slides_apresentacao_parte3.pdf            # Slides usados na defesa oral
│
├── docs/
│   └── Dicionario_de_Dados.pdf           # Dicionário de dados completo (atributos e tabelas)
│
└── README.md                             # Este arquivo
```

---

## 📐 Destaques de Modelagem por Parte

### Parte I — OLTP
- **Especialização de Clientes (Herança):** separação de Clientes Pessoa Física (PF) e Pessoa Jurídica (PJ) através de tabelas especializadas compartilhando a mesma chave primária.
- **Flexibilidade de Motoristas:** vinculação de motoristas independentes e associados a contas corporativas (PJ).
- **Pátios Compartilhados:** modelagem das tabelas `Veiculo` e `Patio` já prevendo a identificação da empresa "dona" da frota, permitindo operação compartilhada entre as 6 marcas do consórcio.

### Parte II — OLAP / Data Warehouse
- Esquema estrela com tabela fato `fato_locacao` (métricas: `qtd_locacao`, `km_rodados`, `valor_total`) e dimensões `dim_veiculo`, `dim_cliente`, `dim_motorista`, `dim_patio`, `dim_tempo`, `dim_categoria`.
- Pipeline de ETL completo: extração do OLTP → staging → transformação/carga → DW.

### Parte III — Big Data
- Arquitetura Lambda (Hot Path + Cold Path), com Kafka para ingestão, Flink para eventos críticos em tempo real, Spark para manutenção preditiva e MapReduce para processamento histórico de exaustão.
- Persistência poliglota: Data Lake (S3), Cassandra, Redis e MongoDB Atlas.
- Dashboard com 6 painéis operacionais e especificação funcional de um assistente de IA por voz (RAG).
- A camada de Big Data se conecta ao Data Warehouse da Parte II (mantido em MySQL) através do fluxo Cold Path, sem substituir a infraestrutura relacional já validada.

---

## 👥 Integrantes
Ana Clara de Jesus Nascimento, Mariana Rocha de Moraes, Matheus Mangia Terra Suzano, Paulo Henrique Cotta de Assumpção, Pedro Nunes de Oliveira Pessanha, Ryan Domingos dos Santos Saraiva

DRE: 124388471, 122147926, 123378716, 122156268, 123177330, 123137429
