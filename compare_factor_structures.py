import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import pearsonr
from scipy.spatial.distance import cosine
import warnings
warnings.filterwarnings('ignore')

# Set plotting style
plt.style.use('default')
sns.set_theme(style="whitegrid")

def load_data():
    # Load German data
    df_german = pd.read_excel('data/processed/deutsch_data_numeric_recoded.xlsx')
    
    # Load English loadings
    df_eng = pd.read_csv('data/eng_version_loading.csv', sep=';')
    df_eng = df_eng.set_index('Item Number')
    
    return df_german, df_eng

def perform_german_efa(df_german):
    from factor_analyzer import FactorAnalyzer
    
    # Perform EFA
    n_factors = 7  # based on previous analysis
    fa = FactorAnalyzer(rotation='varimax', n_factors=n_factors)
    fa.fit(df_german)
    
    # Get loadings
    loadings = pd.DataFrame(
        fa.loadings_,
        columns=[f'Factor{i+1}' for i in range(n_factors)],
        index=df_german.columns
    )
    
    return loadings

def calculate_similarity_metrics(german_loadings, english_loadings):
    # Ensure same number of factors
    n_factors = min(german_loadings.shape[1], english_loadings.shape[1])
    
    # Calculate correlations between factors
    correlations = np.zeros((n_factors, n_factors))
    for i in range(n_factors):
        for j in range(n_factors):
            corr, _ = pearsonr(german_loadings.iloc[:, i], english_loadings.iloc[:, j])
            correlations[i, j] = corr
    
    # Calculate cosine similarity for each factor pair
    cosine_similarities = np.zeros((n_factors, n_factors))
    for i in range(n_factors):
        for j in range(n_factors):
            sim = 1 - cosine(german_loadings.iloc[:, i], english_loadings.iloc[:, j])
            cosine_similarities[i, j] = sim
    
    return correlations, cosine_similarities

def plot_comparison(german_loadings, english_loadings, correlations, cosine_similarities):
    fig = plt.figure(figsize=(20, 15))
    
    # Plot German loadings
    ax1 = plt.subplot2grid((3, 2), (0, 0))
    sns.heatmap(german_loadings, cmap='RdBu_r', center=0, vmin=-1, vmax=1,
                annot=True, fmt='.2f', ax=ax1)
    ax1.set_title('German Version Factor Loadings')
    
    # Plot English loadings
    ax2 = plt.subplot2grid((3, 2), (0, 1))
    sns.heatmap(english_loadings, cmap='RdBu_r', center=0, vmin=-1, vmax=1,
                annot=True, fmt='.2f', ax=ax2)
    ax2.set_title('English Version Factor Loadings')
    
    # Plot correlations
    ax3 = plt.subplot2grid((3, 2), (1, 0))
    sns.heatmap(correlations, cmap='YlOrRd', vmin=0, vmax=1,
                annot=True, fmt='.2f', ax=ax3)
    ax3.set_title('Factor Correlations')
    
    # Plot cosine similarities
    ax4 = plt.subplot2grid((3, 2), (1, 1))
    sns.heatmap(cosine_similarities, cmap='YlOrRd', vmin=0, vmax=1,
                annot=True, fmt='.2f', ax=ax4)
    ax4.set_title('Factor Cosine Similarities')
    
    plt.tight_layout()
    plt.savefig('figures/factor_structure_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()

def generate_report(german_loadings, english_loadings, correlations, cosine_similarities):
    report = []
    report.append("Factor Structure Comparison Report")
    report.append("=" * 50)
    
    # Overall similarity
    mean_corr = np.mean(correlations)
    mean_cosine = np.mean(cosine_similarities)
    report.append(f"\nOverall Similarity Metrics:")
    report.append(f"Mean Factor Correlation: {mean_corr:.3f}")
    report.append(f"Mean Cosine Similarity: {mean_cosine:.3f}")
    
    # Factor-by-factor comparison
    report.append("\nFactor-by-Factor Comparison:")
    for i in range(correlations.shape[0]):
        best_match = np.argmax(correlations[i])
        report.append(f"\nGerman Factor {i+1} best matches English Factor {best_match+1}")
        report.append(f"Correlation: {correlations[i, best_match]:.3f}")
        report.append(f"Cosine Similarity: {cosine_similarities[i, best_match]:.3f}")
        
        # Add item-level comparison for the best matching factors
        report.append("\nTop 5 items in German Factor:")
        german_items = german_loadings.iloc[:, i].sort_values(ascending=False).head()
        for item, loading in german_items.items():
            report.append(f"{item}: {loading:.3f}")
            
        report.append("\nTop 5 items in English Factor:")
        english_items = english_loadings.iloc[:, best_match].sort_values(ascending=False).head()
        for item, loading in english_items.items():
            report.append(f"Item {item}: {loading:.3f}")
    
    # Save report
    with open('data/factor_comparison_report.txt', 'w') as f:
        f.write('\n'.join(report))

def main():
    # Load data
    df_german, df_eng = load_data()
    
    # Perform EFA on German data
    german_loadings = perform_german_efa(df_german)
    
    # Calculate similarity metrics
    correlations, cosine_similarities = calculate_similarity_metrics(
        german_loadings, df_eng
    )
    
    # Create visualizations
    plot_comparison(german_loadings, df_eng, correlations, cosine_similarities)
    
    # Generate report
    generate_report(german_loadings, df_eng, correlations, cosine_similarities)
    
    print("Analysis complete. Check figures/factor_structure_comparison.png and data/factor_comparison_report.txt for results.")

if __name__ == "__main__":
    main() 