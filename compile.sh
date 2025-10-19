#!/bin/bash

# Script de compilação para K-means 1D
# Compila versões serial e OpenMP

echo "========================================="
echo "Compilando K-means 1D - Todas as Versões"
echo "========================================="

# Verificar se o gcc está disponível
if ! command -v gcc &> /dev/null; then
    echo "ERRO: gcc não encontrado!"
    exit 1
fi

# Criar diretório para binários
mkdir -p bin
mkdir -p results

# Flags de compilação
CFLAGS="-O2 -std=c99 -Wall -Wextra"
LDFLAGS="-lm -lrt"

echo ""
echo "1. Compilando versão SERIAL..."
gcc $CFLAGS serial/kmeans_1d_serial.c -o bin/kmeans_1d_serial $LDFLAGS
if [ $? -eq 0 ]; then
    echo "   ✓ Compilado: bin/kmeans_1d_serial"
else
    echo "   ✗ ERRO na compilação serial"
    exit 1
fi

echo ""
echo "2. Compilando versão OPENMP..."
gcc $CFLAGS -fopenmp openmp/kmeans_1d_omp.c -o bin/kmeans_1d_omp $LDFLAGS
if [ $? -eq 0 ]; then
    echo "   ✓ Compilado: bin/kmeans_1d_omp"
else
    echo "   ✗ ERRO na compilação OpenMP"
    exit 1
fi

echo ""
echo "========================================="
echo "Compilação concluída com sucesso!"
echo "========================================="
echo ""
echo "Binários gerados em: bin/"
echo "  - kmeans_1d_serial"
echo "  - kmeans_1d_omp"
echo ""
echo "Para executar os testes, use: ./run_tests.sh"