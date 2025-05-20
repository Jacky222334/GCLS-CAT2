import pandas as pd
import numpy as np
from factor_analyzer import FactorAnalyzer
from factor_analyzer.factor_analyzer import calculate_kmo
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.cluster import hierarchy
from scipy.stats import spearmanr

# Plotting style
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = [12, 8]

# Daten einlesen
df = pd.read_excel('data/deutsch_data_numeric_recoded.xlsx')

# KMO und Bartlett's Test
kmo_all, kmo_model = calculate_kmo(df)
print('KMO Score:', round(kmo_model, 3))

# Scree Plot
fa = FactorAnalyzer(rotation=None, n_factors=38)
fa.fit(df)
ev, v = fa.get_eigenvalues()

plt.figure(figsize=(10, 6))
plt.plot(range(1, 39), ev, 'bo-')
plt.axhline(y=1, color='r', linestyle='--')
plt.title('Scree Plot')
plt.xlabel('Faktoren')
plt.ylabel('Eigenwert')
plt.savefig('data/scree_plot.png', dpi=300, bbox_inches='tight')
plt.close()

# Anzahl der Faktoren
n_factors = sum(ev > 1)
print(f'\nAnzahl Faktoren (Eigenwert > 1): {n_factors}')
print('Eigenwerte > 1:', ev[ev > 1].round(3))

# EFA mit Varimax-Rotation
fa_rot = FactorAnalyzer(rotation='varimax', n_factors=n_factors)
fa_rot.fit(df)

# Varianzaufklärung
var_explained = fa_rot.get_factor_variance()
total_var = var_explained[1].sum()

# Faktorladungen
loadings = pd.DataFrame(
    fa_rot.loadings_,
    columns=[f'Faktor {i+1}' for i in range(n_factors)],
    index=df.columns
)

# Heatmap der Faktorladungen
plt.figure(figsize=(15, 10))
sns.heatmap(loadings, 
            cmap='RdBu_r',
            center=0,
            vmin=-1, 
            vmax=1,
            annot=True,
            fmt='.2f',
            cbar_kws={'label': 'Faktorladung'})
plt.title('Heatmap der Faktorladungen')
plt.tight_layout()
plt.savefig('data/factor_heatmap.png', dpi=300, bbox_inches='tight')
plt.close()

# Korrelationsmatrix und Dendrogramm
corr = df.corr(method='spearman')
linkage = hierarchy.linkage(corr, method='ward')

plt.figure(figsize=(15, 10))
dendro = hierarchy.dendrogram(linkage, 
                            labels=df.columns,
                            leaf_rotation=90)
plt.title('Dendrogramm der Items')
plt.tight_layout()
plt.savefig('data/dendrogram.png', dpi=300, bbox_inches='tight')
plt.close()

# Heatmap der Korrelationsmatrix mit Dendrogramm
g = sns.clustermap(corr,
                   cmap='RdBu_r',
                   center=0,
                   vmin=-1,
                   vmax=1,
                   method='ward',
                   annot=True,
                   fmt='.2f',
                   figsize=(20, 20))
plt.savefig('data/correlation_heatmap.png', dpi=300, bbox_inches='tight')
plt.close()

# Detaillierte Analyse der Faktoren
print('\nDetaillierte Faktoranalyse:')
for factor in range(n_factors):
    factor_name = f'Faktor {factor+1}'
    print(f'\n{factor_name}:')
    # Items mit Ladungen > 0.3 für diesen Faktor
    factor_loadings = loadings[factor_name].sort_values(ascending=False)
    significant_items = factor_loadings[abs(factor_loadings) > 0.3]
    print(f'Varianzaufklärung: {(var_explained[1][factor] * 100).round(2)}%')
    print('Items (Ladung > 0.3):')
    for item, loading in significant_items.items():
        print(f'{item}: {loading:.3f}')

print(f'\nGesamtvarianzaufklärung: {(total_var * 100).round(2)}%')

# Kommunalitäten
communalities = pd.Series(fa_rot.get_communalities(), index=df.columns)
print('\nKommunalitäten:')
print(communalities.round(3))

# Ergebnisse speichern
output_file = 'data/efa_detailed_results.xlsx'
with pd.ExcelWriter(output_file) as writer:
    loadings.round(3).to_excel(writer, sheet_name='Faktorladungen')
    pd.DataFrame(communalities).round(3).to_excel(writer, sheet_name='Kommunalitäten')
    corr.round(3).to_excel(writer, sheet_name='Korrelationsmatrix')

print(f'\nErgebnisse wurden gespeichert in: {output_file}')
print('Visualisierungen wurden gespeichert als:')
print('- data/scree_plot.png')
print('- data/factor_heatmap.png')
print('- data/dendrogram.png')
print('- data/correlation_heatmap.png') 