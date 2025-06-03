#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Create publication-quality visualizations of the translation validation results
"""

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
import numpy as np

def set_style():
    """Set publication-ready style for plots."""
    plt.style.use('seaborn-v0_8-paper')
    sns.set_palette("deep")
    plt.rcParams['font.family'] = 'sans-serif'
    plt.rcParams['font.sans-serif'] = ['Arial']
    plt.rcParams['font.size'] = 11
    plt.rcParams['axes.labelsize'] = 12
    plt.rcParams['axes.titlesize'] = 14
    plt.rcParams['figure.titlesize'] = 16
    plt.rcParams['figure.dpi'] = 300

def create_similarity_distribution(df, output_path):
    """Create violin plot of semantic similarity scores."""
    plt.figure(figsize=(10, 6))
    
    # Create violin plot
    sns.violinplot(y=df['semantic_similarity'], color='#3498db', alpha=0.6)
    sns.stripplot(y=df['semantic_similarity'], color='#2c3e50', alpha=0.4, size=4)
    
    # Add threshold line
    plt.axhline(y=0.85, color='#e74c3c', linestyle='--', alpha=0.8, label='Threshold (0.85)')
    
    plt.title('Distribution of Semantic Similarity Scores', pad=20)
    plt.ylabel('Semantic Similarity Score')
    plt.legend()
    
    # Add statistics annotation
    stats_text = f'Mean: {df["semantic_similarity"].mean():.3f}\nStd: {df["semantic_similarity"].std():.3f}'
    plt.text(0.02, 0.98, stats_text, transform=plt.gca().transAxes, 
             verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig(output_path / 'similarity_distribution.png', bbox_inches='tight')
    plt.close()

def create_similarity_heatmap(df, output_path):
    """Create heatmap of similarity scores vs sentiment differences."""
    plt.figure(figsize=(12, 8))
    
    # Create 2D histogram
    hist2d = plt.hist2d(df['semantic_similarity'], df['sentiment_difference'],
                       bins=20, cmap='YlOrRd', density=True)
    plt.colorbar(label='Density')
    
    plt.title('Relationship between Semantic Similarity and Sentiment Difference', pad=20)
    plt.xlabel('Semantic Similarity Score')
    plt.ylabel('Sentiment Difference')
    
    # Add threshold lines
    plt.axvline(x=0.85, color='#e74c3c', linestyle='--', alpha=0.8, label='Similarity Threshold')
    
    plt.legend()
    plt.tight_layout()
    plt.savefig(output_path / 'similarity_sentiment_heatmap.png', bbox_inches='tight')
    plt.close()

def create_item_comparison(df, output_path):
    """Create comparison plot of items."""
    plt.figure(figsize=(15, 8))
    
    # Sort by similarity score
    df_sorted = df.sort_values('semantic_similarity', ascending=True)
    
    # Create bar plot
    x = range(len(df_sorted))
    plt.bar(x, df_sorted['semantic_similarity'], color='#3498db', alpha=0.6)
    
    # Add threshold line
    plt.axhline(y=0.85, color='#e74c3c', linestyle='--', alpha=0.8, label='Threshold (0.85)')
    
    plt.title('Semantic Similarity Scores by Item', pad=20)
    plt.xlabel('Item Number')
    plt.ylabel('Semantic Similarity Score')
    
    # Rotate x-axis labels
    plt.xticks(x, df_sorted['item_number'], rotation=45)
    
    # Add grid
    plt.grid(True, alpha=0.3)
    plt.legend()
    
    plt.tight_layout()
    plt.savefig(output_path / 'item_comparison.png', bbox_inches='tight')
    plt.close()

def create_entity_analysis(df, output_path):
    """Create analysis of named entities."""
    plt.figure(figsize=(10, 6))
    
    # Calculate entity statistics
    entity_data = {
        'Matched': df['matched_entities'].mean(),
        'Source Only': df['source_only_entities'].mean(),
        'Target Only': df['target_only_entities'].mean()
    }
    
    # Create bar plot
    colors = ['#2ecc71', '#e74c3c', '#f1c40f']
    plt.bar(entity_data.keys(), entity_data.values(), color=colors, alpha=0.7)
    
    plt.title('Average Named Entity Distribution', pad=20)
    plt.ylabel('Average Number of Entities')
    
    # Add value labels
    for i, v in enumerate(entity_data.values()):
        plt.text(i, v, f'{v:.2f}', ha='center', va='bottom')
    
    plt.tight_layout()
    plt.savefig(output_path / 'entity_analysis.png', bbox_inches='tight')
    plt.close()

def main():
    # Set up paths
    script_dir = Path(__file__).parent
    results_path = script_dir.parent / 'reports' / 'validation_results.xlsx'
    output_path = script_dir.parent / 'reports' / 'figures'
    output_path.mkdir(exist_ok=True)
    
    # Load results
    df = pd.read_excel(results_path)
    
    # Set style
    set_style()
    
    # Create visualizations
    create_similarity_distribution(df, output_path)
    create_similarity_heatmap(df, output_path)
    create_item_comparison(df, output_path)
    create_entity_analysis(df, output_path)
    
    print(f"Visualizations saved to: {output_path}")

if __name__ == '__main__':
    main() 