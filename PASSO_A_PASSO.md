# 📝 K-means 1D - Passo a Passo Completo

## Etapas 0 e 1 do Projeto

---

## 🎯 Objetivo

Este guia mostra **exatamente** como executar as Etapas 0 (Serial) e 1 (OpenMP) do projeto K-means 1D.

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter:

- **Linux** (Ubuntu, Debian, ou WSL no Windows)
- **GCC** com suporte OpenMP
- **Bash**
- **bc** (calculadora de linha de comando)
- **Python 3** (opcional, para gráficos)

---

## 🚀 Passo 1: Organizar Arquivos

Crie a seguinte estrutura de diretórios:

```
kmeans_1d/
├── serial/
│   └── kmeans_1d_serial.c
├── openmp/
│   └── kmeans_1d_omp.c
├── setup.sh
├── generate_data.sh
├── compile.sh
├── run_tests.sh
└── plot_results.py
```

**Ação:**
```bash
mkdir -p kmeans_1d
cd kmeans_1d
mkdir -p serial openmp
```

Copie cada código do artifact para o arquivo correspondente.

---

## 🔧 Passo 2: Configurar Ambiente

Execute o script de setup:

```bash
chmod +x setup.sh
./setup.sh
```

**O que esse script faz:**
- ✓ Verifica se GCC está instalado
- ✓ Verifica suporte OpenMP
- ✓ Cria diretórios necessários
- ✓ Configura permissões
- ✓ Testa compilação

**Resultado esperado:**
```
========================================
K-means 1D - Setup Inicial
========================================

1. Verificando dependências...

✓ gcc encontrado
   Versão: gcc (Ubuntu 11.3.0-1ubuntu1~22.04) 11.3.0
   Testando OpenMP... OK
✓ bc encontrado
✓ bash encontrado

2. Criando estrutura de diretórios...
   ...

Setup Concluído!
```

**Se houver erros:**

```bash
# Instalar GCC e OpenMP
sudo apt-get update
sudo apt-get install build-essential libomp-dev bc

# Rodar setup novamente
./setup.sh
```

---

## 📊 Passo 3: Gerar Dados de Teste

Execute o script para gerar datasets:

```bash
./generate_data.sh
```

**O que acontece:**
- Cria `data/` com 4 conjuntos de dados
- **Teste**: 20 pontos (validação rápida)
- **Pequeno**: 10.000 pontos
- **Médio**: 100.000 pontos  
- **Grande**: 1.000.000 pontos

**Resultado esperado:**
```
Gerando dados de teste para K-means 1D...
Dataset gerado: data/dados_teste.csv e data/centroides_teste.csv
Dataset gerado: data/dados_pequeno.csv e data/centroides_pequeno.csv
Dataset gerado: data/dados_medio.csv e data/centroides_medio.csv
Dataset gerado: data/dados_grande.csv e data/centroides_grande.csv

Dados gerados com sucesso!
```

**Verificar:**
```bash
ls -lh data/
# Você deve ver 8 arquivos CSV
```

---

## 🔨 Passo 4: Compilar Código

Compile as versões serial e OpenMP:

```bash
./compile.sh
```

**O que acontece:**
- Compila `kmeans_1d_serial` (versão sequencial)
- Compila `kmeans_1d_omp` (versão OpenMP)
- Salva binários em `bin/`

**Resultado esperado:**
```
=========================================
Compilando K-means 1D - Todas as Versões
=========================================

1. Compilando versão SERIAL...
   ✓ Compilado: bin/kmeans_1d_serial

2. Compilando versão OPENMP...
   ✓ Compilado: bin/kmeans_1d_omp

Compilação concluída com sucesso!
```

**Verificar:**
```bash
ls -lh bin/
# Você deve ver kmeans_1d_serial e kmeans_1d_omp
```

**Se houver erros de compilação:**
```bash
# Compilar manualmente para ver o erro
gcc -O2 -std=c99 serial/kmeans_1d_serial.c -o bin/kmeans_1d_serial -lm
gcc -O2 -std=c99 -fopenmp openmp/kmeans_1d_omp.c -o bin/kmeans_1d_omp -lm
```

---

## ▶️ Passo 5: Executar Benchmarks

**Este é o passo principal!** Execute os testes completos:

```bash
./run_tests.sh
```

**O que acontece:**

### Etapa 0: Versão Serial
- Executa no dataset TESTE (validação)
- Executa no dataset PEQUENO
- Executa no dataset MÉDIO
- Executa no dataset GRANDE
- **Salva tempos de baseline**

### Etapa 1: Versão OpenMP
- Executa com 1, 2, 4, 8, 16 threads
- Para cada dataset (pequeno, médio, grande)
- **Calcula speedup e eficiência**
- Salva resultados em CSV

**Resultado esperado (exemplo):**

```
============================================
ETAPA 0: Executando Versão Serial
============================================

--- Dataset PEQUENO (10k pontos, 4 clusters) ---
========================================
K-means 1D - Versão SERIAL (Baseline)
========================================
Parâmetros:
  N = 10000 pontos
  K = 4 clusters
  max_iter = 100
  eps = 1e-06

Resultados:
  Iterações: 8
  SSE final: 417250.125000
  Tempo: 35.42 ms
  Throughput: 282.31 pontos/ms

============================================
ETAPA 1: Executando Versão OpenMP
============================================

--- Dataset PEQUENO (10k pontos) ---
Threads | Tempo (ms) | Speedup | Eficiência
--------|------------|---------|------------
      1 |      35.87 |    0.99 |      98.75%
      2 |      19.23 |    1.84 |      92.10%
      4 |      10.45 |    3.39 |      84.68%
      8 |       6.12 |    5.79 |      72.36%
     16 |       4.23 |    8.38 |      52.36%

...
```

**Tempo de execução:**
- Dataset pequeno: ~2 minutos
- Dataset médio: ~5 minutos  
- Dataset grande: ~15 minutos
- **Total: ~25 minutos**

---

## 📈 Passo 6: Analisar Resultados

### Opção A: Ver Resultados Brutos

```bash
# Ver tabela de speedup
cat results/benchmarks/speedup_results.csv

# Ver relatório de performance
cat results/benchmarks/performance_report.txt
```

### Opção B: Gerar Gráficos (Recomendado)

**Instalar matplotlib:**
```bash
pip3 install pandas matplotlib numpy
```

**Gerar gráficos:**
```bash
chmod +x plot_results.py
./plot_results.py
```

**Resultado:**
```
K-means 1D - Análise de Resultados OpenMP
Carregando resultados...
✓ 15 registros carregados

Gerando gráficos...
✓ Gráfico salvo: results/benchmarks/speedup_plot.png
✓ Gráfico salvo: results/benchmarks/efficiency_plot.png
✓ Gráfico salvo: results/benchmarks/execution_time_plot.png
✓ Gráfico combinado salvo: results/benchmarks/combined_analysis.png
✓ Relatório salvo: results/benchmarks/performance_report.txt

Análise concluída!
```

**Ver gráficos:**
```bash
# Linux com interface gráfica
xdg-open results/benchmarks/combined_analysis.png

# WSL (Windows)
explorer.exe results/benchmarks/combined_analysis.png

# macOS
open results/benchmarks/combined_analysis.png
```

---

## ✅ Passo 7: Validar Resultados

### Checklist de Validação

Execute estes comandos para validar:

```bash
# 1. Comparar SSE entre versões (devem ser iguais)
echo "SSE Serial:"
grep "SSE final:" results/serial/output_pequeno.txt 2>/dev/null || echo "Execute run_tests.sh"

echo "SSE OpenMP (4 threads):"
grep "SSE final:" results/openmp/output_pequeno_t4.txt 2>/dev/null || echo "Execute run_tests.sh"

# 2. Verificar que speedup > 1 para threads > 1
echo ""
echo "Speedups:"
awk -F',' 'NR>1 && $1=="pequeno" {print "Threads " $2 ": Speedup " $6}' \
    results/benchmarks/speedup_results.csv

# 3. Comparar assignments (devem ser idênticos)
echo ""
echo "Comparando assignments serial vs OpenMP:"
diff results/serial/pequeno_assign.csv results/openmp/pequeno_t4_assign.csv \
    && echo "✓ Assignments IGUAIS" || echo "✗ Assignments DIFERENTES"
```

**Critérios de validação:**
- [ ] SSE não aumenta entre iterações
- [ ] SSE é igual entre serial e OpenMP (±0.01%)
- [ ] Speedup > 1 para threads > 1
- [ ] Eficiência diminui com mais threads (normal)
- [ ] Assignments são idênticos

---

## 🐛 Resolução de Problemas

### Erro: "gcc: command not found"

```bash
sudo apt-get update
sudo apt-get install build-essential
```

### Erro: "OpenMP não encontrado"

```bash
sudo apt-get install libomp-dev
```

### Erro: "bc: command not found"

```bash
sudo apt-get install bc
```

### Performance ruim (speedup baixo)

1. Verificar carga da CPU:
```bash
htop
# Pressione 'q' para sair
```

2. Desabilitar hyperthreading (se necessário):
```bash
echo off | sudo tee /sys/devices/system/cpu/smt/control
```

3. Fixar afinidade de CPU:
```bash
export OMP_PROC_BIND=true
./run_tests.sh
```

### Compilação falha

```bash
# Ver erros detalhados
gcc -O2 -std=c99 -Wall -Wextra serial/kmeans_1d_serial.c -o test -lm
```

---

## 📊 Interpretando os Resultados

### Speedup Esperado

| Threads | Speedup Esperado | Eficiência |
|---------|------------------|------------|
| 1       | 1.00x           | 100%       |
| 2       | 1.85-1.95x      | 92-97%     |
| 4       | 3.40-3.80x      | 85-95%     |
| 8       | 5.80-7.20x      | 72-90%     |
| 16      | 8.00-12.00x     | 50-75%     |

### O que significa cada métrica:

- **Speedup**: Quanto mais rápido fica com mais threads
  - `Speedup = Tempo_Serial / Tempo_Paralelo`
  - Ideal: Speedup = Número de Threads
  
- **Eficiência**: Quão bem os threads são utilizados
  - `Eficiência = Speedup / Threads × 100%`
  - Ideal: 100% (todos threads 100% ocupados)
  - Bom: > 70%
  - Aceitável: > 50%
  
- **SSE** (Sum of Squared Errors): Qualidade do clustering
  - Deve diminuir a cada iteração
  - Deve ser **igual** entre serial e OpenMP

---

## 🎓 Análise para o Relatório

Use estes pontos para o relatório:

### Ambiente de Testes
```bash
# CPU
grep "model name" /proc/cpuinfo | head -1

# Cores
nproc

# Memória
free -h

# Compilador
gcc --version
```

### Gráficos Necessários

1. **Speedup vs Threads** (todos datasets)
2. **Eficiência vs Threads**
3. **Tempo vs Threads** (escala log)
4. **SSE por iteração** (validação convergência)

### Questões para Análise

1. O speedup é linear? Por quê?
2. Qual dataset tem melhor escalabilidade?
3. Por que a eficiência diminui com mais threads?
4. Qual é o número ótimo de threads?
5. Overhead de OpenMP é significativo?

---

## 📝 Próximos Passos

Após completar Etapas 0 e 1:

- [ ] Analisar gráficos de desempenho
- [ ] Escrever seção do relatório sobre OpenMP
- [ ] Comparar com literatura (ver referências)
- [ ] Preparar para Etapa 2 (CUDA)

---

## 📚 Referências

- OpenMP: https://www.openmp.org/
- K-means: Lloyd, S. (1982). IEEE Trans. Information Theory
- Parallel Programming: Chapman et al. (2007)

---

## ✨ Dicas Finais

1. **Execute múltiplas vezes** para média de tempo
2. **Feche outros programas** durante benchmark
3. **Use datasets maiores** para melhor análise
4. **Compare com literatura** para validar resultados
5. **Documente observações** enquanto executa

---

## 🎯 Checklist Final

- [ ] Setup executado com sucesso
- [ ] Dados gerados
- [ ] Código compilado
- [ ] Benchmarks executados
- [ ] Gráficos gerados
- [ ] Resultados validados
- [ ] Análise escrita

**Se completou tudo: Parabéns! Etapas 0 e 1 concluídas! 🎉**