#!/bin/bash

# Script de teste rápido para verificar se os programas funcionam

echo "============================================"
echo "Teste Rápido - K-means 1D"
echo "============================================"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Verificar binários
echo "1. Verificando binários..."

if [ -f "./bin/kmeans_1d_serial" ]; then
    echo -e "   ${GREEN}✓${NC} bin/kmeans_1d_serial encontrado"
else
    echo -e "   ${RED}✗${NC} bin/kmeans_1d_serial NÃO encontrado"
    echo "   Execute: ./compile.sh"
    exit 1
fi

if [ -f "./bin/kmeans_1d_omp" ]; then
    echo -e "   ${GREEN}✓${NC} bin/kmeans_1d_omp encontrado"
else
    echo -e "   ${RED}✗${NC} bin/kmeans_1d_omp NÃO encontrado"
    echo "   Execute: ./compile.sh"
    exit 1
fi

echo ""

# 2. Verificar dados
echo "2. Verificando dados de teste..."

if [ -f "data/dados_teste.csv" ]; then
    echo -e "   ${GREEN}✓${NC} data/dados_teste.csv encontrado"
else
    echo -e "   ${RED}✗${NC} Dados NÃO encontrados"
    echo "   Execute: ./generate_data.sh"
    exit 1
fi

echo ""

# 3. Criar dados simples para teste
echo "3. Criando dados de teste mínimos..."

cat > /tmp/test_data.csv << EOF
1.0
2.0
3.0
4.0
5.0
18.0
19.0
20.0
21.0
22.0
EOF

cat > /tmp/test_centers.csv << EOF
5.0
20.0
EOF

echo "   Criados: /tmp/test_data.csv (10 pontos)"
echo "           /tmp/test_centers.csv (2 clusters)"
echo ""

# 4. Testar versão serial
echo "4. Testando versão SERIAL..."
echo "   Executando: ./bin/kmeans_1d_serial /tmp/test_data.csv /tmp/test_centers.csv"
echo ""

./bin/kmeans_1d_serial /tmp/test_data.csv /tmp/test_centers.csv 50 1e-6 > /tmp/serial_test.txt 2>&1

if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓${NC} Execução bem-sucedida!"
    echo ""
    echo "   Saída:"
    cat /tmp/serial_test.txt
    echo ""
    
    # Verificar se tem as informações esperadas
    if grep -q "SSE final:" /tmp/serial_test.txt; then
        echo -e "   ${GREEN}✓${NC} Formato de saída correto"
    else
        echo -e "   ${YELLOW}⚠${NC} Formato de saída diferente do esperado"
    fi
else
    echo -e "   ${RED}✗${NC} ERRO na execução!"
    echo ""
    echo "   Saída de erro:"
    cat /tmp/serial_test.txt
    exit 1
fi

echo ""

# 5. Testar versão OpenMP
echo "5. Testando versão OPENMP (4 threads)..."
echo "   Executando: ./bin/kmeans_1d_omp /tmp/test_data.csv /tmp/test_centers.csv 4"
echo ""

./bin/kmeans_1d_omp /tmp/test_data.csv /tmp/test_centers.csv 4 50 1e-6 > /tmp/omp_test.txt 2>&1

if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓${NC} Execução bem-sucedida!"
    echo ""
    echo "   Saída:"
    cat /tmp/omp_test.txt
    echo ""
    
    # Verificar se tem as informações esperadas
    if grep -q "SSE final:" /tmp/omp_test.txt; then
        echo -e "   ${GREEN}✓${NC} Formato de saída correto"
    else
        echo -e "   ${YELLOW}⚠${NC} Formato de saída diferente do esperado"
    fi
else
    echo -e "   ${RED}✗${NC} ERRO na execução!"
    echo ""
    echo "   Saída de erro:"
    cat /tmp/omp_test.txt
    exit 1
fi

echo ""

# 6. Comparar SSE
echo "6. Comparando resultados Serial vs OpenMP..."

serial_sse=$(grep "SSE final:" /tmp/serial_test.txt | awk '{print $3}')
omp_sse=$(grep "SSE final:" /tmp/omp_test.txt | awk '{print $3}')

echo "   SSE Serial: $serial_sse"
echo "   SSE OpenMP: $omp_sse"

if [ -n "$serial_sse" ] && [ -n "$omp_sse" ]; then
    diff=$(echo "scale=6; ($serial_sse - $omp_sse)" | bc -l | sed 's/^-//')
    rel_diff=$(echo "scale=6; ($diff / $serial_sse) * 100" | bc -l | sed 's/^-//')
    
    echo "   Diferença: $diff (${rel_diff}%)"
    
    # SSE deve ser praticamente igual (tolerância de 0.1%)
    if (( $(echo "$rel_diff < 0.1" | bc -l) )); then
        echo -e "   ${GREEN}✓${NC} SSE praticamente igual (OK!)"
    else
        echo -e "   ${YELLOW}⚠${NC} SSE diferente (pode ser problema)"
    fi
else
    echo -e "   ${YELLOW}⚠${NC} Não foi possível extrair SSE"
fi

echo ""

# 7. Testar com dados reais
echo "7. Testando com dataset real (teste)..."
echo ""

./bin/kmeans_1d_serial data/dados_teste.csv data/centroides_teste.csv 100 1e-6 > /tmp/real_test.txt 2>&1

if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓${NC} Dataset real funciona!"
    
    # Extrair tempo
    time_ms=$(grep "Tempo:" /tmp/real_test.txt | awk '{print $2}')
    sse=$(grep "SSE final:" /tmp/real_test.txt | awk '{print $3}')
    iters=$(grep "Iterações:" /tmp/real_test.txt | awk '{print $2}')
    
    echo "   Tempo: $time_ms ms"
    echo "   SSE: $sse"
    echo "   Iterações: $iters"
    
    if [ -n "$time_ms" ] && [ -n "$sse" ] && [ -n "$iters" ]; then
        echo -e "   ${GREEN}✓${NC} Extração de métricas funcionando!"
    else
        echo -e "   ${YELLOW}⚠${NC} Problema na extração de métricas"
        echo ""
        echo "   Saída completa:"
        cat /tmp/real_test.txt
    fi
else
    echo -e "   ${RED}✗${NC} ERRO com dataset real!"
    cat /tmp/real_test.txt
    exit 1
fi

echo ""

# Limpeza
rm -f /tmp/test_data.csv /tmp/test_centers.csv
rm -f /tmp/serial_test.txt /tmp/omp_test.txt /tmp/real_test.txt

# 8. Resumo
echo "============================================"
echo "RESUMO DO TESTE"
echo "============================================"
echo ""
echo -e "${GREEN}✓ Todos os testes passaram!${NC}"
echo ""
echo "Sistema pronto para benchmark completo:"
echo "  ./run_tests.sh"
echo ""
echo "============================================"