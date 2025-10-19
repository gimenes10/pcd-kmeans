#!/bin/bash

# Script de execução e benchmark para K-means 1D
# Etapas 0 e 1: Serial e OpenMP

echo "============================================"
echo "K-means 1D - Benchmark Completo"
echo "Etapa 0: Versão Serial (Baseline)"
echo "Etapa 1: Versão OpenMP (Paralelizada)"
echo "============================================"

# Criar diretórios para resultados
mkdir -p results/serial
mkdir -p results/openmp
mkdir -p results/benchmarks

# Configurações de teste
MAX_ITER=100
EPS=1e-6

# Verificar se binários existem
if [ ! -f "./bin/kmeans_1d_serial" ]; then
    echo "ERRO: Binário serial não encontrado!"
    echo "Execute './compile.sh' primeiro."
    exit 1
fi

if [ ! -f "./bin/kmeans_1d_omp" ]; then
    echo "ERRO: Binário OpenMP não encontrado!"
    echo "Execute './compile.sh' primeiro."
    exit 1
fi

# Verificar se dados existem
if [ ! -f "data/dados_teste.csv" ]; then
    echo "ERRO: Dados não encontrados!"
    echo "Execute './generate_data.sh' primeiro."
    exit 1
fi

# Função para executar e extrair métricas
run_serial() {
    local dataset=$1
    local centroids=$2
    local output_prefix=$3
    
    # Executar e salvar saída completa
    ./bin/kmeans_1d_serial "$dataset" "$centroids" $MAX_ITER $EPS \
        "results/serial/${output_prefix}_assign.csv" \
        "results/serial/${output_prefix}_centroids.csv" \
        > "results/serial/${output_prefix}_output.txt" 2>&1
    
    # Extrair métricas da saída
    local time_ms=$(grep "Tempo:" "results/serial/${output_prefix}_output.txt" | awk '{print $2}')
    local sse=$(grep "SSE final:" "results/serial/${output_prefix}_output.txt" | awk '{print $3}')
    local iters=$(grep "Iterações:" "results/serial/${output_prefix}_output.txt" | awk '{print $2}')
    
    # Validar valores
    if [ -z "$time_ms" ]; then time_ms="0.00"; fi
    if [ -z "$sse" ]; then sse="0.000000"; fi
    if [ -z "$iters" ]; then iters="0"; fi
    
    echo "$time_ms|$sse|$iters"
}

run_openmp() {
    local dataset=$1
    local centroids=$2
    local threads=$3
    local output_prefix=$4
    
    # Executar e salvar saída completa
    ./bin/kmeans_1d_omp "$dataset" "$centroids" $threads $MAX_ITER $EPS \
        "results/openmp/${output_prefix}_t${threads}_assign.csv" \
        "results/openmp/${output_prefix}_t${threads}_centroids.csv" \
        > "results/openmp/${output_prefix}_t${threads}_output.txt" 2>&1
    
    # Extrair métricas da saída
    local time_ms=$(grep "Tempo:" "results/openmp/${output_prefix}_t${threads}_output.txt" | awk '{print $2}')
    local sse=$(grep "SSE final:" "results/openmp/${output_prefix}_t${threads}_output.txt" | awk '{print $3}')
    local iters=$(grep "Iterações:" "results/openmp/${output_prefix}_t${threads}_output.txt" | awk '{print $2}')
    
    # Validar valores
    if [ -z "$time_ms" ]; then time_ms="0.00"; fi
    if [ -z "$sse" ]; then sse="0.000000"; fi
    if [ -z "$iters" ]; then iters="0"; fi
    
    echo "$time_ms|$sse|$iters"
}

# ============================================
# ETAPA 0: VERSÃO SERIAL (BASELINE)
# ============================================

echo ""
echo "============================================"
echo "ETAPA 0: Executando Versão Serial"
echo "============================================"

# Dataset TESTE
echo ""
echo "--- Dataset TESTE (validação rápida) ---"
result=$(run_serial "data/dados_teste.csv" "data/centroides_teste.csv" "teste")
IFS='|' read -r time_ms sse iters <<< "$result"
echo "Tempo: $time_ms ms | SSE: $sse | Iterações: $iters"

# Dataset PEQUENO
echo ""
echo "--- Dataset PEQUENO (10k pontos, 4 clusters) ---"
result=$(run_serial "data/dados_pequeno.csv" "data/centroides_pequeno.csv" "pequeno")
IFS='|' read -r serial_time_small sse iters <<< "$result"
echo "Tempo SERIAL: $serial_time_small ms | SSE: $sse | Iterações: $iters"

# Dataset MÉDIO
echo ""
echo "--- Dataset MÉDIO (100k pontos, 8 clusters) ---"
result=$(run_serial "data/dados_medio.csv" "data/centroides_medio.csv" "medio")
IFS='|' read -r serial_time_medium sse iters <<< "$result"
echo "Tempo SERIAL: $serial_time_medium ms | SSE: $sse | Iterações: $iters"

# Dataset GRANDE
echo ""
echo "--- Dataset GRANDE (1M pontos, 16 clusters) ---"
result=$(run_serial "data/dados_grande.csv" "data/centroides_grande.csv" "grande")
IFS='|' read -r serial_time_large sse iters <<< "$result"
echo "Tempo SERIAL: $serial_time_large ms | SSE: $sse | Iterações: $iters"

# ============================================
# ETAPA 1: VERSÃO OPENMP
# ============================================

echo ""
echo ""
echo "============================================"
echo "ETAPA 1: Executando Versão OpenMP"
echo "============================================"

# Array de números de threads para testar
THREAD_COUNTS=(1 2 4 8 16)

# Arquivo de resultados
RESULTS_FILE="results/benchmarks/speedup_results.csv"
echo "Dataset,Threads,Time_ms,SSE,Iters,Speedup,Efficiency" > "$RESULTS_FILE"

# ============================================
# Benchmark: Dataset PEQUENO
# ============================================

echo ""
echo "--- Dataset PEQUENO (10k pontos) ---"
echo "Threads | Tempo (ms) | Speedup | Eficiência"
echo "--------|------------|---------|------------"

for threads in "${THREAD_COUNTS[@]}"; do
    result=$(run_openmp "data/dados_pequeno.csv" "data/centroides_pequeno.csv" $threads "pequeno")
    IFS='|' read -r time_ms sse iters <<< "$result"
    
    # Calcular speedup e eficiência com validação
    if [ "$time_ms" != "0.00" ] && [ "$serial_time_small" != "0.00" ]; then
        speedup=$(echo "scale=2; $serial_time_small / $time_ms" | bc -l)
        efficiency=$(echo "scale=2; ($speedup / $threads) * 100" | bc -l)
    else
        speedup="0.00"
        efficiency="0.00"
    fi
    
    printf "%7d | %10s | %7s | %10s%%\n" $threads $time_ms $speedup $efficiency
    echo "pequeno,$threads,$time_ms,$sse,$iters,$speedup,$efficiency" >> "$RESULTS_FILE"
done

# ============================================
# Benchmark: Dataset MÉDIO
# ============================================

echo ""
echo "--- Dataset MÉDIO (100k pontos) ---"
echo "Threads | Tempo (ms) | Speedup | Eficiência"
echo "--------|------------|---------|------------"

for threads in "${THREAD_COUNTS[@]}"; do
    result=$(run_openmp "data/dados_medio.csv" "data/centroides_medio.csv" $threads "medio")
    IFS='|' read -r time_ms sse iters <<< "$result"
    
    # Calcular speedup e eficiência com validação
    if [ "$time_ms" != "0.00" ] && [ "$serial_time_medium" != "0.00" ]; then
        speedup=$(echo "scale=2; $serial_time_medium / $time_ms" | bc -l)
        efficiency=$(echo "scale=2; ($speedup / $threads) * 100" | bc -l)
    else
        speedup="0.00"
        efficiency="0.00"
    fi
    
    printf "%7d | %10s | %7s | %10s%%\n" $threads $time_ms $speedup $efficiency
    echo "medio,$threads,$time_ms,$sse,$iters,$speedup,$efficiency" >> "$RESULTS_FILE"
done

# ============================================
# Benchmark: Dataset GRANDE
# ============================================

echo ""
echo "--- Dataset GRANDE (1M pontos) ---"
echo "Threads | Tempo (ms) | Speedup | Eficiência"
echo "--------|------------|---------|------------"

for threads in "${THREAD_COUNTS[@]}"; do
    result=$(run_openmp "data/dados_grande.csv" "data/centroides_grande.csv" $threads "grande")
    IFS='|' read -r time_ms sse iters <<< "$result"
    
    # Calcular speedup e eficiência com validação
    if [ "$time_ms" != "0.00" ] && [ "$serial_time_large" != "0.00" ]; then
        speedup=$(echo "scale=2; $serial_time_large / $time_ms" | bc -l)
        efficiency=$(echo "scale=2; ($speedup / $threads) * 100" | bc -l)
    else
        speedup="0.00"
        efficiency="0.00"
    fi
    
    printf "%7d | %10s | %7s | %10s%%\n" $threads $time_ms $speedup $efficiency
    echo "grande,$threads,$time_ms,$sse,$iters,$speedup,$efficiency" >> "$RESULTS_FILE"
done

# ============================================
# Verificação de Resultados
# ============================================

echo ""
echo ""
echo "============================================"
echo "VERIFICAÇÃO DE RESULTADOS"
echo "============================================"
echo ""

# Verificar se houve resultados válidos
total_lines=$(wc -l < "$RESULTS_FILE")
if [ "$total_lines" -le 1 ]; then
    echo "⚠ AVISO: Nenhum resultado foi coletado!"
    echo ""
    echo "Possíveis causas:"
    echo "  1. Programas não executaram corretamente"
    echo "  2. Formato de saída diferente do esperado"
    echo ""
    echo "Diagnóstico:"
    echo "  Verifique os arquivos de saída em results/serial/ e results/openmp/"
    echo "  Exemplo: cat results/serial/teste_output.txt"
    echo ""
    echo "  Se houver erros de execução, compile novamente:"
    echo "    ./compile.sh"
else
    echo "✓ Resultados coletados: $((total_lines - 1)) experimentos"
    echo ""
    
    # Mostrar exemplo de saída
    echo "Exemplo de saída serial (dataset teste):"
    echo "----------------------------------------"
    if [ -f "results/serial/teste_output.txt" ]; then
        head -n 15 results/serial/teste_output.txt
    else
        echo "Arquivo não encontrado"
    fi
fi

# ============================================
# Resumo Final
# ============================================

echo ""
echo ""
echo "============================================"
echo "RESUMO DOS RESULTADOS"
echo "============================================"
echo ""
echo "Tempos baseline (serial):"
echo "  Teste:   Ver results/serial/teste_output.txt"
echo "  Pequeno: $serial_time_small ms"
echo "  Médio:   $serial_time_medium ms"
echo "  Grande:  $serial_time_large ms"
echo ""
echo "Resultados salvos em:"
echo "  - results/serial/       (outputs da versão serial)"
echo "  - results/openmp/       (outputs da versão OpenMP)"
echo "  - results/benchmarks/speedup_results.csv (dados completos)"
echo ""
echo "Para visualizar os dados:"
echo "  cat results/benchmarks/speedup_results.csv"
echo ""
echo "Para análise detalhada:"
echo "  cat results/serial/pequeno_output.txt"
echo "  cat results/openmp/pequeno_t4_output.txt"
echo ""
echo "Próximos passos:"
echo "  1. Analisar os gráficos de speedup: ./plot_results.py"
echo "  2. Verificar eficiência de paralelização"
echo "  3. Comparar SSE entre versões (devem ser iguais)"
echo "  4. Identificar o melhor número de threads"
echo ""
echo "============================================"