# K-means 1D - Paralelização Progressiva

Projeto de Programação Concorrente e Distribuída (PCD)  
**Etapas 0 e 1**: Versão Serial (Baseline) e OpenMP

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Estrutura do Projeto](#estrutura-do-projeto)
3. [Requisitos](#requisitos)
4. [Compilação](#compilação)
5. [Execução](#execução)
6. [Resultados Esperados](#resultados-esperados)
7. [Análise de Desempenho](#análise-de-desempenho)
8. [Validação](#validação)

---

## 🎯 Visão Geral

Implementação do algoritmo K-means para clusterização de dados 1D, com paralelização progressiva:

- **Etapa 0**: Versão sequencial (baseline)
- **Etapa 1**: Versão OpenMP (CPU com memória compartilhada)
- **Etapa 2**: Versão CUDA (GPU) - *futuro*
- **Etapa 3**: Versão MPI (memória distribuída) - *futuro*

### Algoritmo

O K-means realiza clustering iterativo:

1. **Assignment**: Para cada ponto, encontra o centróide mais próximo (minimiza distância euclidiana)
2. **Update**: Recalcula centróides como média dos pontos de cada cluster
3. **Convergência**: Repete até variação do SSE < ε ou atingir max_iter

---

## 📁 Estrutura do Projeto

```
kmeans_1d/
├── README.md
├── compile.sh              # Script de compilação
├── run_tests.sh           # Script de execução e benchmark
├── generate_data.sh       # Gera datasets de teste
│
├── serial/
│   └── kmeans_1d_serial.c # Versão sequencial (Etapa 0)
│
├── openmp/
│   └── kmeans_1d_omp.c    # Versão OpenMP (Etapa 1)
│
├── data/                  # Datasets gerados
│   ├── dados_teste.csv
│   ├── centroides_teste.csv
│   ├── dados_pequeno.csv
│   ├── centroides_pequeno.csv
│   ├── dados_medio.csv
│   ├── centroides_medio.csv
│   ├── dados_grande.csv
│   └── centroides_grande.csv
│
├── bin/                   # Binários compilados
│   ├── kmeans_1d_serial
│   └── kmeans_1d_omp
│
└── results/               # Resultados das execuções
    ├── serial/
    ├── openmp/
    └── benchmarks/
        └── speedup_results.csv
```

---

## 🔧 Requisitos

### Software

- **GCC** >= 7.0 com suporte a OpenMP
- **Bash** para scripts
- **bc** para cálculos no script de benchmark

### Verificação

```bash
# Verificar GCC
gcc --version

# Verificar suporte OpenMP
echo '#include <omp.h>' | gcc -fopenmp -x c -E - > /dev/null && echo "OpenMP: OK" || echo "OpenMP: ERRO"

# Verificar bc
which bc
```

---

## 🛠️ Compilação

### Passo 1: Gerar Dados de Teste

```bash
chmod +x generate_data.sh
./generate_data.sh
```

Isso cria:
- Dataset **TESTE**: 20 pontos, 4 clusters (validação rápida)
- Dataset **PEQUENO**: 10.000 pontos, 4 clusters
- Dataset **MÉDIO**: 100.000 pontos, 8 clusters
- Dataset **GRANDE**: 1.000.000 pontos, 16 clusters

### Passo 2: Compilar Código

```bash
chmod +x compile.sh
./compile.sh
```

Gera binários em `bin/`:
- `kmeans_1d_serial` (versão sequencial)
- `kmeans_1d_omp` (versão OpenMP)

### Compilação Manual (Alternativa)

```bash
# Versão Serial
gcc -O2 -std=c99 -Wall serial/kmeans_1d_serial.c -o bin/kmeans_1d_serial -lm

# Versão OpenMP
gcc -O2 -std=c99 -Wall -fopenmp openmp/kmeans_1d_omp.c -o bin/kmeans_1d_omp -lm
```

---

## ▶️ Execução

### Execução Automática (Recomendado)

```bash
chmod +x run_tests.sh
./run_tests.sh
```

Este script:
1. Executa a versão **serial** em todos os datasets (Etapa 0)
2. Executa a versão **OpenMP** com 1, 2, 4, 8, 16 threads (Etapa 1)
3. Calcula **speedup** e **eficiência**
4. Salva resultados em `results/benchmarks/speedup_results.csv`

### Execução Manual

#### Versão Serial

```bash
./bin/kmeans_1d_serial dados.csv centroides.csv [max_iter] [eps] [assign.csv] [centroids.csv]
```

**Exemplo:**
```bash
./bin/kmeans_1d_serial data/dados_teste.csv data/centroides_teste.csv 100 1e-6 \
    results/serial/assign.csv results/serial/centroids.csv
```

#### Versão OpenMP

```bash
./bin/kmeans_1d_omp dados.csv centroides.csv [threads] [max_iter] [eps] [assign.csv] [centroids.csv]
```

**Exemplo:**
```bash
./bin/kmeans_1d_omp data/dados_pequeno.csv data/centroides_pequeno.csv 8 100 1e-6 \
    results/openmp/assign.csv results/openmp/centroids.csv
```

---

## 📊 Resultados Esperados

### Etapa 0: Versão Serial (Baseline)

**Saída esperada:**
```
========================================
K-means 1D - Versão SERIAL (Baseline)
========================================
Parâmetros:
  N = 10000 pontos
  K = 4 clusters
  max_iter = 100
  eps = 1e-06

Resultados:
  Iterações: 12
  SSE final: 415234.125000
  Tempo: 45.23 ms
  Throughput: 221.08 pontos/ms

SSE por iteração:
  [  0] SSE = 823456.250000
  [  1] SSE = 625123.750000 (Δ = -198332.500000)
  [  2] SSE = 487965.125000 (Δ = -137158.625000)
  ...
  [ 12] SSE = 415234.125000 (Δ = -0.000124)
```

### Etapa 1: Versão OpenMP

**Speedup esperado** (depende do hardware):

| Dataset | 1 Thread | 2 Threads | 4 Threads | 8 Threads | 16 Threads |
|---------|----------|-----------|-----------|-----------|------------|
| Pequeno | 1.00x    | 1.85x     | 3.42x     | 5.89x     | 8.12x      |
| Médio   | 1.00x    | 1.92x     | 3.71x     | 6.85x     | 11.23x     |
| Grande  | 1.00x    | 1.95x     | 3.84x     | 7.42x     | 13.56x     |

**Eficiência esperada:**
- 2 threads: ~90-95%
- 4 threads: ~85-90%
- 8 threads: ~75-85%
- 16 threads: ~50-70%

---

## 📈 Análise de Desempenho

### Métricas Calculadas

1. **Speedup**: `S = T_serial / T_parallel`
2. **Eficiência**: `E = S / P × 100%` (onde P = número de threads)
3. **Throughput**: `pontos/ms`

### Arquivo de Resultados

`results/benchmarks/speedup_results.csv`:

```csv
Dataset,Threads,Time_ms,SSE,Iters,Speedup,Efficiency
pequeno,1,45.23,415234.12,12,1.00,100.00
pequeno,2,24.87,415234.12,12,1.82,91.00
pequeno,4,13.21,415234.12,12,3.42,85.50
...
```

### Gráficos Recomendados

1. **Speedup vs. Threads** (por dataset)
2. **Eficiência vs. Threads**
3. **Tempo de execução vs. Threads** (escala log)
4. **Strong Scaling** (tempo fixo, aumenta threads)

---

## ✅ Validação

### Checklist de Validação

- [ ] **SSE não aumenta** entre iterações (deve convergir)
- [ ] **SSE é igual** entre versões serial e OpenMP (±0.01%)
- [ ] **Número de iterações** é igual entre versões
- [ ] **Speedup > 1** para threads > 1
- [ ] **Eficiência diminui** com mais threads (esperado)

### Validação Manual

```bash
# 1. Executar serial
./bin/kmeans_1d_serial data/dados_teste.csv data/centroides_teste.csv 100 1e-6 \
    results/serial/assign.csv results/serial/centroids.csv > serial_output.txt

# 2. Executar OpenMP com 4 threads
./bin/kmeans_1d_omp data/dados_teste.csv data/centroides_teste.csv 4 100 1e-6 \
    results/openmp/assign.csv results/openmp/centroids.csv > omp_output.txt

# 3. Comparar SSE
grep "SSE final" serial_output.txt
grep "SSE final" omp_output.txt

# 4. Comparar assignments (devem ser idênticos)
diff results/serial/assign.csv results/openmp/assign.csv
```

---

## 🔍 Análise de Schedule

O código OpenMP usa `schedule(static)` por padrão. Para testar outras estratégias:

### Modificar o Código

Em `openmp/kmeans_1d_omp.c`, linha ~135:

```c
// Opção A: Static (padrão)
#pragma omp parallel for schedule(static) reduction(+:sse)

// Opção B: Static com chunk
#pragma omp parallel for schedule(static, 1000) reduction(+:sse)

// Opção C: Dynamic
#pragma omp parallel for schedule(dynamic) reduction(+:sse)

// Opção D: Dynamic com chunk
#pragma omp parallel for schedule(dynamic, 1000) reduction(+:sse)

// Opção E: Guided
#pragma omp parallel for schedule(guided) reduction(+:sse)
```

### Recompilar e Testar

```bash
./compile.sh
./run_tests.sh
```

### Comparar Resultados

- **Static**: Melhor para workload balanceado
- **Dynamic**: Melhor para workload irregular
- **Guided**: Compromisso entre static e dynamic

---

## 🐛 Troubleshooting

### Erro: "OpenMP não encontrado"

```bash
# Instalar OpenMP no Ubuntu/Debian
sudo apt-get install libomp-dev

# Instalar no macOS
brew install libomp
```

### Erro: "bc: command not found"

```bash
# Instalar bc
sudo apt-get install bc  # Ubuntu/Debian
brew install bc          # macOS
```

### Desempenho Ruim

1. Verificar carga da CPU: `htop`
2. Desabilitar hyperthreading se necessário
3. Fixar CPU affinity: `OMP_PROC_BIND=true`

---

## 📚 Referências

1. Lloyd, S. (1982). "Least squares quantization in PCM". IEEE Transactions on Information Theory.
2. Chapman, B., Jost, G., & Van Der Pas, R. (2007). "Using OpenMP: portable shared memory parallel programming".
3. OpenMP Documentation: https://www.openmp.org/

---

## 👥 Autor

Desenvolvido para o curso de Programação Concorrente e Distribuída.

---

## 📝 Próximas Etapas

- [ ] **Etapa 2**: Implementar versão CUDA (GPU)
- [ ] **Etapa 3**: Implementar versão MPI (distribuída)
- [ ] Comparar desempenho entre todas as versões
- [ ] Gerar relatório completo com gráficos