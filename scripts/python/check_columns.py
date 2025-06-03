import pandas as pd
import numpy as np

# Read the data file
data = pd.read_excel("data/raw/raw_quest_all.xlsx")

# Print columns related to medical measures
print("\nSpalten zu medizinischen Maßnahmen:")
print("=" * 50)
for col in data.columns:
    if '9falls' in col.lower():
        print(f"\n{col}")
        print(data[col].value_counts())

# Print all column names containing 'phq' or related terms
print("\nSearching for PHQ-9 related columns:")
print("=" * 50)
for col in data.columns:
    if any(term in col.lower() for term in ['phq', 'depression', 'depress']):
        print(col)

# Print ZUF-8 related columns
print("\nZUF-8 related columns:")
print("=" * 50)
for col in data.columns:
    if any(term in col.lower() for term in ['zuf', 'zufriedenheit']):
        print(col)

# Read the correlation matrix
corr = pd.read_csv('data/processed/correlation_matrix_zuf8.csv', index_col=0)

print("\nVerfügbare Spalten in der Korrelationsmatrix:")
print("=" * 50)
for col in corr.columns:
    print(col)

# Read the Excel file
file_path = 'data/raw/raw_transspezifische_eng.xlsx'
df = pd.read_excel(file_path)

# Print all column names
print("\nAlle Spaltennamen:")
print(df.columns.tolist())

# Print specific columns we renamed (from EHT to OMI)
print("\nUmbenannte Spalten und ihre Position:")
target_columns = ['EHT', 'AA', 'THT', 'VT', 'LE', 'FFS', 'CMS', 'BA', 'HE', 'NV', 'PH', 'VCS', 'CR', 'OMI']
for col in target_columns:
    if col in df.columns:
        pos = df.columns.get_loc(col)
        print(f"{col} ist an Position {pos}") 