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

# Daten einlesen
df = pd.read_excel('data/deutsch_data_numeric_recoded.xlsx')

# EFA durchführen
n_factors = 7  # basierend auf vorheriger Analyse
fa_rot = FactorAnalyzer(rotation='varimax', n_factors=n_factors)
fa_rot.fit(df)

# Faktorladungen
loadings = pd.DataFrame(
    fa_rot.loadings_,
    columns=[f'Faktor {i+1}' for i in range(n_factors)],
    index=df.columns
)

# Distanzmatrix für Items basierend auf Faktorladungen
# Verwendung der euklidischen Distanz zwischen Faktorladungsprofilen
dist_matrix = pdist(loadings.values, metric='euclidean')
linkage = hierarchy.linkage(dist_matrix, method='ward')

# Sortierung der Items nach hierarchischer Clusterung
dendro = hierarchy.dendrogram(linkage, labels=loadings.index, no_plot=True)
item_order = dendro['leaves']

# Sortierte Faktorladungsmatrix
loadings_sorted = loadings.iloc[item_order]

# Erstellen der kombinierten Visualisierung
fig = plt.figure(figsize=(15, 20))

# Dendrogramm oben
ax1 = plt.subplot2grid((3, 1), (0, 0), rowspan=1)
hierarchy.dendrogram(linkage, 
                    labels=loadings.index,
                    leaf_rotation=0,
                    ax=ax1)
ax1.set_title('Dendrogramm der Items basierend auf Faktorladungen')
ax1.set_xticklabels([])

# Heatmap unten
ax2 = plt.subplot2grid((3, 1), (1, 0), rowspan=2)
sns.heatmap(loadings_sorted,
            cmap='RdBu_r',
            center=0,
            vmin=-1,
            vmax=1,
            annot=True,
            fmt='.2f',
            cbar_kws={'label': 'Faktorladung'},
            ax=ax2)
ax2.set_title('Heatmap der Faktorladungen')
ax2.set_xticklabels(ax2.get_xticklabels(), rotation=45, ha='right')
ax2.set_yticklabels(ax2.get_yticklabels(), rotation=0)

plt.tight_layout()
plt.savefig('data/factor_loadings_clustered.png', dpi=300, bbox_inches='tight')
plt.close()

# Ausgabe der Cluster-Struktur
print("\nCluster-Struktur der Items basierend auf Faktorladungen:")
n_clusters = 5  # Anzahl der zu identifizierenden Cluster
clusters = hierarchy.fcluster(linkage, n_clusters, criterion='maxclust')
cluster_df = pd.DataFrame({'Item': loadings.index, 'Cluster': clusters})
cluster_df = cluster_df.sort_values('Cluster')

for cluster in range(1, n_clusters + 1):
    items = cluster_df[cluster_df['Cluster'] == cluster]['Item'].tolist()
    print(f"\nCluster {cluster}:")
    print(", ".join(items))

print("\nVisualisierung wurde gespeichert als: data/factor_loadings_clustered.png") 