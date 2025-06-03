import pandas as pd

# Read the Excel file
df = pd.read_excel('../../data/raw/rwa_demo_trans_transpez_labeled.xlsx')

# Print column names
print("\nColumn names in the dataset:")
for i, col in enumerate(df.columns):
    print(f"{i}: {col}")

# Print first few rows to see the data structure
print("\nFirst few rows of the dataset:")
print(df.head()) 