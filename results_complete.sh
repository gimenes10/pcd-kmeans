# Salvar tudo em um arquivo
{
echo "========================================" && \
echo "RELATÓRIO COMPLETO - K-MEANS 1D" && \
echo "Data: $(date)" && \
echo "========================================" && \
echo "" && \
echo "=== 1. SPEEDUP RESULTS CSV ===" && \
cat results/benchmarks/speedup_results.csv && \
echo "" && \
echo "=== 2. INFORMAÇÕES DO SISTEMA ===" && \
echo "CPU: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)" && \
echo "Cores físicos: $(lscpu | grep "Core(s) per socket" | awk '{print $4}')" && \
echo "Threads por core: $(lscpu | grep "Thread(s) per core" | awk '{print $4}')" && \
echo "Total threads disponíveis: $(nproc)" && \
echo "Memória RAM: $(free -h | grep Mem | awk '{print $2}')" && \
echo "GCC: $(gcc --version | head -1)" && \
echo "Sistema Operacional: $(uname -s) $(uname -r)" && \
echo "" && \
echo "=== 3. RESULTADOS SERIAL (BASELINE - ETAPA 0) ===" && \
echo "" && \
echo "--- TESTE (20 pontos, 4 clusters) ---" && \
cat results/serial/teste_output.txt && \
echo "" && \
echo "--- PEQUENO (10k pontos, 4 clusters) ---" && \
cat results/serial/pequeno_output.txt && \
echo "" && \
echo "--- MÉDIO (100k pontos, 8 clusters) ---" && \
cat results/serial/medio_output.txt && \
echo "" && \
echo "--- GRANDE (1M pontos, 16 clusters) ---" && \
cat results/serial/grande_output.txt && \
echo "" && \
echo "=== 4. RESULTADOS OPENMP - DATASET PEQUENO (ETAPA 1) ===" && \
for threads in 1 2 4 8 16; do \
  echo "" && \
  echo "--- PEQUENO - $threads THREADS ---" && \
  cat results/openmp/pequeno_t${threads}_output.txt 2>/dev/null || echo "Arquivo não encontrado"; \
done && \
echo "" && \
echo "=== 5. RESULTADOS OPENMP - DATASET MÉDIO (ETAPA 1) ===" && \
for threads in 1 2 4 8 16; do \
  echo "" && \
  echo "--- MÉDIO - $threads THREADS ---" && \
  cat results/openmp/medio_t${threads}_output.txt 2>/dev/null || echo "Arquivo não encontrado"; \
done && \
echo "" && \
echo "=== 6. RESULTADOS OPENMP - DATASET GRANDE (ETAPA 1) ===" && \
for threads in 1 2 4 8 16; do \
  echo "" && \
  echo "--- GRANDE - $threads THREADS ---" && \
  cat results/openmp/grande_t${threads}_output.txt 2>/dev/null || echo "Arquivo não encontrado"; \
done && \
echo "" && \
echo "=== 7. ARQUIVOS GERADOS ===" && \
echo "Total de arquivos em results/:" && \
find results/ -type f | wc -l && \
echo "" && \
echo "Arquivos CSV:" && \
ls -lh results/benchmarks/*.csv 2>/dev/null && \
echo "" && \
echo "Gráficos gerados:" && \
ls -lh results/benchmarks/*.png 2>/dev/null || echo "Nenhum gráfico gerado" && \
echo "" && \
echo "========================================" && \
echo "FIM DO RELATÓRIO COMPLETO" && \
echo "Gerado em: $(date)" && \
echo "========================================" 
} > relatorio_completo_dados.txt

echo "✓ Relatório salvo em: relatorio_completo_dados.txt"
echo "  Tamanho: $(ls -lh relatorio_completo_dados.txt | awk '{print $5}')"
echo ""
echo "Para visualizar: cat relatorio_completo_dados.txt"
echo "Para copiar: cat relatorio_completo_dados.txt | xclip -selection clipboard"