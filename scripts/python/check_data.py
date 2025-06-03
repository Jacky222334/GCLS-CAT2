import pandas as pd
import numpy as np

# Read the data
data = pd.read_excel("data/raw/raw_quest_all.xlsx")

# Print all column names
print("\nAll column names:")
print("=" * 50)
for col in data.columns:
    print(col)

# Print first few rows of medical measure columns
print("\nFirst few rows of medical measure columns:")
print("=" * 50)
med_cols = [col for col in data.columns if col.startswith('@9')]
print(data[med_cols].head())

print("\nSpalten mit 'sf' oder 'pcs' oder 'mcs':")
print("=" * 50)
for col in data.columns:
    if any(term in col.lower() for term in ['sf', 'pcs', 'mcs']):
        print(col)

print("\nExakte Spaltennamen:")
print("=" * 50)
for col in data.columns:
    if '9falls' in col:
        print(f"\n{repr(col)}")  # Using repr to show exact string
        print(data[col].value_counts().head())

# Medical measures columns
med_measures = {
    'Hormontherapie': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_a',
    'Mastektomie': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_b',
    'Hysterektomie': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_c',
    'Ovarektomie': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_d',
    'Vaginektomie': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_e',
    'Kolpektomie': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_f',
    'Phalloplastik': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_g',
    'Metoidioplastik': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_h',
    'Mammaplastik': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_i',
    'Orchidektomie': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_j',
    'Penektomie': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_k',
    'Vaginoplastik': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_l',
    'Vulvaplastik': '@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_m'
}

print("\nDatentypen und Werte der medizinischen Maßnahmen:")
print("=" * 50)
for name, col in med_measures.items():
    if col in data.columns:
        print(f"\n{name}:")
        print(f"Datentyp: {data[col].dtype}")
        print("Werte:")
        print(data[col].value_counts()) 