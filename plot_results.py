#!/usr/bin/env python3
"""
Script para análise e visualização dos resultados do K-means 1D
Gera gráficos de speedup, eficiência e tempos de execução
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import sys
import os

def load_results(filename='results/benchmarks/speedup_results.csv'):
    """Carrega os resultados do CSV"""
    try:
        df = pd.read_csv(filename)
        return df
    except FileNotFoundError:
        print(f"ERRO: Arquivo {filename} não encontrado!")
        print("Execute './run_tests.sh' primeiro para gerar os resultados.")
        sys.exit(1)

def plot_speedup(df, output_dir='results/benchmarks'):
    """Plota gráfico de Speedup vs Threads"""
    plt.figure(figsize=(10, 6))
    
    for dataset in df['Dataset'].unique():
        data = df[df['Dataset'] == dataset]
        plt.plot(data['Threads'], data['Speedup'], 
                marker='o', linewidth=2, markersize=8,
                label=f'Dataset {dataset}')
    
    # Linha ideal (speedup linear)
    max_threads = df['Threads'].max()
    plt.plot([1, max_threads], [1, max_threads], 
            'k--', alpha=0.5, linewidth=1.5, label='Speedup Ideal')
    
    plt.xlabel('Número de Threads', fontsize=12, fontweight='bold')
    plt.ylabel('Speedup', fontsize=12, fontweight='bold')
    plt.title('Speedup vs Número de Threads\n(K-means 1D - OpenMP)', 
             fontsize=14, fontweight='bold')
    plt.legend(fontsize=10)
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    
    output_file = os.path.join(output_dir, 'speedup_plot.png')
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"✓ Gráfico salvo: {output_file}")
    plt.close()

def plot_efficiency(df, output_dir='results/benchmarks'):
    """Plota gráfico de Eficiência vs Threads"""
    plt.figure(figsize=(10, 6))
    
    for dataset in df['Dataset'].unique():
        data = df[df['Dataset'] == dataset]
        plt.plot(data['Threads'], data['Efficiency'], 
                marker='s', linewidth=2, markersize=8,
                label=f'Dataset {dataset}')
    
    # Linha de eficiência ideal (100%)
    plt.axhline(y=100, color='k', linestyle='--', alpha=0.5, 
               linewidth=1.5, label='Eficiência Ideal')
    
    plt.xlabel('Número de Threads', fontsize=12, fontweight='bold')
    plt.ylabel('Eficiência (%)', fontsize=12, fontweight='bold')
    plt.title('Eficiência vs Número de Threads\n(K-means 1D - OpenMP)', 
             fontsize=14, fontweight='bold')
    plt.legend(fontsize=10)
    plt.grid(True, alpha=0.3)
    plt.ylim(0, 110)
    plt.tight_layout()
    
    output_file = os.path.join(output_dir, 'efficiency_plot.png')
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"✓ Gráfico salvo: {output_file}")
    plt.close()

def plot_execution_time(df, output_dir='results/benchmarks'):
    """Plota gráfico de Tempo de Execução vs Threads (escala log)"""
    plt.figure(figsize=(10, 6))
    
    for dataset in df['Dataset'].unique():
        data = df[df['Dataset'] == dataset]
        plt.plot(data['Threads'], data['Time_ms'], 
                marker='^', linewidth=2, markersize=8,
                label=f'Dataset {dataset}')
    
    plt.xlabel('Número de Threads', fontsize=12, fontweight='bold')
    plt.ylabel('Tempo de Execução (ms)', fontsize=12, fontweight='bold')
    plt.title('Tempo de Execução vs Número de Threads\n(K-means 1D - OpenMP)', 
             fontsize=14, fontweight='bold')
    plt.legend(fontsize=10)
    plt.grid(True, alpha=0.3, which='both')
    plt.yscale('log')
    plt.tight_layout()
    
    output_file = os.path.join(output_dir, 'execution_time_plot.png')
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"✓ Gráfico salvo: {output_file}")
    plt.close()

def plot_combined(df, output_dir='results/benchmarks'):
    """Plota gráficos combinados em subplots"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # 1. Speedup
    ax = axes[0, 0]
    for dataset in df['Dataset'].unique():
        data = df[df['Dataset'] == dataset]
        ax.plot(data['Threads'], data['Speedup'], 
               marker='o', linewidth=2, label=f'{dataset}')
    max_threads = df['Threads'].max()
    ax.plot([1, max_threads], [1, max_threads], 
           'k--', alpha=0.5, label='Ideal')
    ax.set_xlabel('Threads')
    ax.set_ylabel('Speedup')
    ax.set_title('Speedup vs Threads', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. Eficiência
    ax = axes[0, 1]
    for dataset in df['Dataset'].unique():
        data = df[df['Dataset'] == dataset]
        ax.plot(data['Threads'], data['Efficiency'], 
               marker='s', linewidth=2, label=f'{dataset}')
    ax.axhline(y=100, color='k', linestyle='--', alpha=0.5)
    ax.set_xlabel('Threads')
    ax.set_ylabel('Eficiência (%)')
    ax.set_title('Eficiência vs Threads', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 110)
    
    # 3. Tempo de Execução
    ax = axes[1, 0]
    for dataset in df['Dataset'].unique():
        data = df[df['Dataset'] == dataset]
        ax.plot(data['Threads'], data['Time_ms'], 
               marker='^', linewidth=2, label=f'{dataset}')
    ax.set_xlabel('Threads')
    ax.set_ylabel('Tempo (ms)')
    ax.set_title('Tempo de Execução vs Threads', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3, which='both')
    ax.set_yscale('log')
    
    # 4. Tabela de Resumo
    ax = axes[1, 1]
    ax.axis('off')
    
    # Calcular estatísticas
    stats_text = "Resumo de Desempenho\n" + "="*40 + "\n\n"
    
    for dataset in df['Dataset'].unique():
        data = df[df['Dataset'] == dataset]
        max_speedup = data['Speedup'].max()
        max_speedup_threads = data.loc[data['Speedup'].idxmax(), 'Threads']
        best_efficiency = data['Efficiency'].max()
        
        stats_text += f"Dataset: {dataset}\n"
        stats_text += f"  Melhor Speedup: {max_speedup:.2f}x ({int(max_speedup_threads)} threads)\n"
        stats_text += f"  Melhor Eficiência: {best_efficiency:.1f}%\n\n"
    
    ax.text(0.1, 0.9, stats_text, 
           transform=ax.transAxes,
           fontsize=10,
           verticalalignment='top',
           fontfamily='monospace',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.suptitle('K-means 1D - Análise de Desempenho OpenMP', 
                fontsize=16, fontweight='bold')
    plt.tight_layout()
    
    output_file = os.path.join(output_dir, 'combined_analysis.png')
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"✓ Gráfico combinado salvo: {output_file}")
    plt.close()

def generate_report(df, output_dir='results/benchmarks'):
    """Gera relatório textual com estatísticas"""
    report = []
    report.append("="*60)
    report.append("RELATÓRIO DE DESEMPENHO - K-means 1D OpenMP")
    report.append("="*60)
    report.append("")
    
    for dataset in df['Dataset'].unique():
        data = df[df['Dataset'] == dataset].sort_values('Threads')
        
        report.append(f"\n{'='*60}")
        report.append(f"Dataset: {dataset.upper()}")
        report.append(f"{'='*60}")
        report.append("")
        report.append(f"{'Threads':<10} {'Tempo (ms)':<15} {'Speedup':<12} {'Eficiência':<12}")
        report.append("-"*60)
        
        for _, row in data.iterrows():
            report.append(f"{int(row['Threads']):<10} "
                        f"{row['Time_ms']:<15.2f} "
                        f"{row['Speedup']:<12.2f} "
                        f"{row['Efficiency']:<12.1f}%")
        
        # Estatísticas
        report.append("")
        report.append("Estatísticas:")
        report.append(f"  • Melhor Speedup: {data['Speedup'].max():.2f}x "
                     f"({int(data.loc[data['Speedup'].idxmax(), 'Threads'])} threads)")
        report.append(f"  • Melhor Eficiência: {data['Efficiency'].max():.1f}% "
                     f"({int(data.loc[data['Efficiency'].idxmax(), 'Threads'])} threads)")
        report.append(f"  • Tempo Serial: {data.loc[data['Threads']==1, 'Time_ms'].values[0]:.2f} ms")
        report.append(f"  • Tempo Paralelo (max threads): "
                     f"{data['Time_ms'].min():.2f} ms")
        
        # Análise de escalabilidade
        report.append("")
        report.append("Análise de Escalabilidade:")
        
        if data['Speedup'].max() >= 0.9 * data['Threads'].max():
            report.append("  • Excelente escalabilidade (próximo ao ideal)")
        elif data['Speedup'].max() >= 0.7 * data['Threads'].max():
            report.append("  • Boa escalabilidade")
        elif data['Speedup'].max() >= 0.5 * data['Threads'].max():
            report.append("  • Escalabilidade moderada")
        else:
            report.append("  • Escalabilidade limitada")
        
        if data['Efficiency'].iloc[-1] > 70:
            report.append("  • Eficiência mantida mesmo com muitos threads")
        elif data['Efficiency'].iloc[-1] > 50:
            report.append("  • Eficiência razoável com muitos threads")
        else:
            report.append("  • Perda significativa de eficiência com muitos threads")
    
    report.append("")
    report.append("="*60)
    report.append("FIM DO RELATÓRIO")
    report.append("="*60)
    
    # Salvar relatório
    output_file = os.path.join(output_dir, 'performance_report.txt')
    with open(output_file, 'w') as f:
        f.write('\n'.join(report))
    
    print(f"✓ Relatório salvo: {output_file}")
    
    # Também imprimir no console
    print("\n" + '\n'.join(report))

def main():
    """Função principal"""
    print("="*60)
    print("K-means 1D - Análise de Resultados OpenMP")
    print("="*60)
    print()
    
    # Carregar dados
    print("Carregando resultados...")
    df = load_results()
    print(f"✓ {len(df)} registros carregados")
    print()
    
    # Gerar gráficos
    print("Gerando gráficos...")
    plot_speedup(df)
    plot_efficiency(df)
    plot_execution_time(df)
    plot_combined(df)
    print()
    
    # Gerar relatório
    print("Gerando relatório...")
    generate_report(df)
    print()
    
    print("="*60)
    print("Análise concluída!")
    print("="*60)
    print()
    print("Arquivos gerados:")
    print("  • results/benchmarks/speedup_plot.png")
    print("  • results/benchmarks/efficiency_plot.png")
    print("  • results/benchmarks/execution_time_plot.png")
    print("  • results/benchmarks/combined_analysis.png")
    print("  • results/benchmarks/performance_report.txt")

if __name__ == '__main__':
    main()