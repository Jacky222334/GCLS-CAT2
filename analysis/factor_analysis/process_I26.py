import pandas as pd

# Read the Excel file
df = pd.read_excel('../../data/raw/I26_op.xlsx')

# Create new column - set to 0 if either column B or C contains 1
df['I26_processed'] = 0
mask = (df.iloc[:, 1] != 1) & (df.iloc[:, 2] != 1)  # columns B and C are at index 1 and 2
df.loc[mask, 'I26_processed'] = df.loc[mask, 'I26']  # keep original value if neither B nor C is 1

# Save back to the same file with the new column
df.to_excel('../../data/raw/I26_op.xlsx', index=False) 