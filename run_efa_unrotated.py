import pandas as pd
import numpy as np
from factor_analyzer import FactorAnalyzer
from factor_analyzer.factor_analyzer import calculate_kmo
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.cluster import hierarchy
from scipy.spatial.distance import pdist, squareform

# Plotting style
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = [12, 8]

# Theoretische Subskalen
subscales = {
    "GEN": {"name": "Genitalia", "items": [14, 21, 25, 26, 27, 29]},
    "CH": {"name": "Chest", "items": [15, 18, 28, 30]},
    "SSC": {"name": "Other secondary sex characteristics", "items": [17, 23, 24]},
    "SGR": {"name": "Social gender role recognition", "items": [16, 19, 20, 22]},
    "PEI": {"name": "Physical and emotional intimacy", "items": [3, 5, 32, 33]},
    "PF": {"name": "Psychological functioning", "items": [1, 2, 4, 6, 7, 8, 9, 11, 12, 13]},
    "LS": {"name": "Life satisfaction", "items": [10, 31, 34, 35, 36, 37, 38]}
}

# Daten einlesen
df = pd.read_excel('data/deutsch_data_numeric_recoded.xlsx')

# EFA durchführen ohne Rotation
n_factors = 7  # basierend auf vorheriger Analyse
fa_unrot = FactorAnalyzer(rotation=None, n_factors=n_factors)
fa_unrot.fit(df)

# Unrotierte Faktorladungen
loadings_unrot = pd.DataFrame(
    fa_unrot.loadings_,
    columns=[f'Faktor {i+1}' for i in range(n_factors)],
    index=df.columns
)

# Distanzmatrix für Items basierend auf Faktorladungen
dist_matrix = pdist(loadings_unrot.values, metric='euclidean')
linkage = hierarchy.linkage(dist_matrix, method='ward')

# Sortierung der Items nach hierarchischer Clusterung
dendro = hierarchy.dendrogram(linkage, labels=loadings_unrot.index, no_plot=True)
item_order = dendro['leaves']

# Sortierte Faktorladungsmatrix
loadings_sorted = loadings_unrot.iloc[item_order]

# Erstellen der kombinierten Visualisierung
fig = plt.figure(figsize=(15, 20))

# Dendrogramm oben (1/5 der Höhe)
ax1 = plt.subplot2grid((5, 1), (0, 0), rowspan=1)
hierarchy.dendrogram(linkage, 
                    labels=loadings_unrot.index,
                    leaf_rotation=0,
                    ax=ax1)
ax1.set_title('Dendrogramm der Items (unrotierte Lösung)')
ax1.set_xticklabels([])

# Heatmap unten (4/5 der Höhe)
ax2 = plt.subplot2grid((5, 1), (1, 0), rowspan=4)
sns.heatmap(loadings_sorted,
            cmap='RdBu_r',
            center=0,
            vmin=-1,
            vmax=1,
            annot=True,
            fmt='.2f',
            cbar_kws={'label': 'Faktorladung'},
            ax=ax2)
ax2.set_title('Heatmap der unrotierten Faktorladungen')
ax2.set_xticklabels(ax2.get_xticklabels(), rotation=45, ha='right')
ax2.set_yticklabels(ax2.get_yticklabels(), rotation=0)

plt.tight_layout()
plt.savefig('data/factor_loadings_unrotated.png', dpi=300, bbox_inches='tight')
plt.close()

# Vergleich der Varianzaufklärung
var_unrot = fa_unrot.get_factor_variance()
print("\nVarianzaufklärung (unrotiert):")
for i in range(n_factors):
    print(f"Faktor {i+1}: {(var_unrot[1][i] * 100).round(2)}%")

# Ausgabe der Ladungen für alle Faktoren
print("\nSignifikante Ladungen (|λ| > 0.3) für alle Faktoren:")
for factor in range(n_factors):
    print(f"\nFaktor {factor+1} (Varianz: {(var_unrot[1][factor] * 100).round(2)}%):")
    # Positive Ladungen
    pos_loads = loadings_unrot[f'Faktor {factor+1}'][loadings_unrot[f'Faktor {factor+1}'] > 0.3]
    if not pos_loads.empty:
        print("  Positive Ladungen:")
        for item, load in pos_loads.items():
            # Finde die zugehörige Subskala
            subscale = next((scale for scale, info in subscales.items() 
                           if int(item[1:]) in info['items']), '?')
            print(f"    {item} ({subscale}): {load:.3f}")
    
    # Negative Ladungen
    neg_loads = loadings_unrot[f'Faktor {factor+1}'][loadings_unrot[f'Faktor {factor+1}'] < -0.3]
    if not neg_loads.empty:
        print("  Negative Ladungen:")
        for item, load in neg_loads.items():
            # Finde die zugehörige Subskala
            subscale = next((scale for scale, info in subscales.items() 
                           if int(item[1:]) in info['items']), '?')
            print(f"    {item} ({subscale}): {load:.3f}")

print("\nVisualisierung wurde gespeichert als: data/factor_loadings_unrotated.png") 