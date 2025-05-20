import pandas as pd
import numpy as np
from factor_analyzer import FactorAnalyzer
from factor_analyzer.factor_analyzer import calculate_kmo
import matplotlib.pyplot as plt
from scipy import stats

# Daten einlesen
df = pd.read_excel('data/deutsch_data_numeric_recoded.xlsx')

# KMO und Bartlett's Test
kmo_all, kmo_model = calculate_kmo(df)
print('KMO Score:', round(kmo_model, 3))

# Scree Plot vorbereiten
fa = FactorAnalyzer(rotation=None, n_factors=38)
fa.fit(df)
ev, v = fa.get_eigenvalues()
print('\nEigenwerte:', ev[:10].round(3))

# Anzahl der Faktoren basierend auf Eigenwert > 1
n_factors = sum(ev > 1)
print(f'\nAnzahl Faktoren (Eigenwert > 1): {n_factors}')

# EFA mit der ermittelten Anzahl von Faktoren
fa_rot = FactorAnalyzer(rotation='varimax', n_factors=n_factors)
fa_rot.fit(df)

# Faktorladungen
loadings = pd.DataFrame(
    fa_rot.loadings_,
    columns=[f'Factor{i+1}' for i in range(n_factors)],
    index=df.columns
)

# Nur Ladungen > 0.3 anzeigen
loadings_cleaned = loadings.copy()
loadings_cleaned[abs(loadings_cleaned) < 0.3] = np.nan

# Varianzaufklärung
var_explained = fa_rot.get_factor_variance()
variance = pd.DataFrame(
    var_explained[1].reshape(1, -1),  # Proportion of Variance
    columns=[f'Factor{i+1}' for i in range(n_factors)],
    index=['Variance Explained']
)

print('\nVarianzaufklärung pro Faktor:')
print(variance.round(3))

print('\nGesamtvarianzaufklärung:', variance.sum(axis=1).values[0].round(3))

print('\nFaktorladungen (> 0.3):')
pd.set_option('display.max_rows', None)
print(loadings_cleaned.round(3))

# Ergebnisse speichern
output_file = 'data/efa_results.xlsx'
with pd.ExcelWriter(output_file) as writer:
    loadings.round(3).to_excel(writer, sheet_name='Faktorladungen')
    loadings_cleaned.round(3).to_excel(writer, sheet_name='Faktorladungen_bereinigt')
    variance.round(3).to_excel(writer, sheet_name='Varianzaufklärung')

print(f'\nErgebnisse wurden gespeichert in: {output_file}') 