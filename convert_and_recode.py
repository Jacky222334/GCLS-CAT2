import pandas as pd
import numpy as np

# Einlesen der Datei
df = pd.read_excel('data/raw_gcls_strings1.xlsx')

# Mapping für die Umwandlung von Strings in Zahlen
mapping = {
    'Nie': 1,
    'Never': 1,
    'Selten': 2,
    'Rarely': 2,
    'Manchmal': 3,
    'Sometimes': 3,
    'Oft': 4,
    'Often': 4,
    'Immer': 5,
    'Always': 5
}

# Alle Spalten mit dem Mapping umwandeln
for col in df.columns:
    df[col] = df[col].map(mapping)

# Liste der umzupolenden Items
items_to_reverse = ['I16', 'I20', 'I22', 'I25', 'I30', 'I31', 'I32', 'I33', 'I34', 'I36', 'I38']

# Umpolen der spezifizierten Items (neu = 6 - roh)
df[items_to_reverse] = 6 - df[items_to_reverse]

# Speichern der Ergebnisse
output_file = 'data/gcls_numeric_recoded.xlsx'
df.to_excel(output_file, index=False)

# Überprüfung
print("\nÜberprüfung der Umwandlung:")
print(df.head())

# Überprüfung der Wertebereiche
print("\nWertebereich pro Spalte:")
for col in df.columns:
    print(f"{col}: {df[col].unique()}")

print(f"\nDatei wurde gespeichert als: {output_file}") 