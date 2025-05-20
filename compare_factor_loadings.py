import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from factor_analyzer import FactorAnalyzer
from factor_analyzer.factor_analyzer import calculate_kmo
from scipy.stats import spearmanr
from scipy.cluster import hierarchy
from scipy.spatial.distance import pdist, squareform

# Theoretische Subskalen (zur Orientierung)
subscales = {
    "GEN": {"name": "Genitalia", "items": [14, 21, 25, 26, 27, 29]},
    "CH": {"name": "Chest", "items": [15, 18, 28, 30]},
    "SSC": {"name": "Other secondary sex characteristics", "items": [17, 23, 24]},
    "SGR": {"name": "Social gender role recognition", "items": [16, 19, 20, 22]},
    "PEI": {"name": "Physical and emotional intimacy", "items": [3, 5, 32, 33]},
    "PF": {"name": "Psychological functioning", "items": [1, 2, 4, 6, 7, 8, 9, 11, 12, 13]},
    "LS": {"name": "Life satisfaction", "items": [10, 31, 34, 35, 36, 37, 38]}
}

# Deutsche Daten einlesen
print("Lade deutsche Daten...")
df = pd.read_excel('data/raw/deutsch_data_numeric_recoded.xlsx')

# 1. Eignung der Daten für Faktorenanalyse prüfen
print("\n1. Prüfe Eignung der Daten für Faktorenanalyse:")
kmo_all, kmo_model = calculate_kmo(df)
print(f"KMO Score: {kmo_model:.3f}")

# 2. Scree Plot erstellen
print("\n2. Erstelle Scree Plot...")
fa = FactorAnalyzer(rotation=None, n_factors=df.shape[1])
fa.fit(df)
ev, v = fa.get_eigenvalues()
plt.figure(figsize=(10, 6))
plt.plot(range(1, df.shape[1] + 1), ev)
plt.title('Scree Plot')
plt.xlabel('Faktoren')
plt.ylabel('Eigenwert')
plt.axhline(y=1, color='r', linestyle='--')
plt.savefig('data/scree_plot.png')
plt.close()

# Anzahl der Faktoren mit Eigenwert > 1
n_factors = sum(ev > 1)
print(f"\nAnzahl Faktoren mit Eigenwert > 1: {n_factors}")
print("\nEigenwerte > 1:")
for i, eigenvalue in enumerate(ev, 1):
    if eigenvalue > 1:
        print(f"Faktor {i}: {eigenvalue:.2f}")

# 3. Faktorenanalyse mit Varimax-Rotation
print("\n3. Führe Faktorenanalyse durch...")
fa_rot = FactorAnalyzer(rotation='varimax', n_factors=n_factors)
fa_rot.fit(df)
loadings = pd.DataFrame(
    fa_rot.loadings_,
    columns=[f'Faktor{i+1}' for i in range(n_factors)],
    index=[f'Item{i+1}' for i in range(38)]
)

# Varianzaufklärung
print("\nVarianzaufklärung:")
# Berechne erklärte Varianz für jeden Faktor
explained_var = (loadings ** 2).sum() / df.shape[1]
cumulative_var = explained_var.cumsum()
print("\nErklärte Varianz pro Faktor:")
for i, var in enumerate(explained_var, 1):
    print(f"Faktor {i}: {var:.3f} ({cumulative_var[i-1]:.3f} kumulativ)")

# 4. Faktorladungen anzeigen (nur Ladungen > 0.3)
print("\n4. Faktorladungen (nur > 0.3):")
loadings_display = loadings.copy()
loadings_display[abs(loadings_display) < 0.3] = ''
print(loadings_display.round(3))

# 5. Heatmap mit Dendrogramm
print("\n5. Erstelle Heatmap mit Dendrogramm...")
plt.figure(figsize=(15, 10))

# Berechne Distanzmatrizen
item_linkage = hierarchy.linkage(pdist(loadings), method='ward')
factor_linkage = hierarchy.linkage(pdist(loadings.T), method='ward')

# Erstelle Grid für Subplots
gs = plt.GridSpec(2, 2, width_ratios=[0.2, 1], height_ratios=[0.2, 1])

# Dendrogramm für Faktoren (oben)
ax_factor_dendrogram = plt.subplot(gs[0, 1])
hierarchy.dendrogram(factor_linkage, ax=ax_factor_dendrogram, labels=loadings.columns)
ax_factor_dendrogram.set_xticklabels([])
ax_factor_dendrogram.set_xticks([])

# Dendrogramm für Items (links)
ax_item_dendrogram = plt.subplot(gs[1, 0])
hierarchy.dendrogram(item_linkage, ax=ax_item_dendrogram, orientation='left', labels=loadings.index)
ax_item_dendrogram.set_yticklabels([])
ax_item_dendrogram.set_yticks([])

# Heatmap
ax_heatmap = plt.subplot(gs[1, 1])
# Ordne die Daten entsprechend der Dendrogramme
idx_items = hierarchy.dendrogram(item_linkage, no_plot=True)['leaves']
idx_factors = hierarchy.dendrogram(factor_linkage, no_plot=True)['leaves']
data_ordered = loadings.iloc[idx_items, idx_factors]

sns.heatmap(data_ordered, 
            cmap='RdBu_r',
            center=0,
            vmin=-1,
            vmax=1,
            annot=True,
            fmt='.2f',
            ax=ax_heatmap)

plt.suptitle('Faktorladungen der deutschen Version mit hierarchischer Clusterung', fontsize=14)
plt.tight_layout()
plt.savefig('data/factor_loadings_dendrogram.png', dpi=300, bbox_inches='tight')
plt.close()

# 6. Items nach Faktoren gruppieren
print("\n5. Items pro Faktor (Hauptladungen):")
for factor in loadings.columns:
    items = loadings.index[abs(loadings[factor]) == abs(loadings).max(axis=1)].tolist()
    print(f"\n{factor}:")
    for item in items:
        loading = loadings.loc[item, factor]
        print(f"{item}: {loading:.3f}")

# 7. Speichere detaillierte Ergebnisse
results = pd.DataFrame({
    'Item': loadings.index,
    'Stärkster_Faktor': [loadings.columns[abs(row).argmax()] for _, row in loadings.iterrows()],
    'Ladung': [row[abs(row).argmax()] for _, row in loadings.iterrows()]
})
results.to_csv('data/factor_analysis_results.csv', index=False)

print("\nAnalyse abgeschlossen. Ergebnisse wurden in 'data/factor_analysis_results.csv' gespeichert.")
print("Visualisierungen wurden in 'data/scree_plot.png' und 'data/factor_loadings_dendrogram.png' gespeichert.")

# Berechne und zeige Korrelationen zwischen den Faktoren
print("\nKorrelationen zwischen den Faktoren:")
factor_corr = loadings.corr()
plt.figure(figsize=(10, 8))
sns.heatmap(factor_corr, 
            cmap='RdBu_r',
            center=0,
            vmin=-1,
            vmax=1,
            annot=True,
            fmt='.2f')
plt.title('Korrelationen zwischen den Faktoren')
plt.tight_layout()
plt.savefig('data/factor_correlations.png', dpi=300, bbox_inches='tight')
plt.close()

# Vergleich der Faktorladungen nach Subskalen
print('\nVergleich der Faktorladungen nach Subskalen:')
for subscale, info in subscales.items():
    print(f'\n{subscale} - {info["name"]}:')
    print('Item  |  Stärkster ENG Faktor (Ladung)  |  Stärkster DE Faktor (Ladung)')
    print('-' * 70)
    
    for item in info['items']:
        # Englische Version - stärkste Ladung finden
        eng_loadings = eng_data.loc[f'I{item}']
        eng_strongest = eng_loadings.abs().idxmax()
        eng_value = eng_loadings[eng_strongest]
        
        # Deutsche Version - stärkste Ladung finden
        ger_loadings = ger_data.loc[f'I{item}']
        ger_strongest = ger_loadings.abs().idxmax()
        ger_value = ger_loadings[ger_strongest]
        
        print(f'I{item:2d}  |  {eng_strongest:3s} ({eng_value:6.2f})  |  {ger_strongest:3s} ({ger_value:6.2f})') 