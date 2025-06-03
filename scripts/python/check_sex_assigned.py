import pandas as pd

# Read the data
df = pd.read_excel('data/raw/raw_transspezifische_eng.xlsx')

# Check unique values in Sex assigned at birth column
print("\nUnique values in 'Sex assigned at birth' column:")
print(df['Sex assigned at birth'].unique())

# Print value counts
print("\nValue counts:")
print(df['Sex assigned at birth'].value_counts()) 