#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Perform Exploratory Factor Analysis on translation validation results
"""

import pandas as pd
import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.impute import SimpleImputer
from scipy.stats import zscore
import warnings
warnings.filterwarnings('ignore')

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

def prepare_data(df):
    """Prepare data for analysis."""
    analysis_cols = [
        'semantic_similarity',
        'sentiment_difference',
        'source_only_entities',
        'target_only_entities'
    ]
    
    # Extract relevant columns
    data = df[analysis_cols]
    
    # Print initial statistics
    print("\nInitial Data Statistics:")
    print(data.describe())
    print("\nMissing Values:")
    print(data.isnull().sum())
    
    # Handle missing values
    imputer = SimpleImputer(strategy='mean')
    data_imputed = pd.DataFrame(
        imputer.fit_transform(data),
        columns=data.columns
    )
    
    # Standardize the data
    data_std = pd.DataFrame(
        zscore(data_imputed),
        columns=analysis_cols
    )
    
    print("\nProcessed Data Statistics:")
    print(data_std.describe())
    
    return data_std

def create_correlation_heatmap(df, output_path):
    """Create correlation heatmap."""
    plt.figure(figsize=(10, 8))
    
    # Calculate correlation matrix
    corr = df.corr()
    
    # Create mask for upper triangle
    mask = np.triu(np.ones_like(corr, dtype=bool))
    
    # Create heatmap
    sns.heatmap(corr, mask=mask, annot=True, cmap='RdBu', center=0,
                fmt='.2f', square=True, cbar_kws={'label': 'Correlation'})
    
    plt.title('Correlation Matrix of Variables', pad=20)
    plt.tight_layout()
    plt.savefig(output_path / 'correlation_matrix.png', bbox_inches='tight')
    plt.close()
    
    return corr

def perform_pca(data):
    """Perform PCA analysis."""
    pca = PCA()
    pca.fit(data)
    return pca

def create_scree_plot(pca, output_path):
    """Create scree plot of explained variance."""
    plt.figure(figsize=(10, 6))
    
    explained_var = pca.explained_variance_ratio_ * 100
    cum_explained_var = np.cumsum(explained_var)
    
    plt.plot(range(1, len(explained_var) + 1), explained_var, 'bo-', label='Individual')
    plt.plot(range(1, len(explained_var) + 1), cum_explained_var, 'ro-', label='Cumulative')
    
    plt.axhline(y=80, color='g', linestyle='--', label='80% Threshold')
    
    plt.title('Scree Plot of Explained Variance', pad=20)
    plt.xlabel('Principal Component')
    plt.ylabel('Explained Variance (%)')
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(output_path / 'scree_plot.png', bbox_inches='tight')
    plt.close()

def create_loading_plot(pca, feature_names, output_path):
    """Create loading plot for first two components."""
    loadings = pd.DataFrame(
        pca.components_.T,
        columns=[f'PC{i+1}' for i in range(len(feature_names))],
        index=feature_names
    )
    
    # Plot loadings for first two components
    plt.figure(figsize=(10, 10))
    for i, feature in enumerate(feature_names):
        plt.arrow(0, 0, loadings.iloc[i, 0], loadings.iloc[i, 1],
                 head_width=0.05, head_length=0.05, fc='k', ec='k')
        plt.text(loadings.iloc[i, 0] * 1.15, loadings.iloc[i, 1] * 1.15,
                feature, ha='center', va='center')
    
    plt.grid(True, alpha=0.3)
    plt.axhline(y=0, color='k', linestyle='-', alpha=0.3)
    plt.axvline(x=0, color='k', linestyle='-', alpha=0.3)
    
    # Add a circle
    circle = plt.Circle((0,0), 1, facecolor='none', edgecolor='k', alpha=0.3)
    plt.gca().add_patch(circle)
    
    plt.xlabel(f'PC1 ({pca.explained_variance_ratio_[0]:.1%})')
    plt.ylabel(f'PC2 ({pca.explained_variance_ratio_[1]:.1%})')
    plt.title('PCA Loading Plot', pad=20)
    
    # Make the plot more square
    plt.axis('equal')
    plt.tight_layout()
    plt.savefig(output_path / 'loading_plot.png', bbox_inches='tight')
    plt.close()
    
    return loadings

def main():
    # Set up paths
    script_dir = Path(__file__).parent
    results_path = script_dir.parent / 'reports' / 'validation_results.xlsx'
    output_path = script_dir.parent / 'reports' / 'figures'
    output_path.mkdir(exist_ok=True)
    
    # Load and prepare data
    df = pd.read_excel(results_path)
    data_std = prepare_data(df)
    
    # Set style
    set_style()
    
    # Create correlation heatmap
    corr = create_correlation_heatmap(data_std, output_path)
    print("\nCorrelation Matrix:")
    print(corr)
    
    # Perform PCA
    pca = perform_pca(data_std)
    
    # Create visualizations
    create_scree_plot(pca, output_path)
    loadings = create_loading_plot(pca, data_std.columns, output_path)
    
    # Print explained variance
    print("\nExplained Variance Ratio:")
    for i, var in enumerate(pca.explained_variance_ratio_, 1):
        print(f"PC{i}: {var:.3%}")
    
    print("\nCumulative Explained Variance:")
    cum_var = np.cumsum(pca.explained_variance_ratio_)
    for i, var in enumerate(cum_var, 1):
        print(f"PC1 to PC{i}: {var:.3%}")
    
    print("\nComponent Loadings:")
    print(loadings)

if __name__ == '__main__':
    main() 