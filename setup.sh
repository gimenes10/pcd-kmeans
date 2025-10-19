#!/bin/bash

# Script de configuração inicial do projeto K-means 1D
# Cria estrutura de diretórios e verifica dependências

echo "========================================="
echo "K-means 1D - Setup Inicial"
echo "========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para verificar comando
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 encontrado"
        return 0
    else
        echo -e "${RED}✗${NC} $1 não encontrado"
        return 1
    fi
}

# ========================================
# 1. Verificar Dependências
# ========================================

echo ""
echo "1. Verificando dependências..."
echo ""

all_ok=true

# Verificar GCC
if check_command gcc; then
    gcc_version=$(gcc --version | head -n1)
    echo "   Versão: $gcc_version"
else
    echo -e "   ${YELLOW}Instale com: sudo apt-get install build-essential${NC}"
    all_ok=false
fi

# Verificar suporte OpenMP
echo -n "   Testando OpenMP... "
if echo '#include <omp.h>' | gcc -fopenmp -x c -E - > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERRO${NC}"
    echo -e "   ${YELLOW}Instale com: sudo apt-get install libomp-dev${NC}"
    all_ok=false
fi

# Verificar bc (para cálculos no benchmark)
if check_command bc; then
    :
else
    echo -e "   ${YELLOW}Instale com: sudo apt-get install bc${NC}"
    all_ok=false
fi

# Verificar bash
check_command bash

if [ "$all_ok" = false ]; then
    echo ""
    echo -e "${RED}ERRO: Dependências faltando. Instale-as antes de continuar.${NC}"
    exit 1
fi

# ========================================
# 2. Criar Estrutura de Diretórios
# ========================================

echo ""
echo "2. Criando estrutura de diretórios..."
echo ""

directories=(
    "serial"
    "openmp"
    "data"
    "bin"
    "results/serial"
    "results/openmp"
    "results/benchmarks"
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "   Criado: $dir/"
    else
        echo "   Existe: $dir/"
    fi
done

# ========================================
# 3. Verificar Arquivos Fonte
# ========================================

echo ""
echo "3. Verificando arquivos fonte..."
echo ""

required_files=(
    "serial/kmeans_1d_serial.c"
    "openmp/kmeans_1d_omp.c"
    "compile.sh"
    "run_tests.sh"
    "generate_data.sh"
)

missing_files=false
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "   ${GREEN}✓${NC} $file"
    else
        echo -e "   ${RED}✗${NC} $file ${YELLOW}(precisa ser criado)${NC}"
        missing_files=true
    fi
done

if [ "$missing_files" = true ]; then
    echo ""
    echo -e "${YELLOW}AVISO: Alguns arquivos fonte estão faltando.${NC}"
    echo "        Crie-os conforme a documentação do projeto."
fi

# ========================================
# 4. Tornar Scripts Executáveis
# ========================================

echo ""
echo "4. Configurando permissões de execução..."
echo ""

scripts=(
    "compile.sh"
    "run_tests.sh"
    "generate_data.sh"
    "setup.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        echo "   chmod +x $script"
    fi
done

# ========================================
# 5. Informações do Sistema
# ========================================

echo ""
echo "5. Informações do sistema..."
echo ""

echo "   CPU:"
if [ -f /proc/cpuinfo ]; then
    cpu_model=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | xargs)
    cpu_cores=$(grep -c "processor" /proc/cpuinfo)
    echo "      Modelo: $cpu_model"
    echo "      Cores: $cpu_cores"
else
    echo "      (Informação não disponível)"
fi

echo ""
echo "   Memória:"
if command -v free &> /dev/null; then
    free -h | grep "Mem:" | awk '{print "      Total: " $2 "  |  Livre: " $4}'
else
    echo "      (Informação não disponível)"
fi

echo ""
echo "   Compilador:"
gcc --version | head -n1

# ========================================
# 6. Teste Rápido de Compilação
# ========================================

echo ""
echo "6. Teste rápido de compilação..."
echo ""

# Criar um programa de teste simples
cat > /tmp/omp_test.c << 'EOF'
#include <stdio.h>
#include <omp.h>

int main() {
    #pragma omp parallel
    {
        #pragma omp single
        printf("OpenMP threads: %d\n", omp_get_num_threads());
    }
    return 0;
}
EOF

echo -n "   Compilando teste OpenMP... "
if gcc -fopenmp /tmp/omp_test.c -o /tmp/omp_test 2>/dev/null; then
    echo -e "${GREEN}OK${NC}"
    echo -n "   Executando teste... "
    /tmp/omp_test
    rm -f /tmp/omp_test /tmp/omp_test.c
else
    echo -e "${RED}ERRO${NC}"
    rm -f /tmp/omp_test.c
fi

# ========================================
# 7. Resumo e Próximos Passos
# ========================================

echo ""
echo "========================================="
echo "Setup Concluído!"
echo "========================================="
echo ""
echo "Estrutura criada:"
for dir in "${directories[@]}"; do
    echo "  ✓ $dir/"
done

echo ""
echo "Próximos passos:"
echo ""
echo "  1. Gerar dados de teste:"
echo "     ${GREEN}./generate_data.sh${NC}"
echo ""
echo "  2. Compilar projeto:"
echo "     ${GREEN}./compile.sh${NC}"
echo ""
echo "  3. Executar benchmarks:"
echo "     ${GREEN}./run_tests.sh${NC}"
echo ""
echo "  4. Analisar resultados:"
echo "     ${GREEN}cat results/benchmarks/speedup_results.csv${NC}"
echo ""
echo "Documentação completa: README.md"
echo ""
echo "========================================="