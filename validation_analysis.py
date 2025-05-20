import pandas as pd
import numpy as np
from factor_analyzer import FactorAnalyzer
from scipy import stats
import pingouin as pg
import seaborn as sns
import matplotlib.pyplot as plt

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

# 1. Reliabilitätsanalyse
print("\n=== Reliabilitätsanalyse ===")
reliability_results = {}
for scale, info in subscales.items():
    # Extrahiere Items für diese Subskala
    scale_items = [f'I{i}' for i in info['items']]
    scale_data = df[scale_items]
    
    # Berechne Cronbach's Alpha
    alpha = pg.cronbach_alpha(data=scale_data)
    
    # Berechne Item-Total Korrelationen
    item_total_corr = {}
    for item in scale_items:
        other_items = [i for i in scale_items if i != item]
        total = scale_data[other_items].sum(axis=1)
        item_total_corr[item] = stats.pearsonr(scale_data[item], total)[0]
    
    reliability_results[scale] = {
        'alpha': alpha[0],
        'item_total_corr': item_total_corr
    }

    print(f"\nSubskala: {scale} - {info['name']}")
    print(f"Cronbach's Alpha: {alpha[0]:.3f}")
    print("Item-Total Korrelationen:")
    for item, corr in item_total_corr.items():
        print(f"  {item}: {corr:.3f}")

# 2. Inter-Skalen-Korrelationen
print("\n=== Inter-Skalen-Korrelationen ===")
scale_scores = {}
for scale, info in subscales.items():
    scale_items = [f'I{i}' for i in info['items']]
    scale_scores[scale] = df[scale_items].mean(axis=1)

scale_corr = pd.DataFrame(scale_scores).corr()

# Visualisiere Inter-Skalen-Korrelationen
plt.figure(figsize=(10, 8))
sns.heatmap(scale_corr, 
            annot=True, 
            fmt='.2f', 
            cmap='RdBu_r',
            center=0,
            vmin=-1,
            vmax=1)
plt.title('Inter-Skalen-Korrelationen')
plt.tight_layout()
plt.savefig('data/subscale_correlations.png', dpi=300, bbox_inches='tight')
plt.close()

# 3. Deskriptive Statistiken
print("\n=== Deskriptive Statistiken ===")
descriptives = pd.DataFrame(scale_scores).describe()
print("\nMittelwerte und Standardabweichungen der Subskalen:")
print(descriptives.loc[['mean', 'std']].round(3))

# 4. Konvergente Validität (AVE)
print("\n=== Konvergente Validität ===")
fa = FactorAnalyzer(rotation=None, n_factors=7)
fa.fit(df)
loadings = pd.DataFrame(
    fa.loadings_,
    columns=[f'F{i+1}' for i in range(7)],
    index=df.columns
)

ave_values = {}
for scale, info in subscales.items():
    scale_items = [f'I{i}' for i in info['items']]
    # Nehme die höchsten Ladungen für jedes Item
    max_loadings = loadings.loc[scale_items].max(axis=1)
    ave = (max_loadings ** 2).mean()
    ave_values[scale] = ave
    print(f"{scale} AVE: {ave:.3f}")

# Speichere alle Ergebnisse
results = {
    'reliability': reliability_results,
    'correlations': scale_corr.to_dict(),
    'descriptives': descriptives.to_dict(),
    'ave': ave_values
}

# Speichere Ergebnisse als JSON
import json
with open('data/validation_results.json', 'w') as f:
    json.dump(results, f, indent=4)

print("\nAlle Ergebnisse wurden in 'data/validation_results.json' gespeichert.")
print("Inter-Skalen-Korrelationen wurden in 'data/subscale_correlations.png' visualisiert.") 