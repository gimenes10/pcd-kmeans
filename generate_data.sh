#!/bin/bash

# Script para gerar dados de teste para K-means 1D
# Gera dados com clusters bem definidos em diferentes faixas

echo "Gerando dados de teste para K-means 1D..."

# Função para gerar dados
generate_dataset() {
    local n=$1
    local k=$2
    local output_data=$3
    local output_centroids=$4
    
    echo "Gerando dataset: N=$n, K=$k"
    
    # Gerar dados.csv com clusters em diferentes faixas
    > "$output_data"
    
    # Definir faixas para os clusters
    local points_per_cluster=$((n / k))
    
    for ((i=0; i<k; i++)); do
        local center=$((i * 30 + 10))
        local spread=5
        
        for ((j=0; j<points_per_cluster; j++)); do
            # Gerar valor com distribuição ao redor do centro
            local offset=$((RANDOM % (spread * 2) - spread))
            local value=$((center + offset))
            echo "$value" >> "$output_data"
        done
    done
    
    # Gerar centroides iniciais (ligeiramente deslocados dos centros reais)
    > "$output_centroids"
    for ((i=0; i<k; i++)); do
        local init_center=$((i * 30 + 15))
        echo "$init_center" >> "$output_centroids"
    done
    
    echo "Dataset gerado: $output_data e $output_centroids"
}

# Criar diretório para dados
mkdir -p data

# Dataset Pequeno: N=10^4, K=4
generate_dataset 10000 4 "data/dados_pequeno.csv" "data/centroides_pequeno.csv"

# Dataset Médio: N=10^5, K=8
generate_dataset 100000 8 "data/dados_medio.csv" "data/centroides_medio.csv"

# Dataset Grande: N=10^6, K=16
generate_dataset 1000000 16 "data/dados_grande.csv" "data/centroides_grande.csv"

# Dataset Teste (pequeno para validação rápida)
cat > data/dados_teste.csv << EOF
1
2
3
4
5
6
7
8
4.5
5.5
18
19
20
21
22
23
19.5
20.5
100
125
EOF

cat > data/centroides_teste.csv << EOF
10
30
60
90
EOF

echo ""
echo "Dados gerados com sucesso!"
echo "  - data/dados_teste.csv (20 pontos, 4 clusters) - para testes rápidos"
echo "  - data/dados_pequeno.csv (10k pontos, 4 clusters)"
echo "  - data/dados_medio.csv (100k pontos, 8 clusters)"
echo "  - data/dados_grande.csv (1M pontos, 16 clusters)"