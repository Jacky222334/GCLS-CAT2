import pandas as pd

# Read the Excel file
df = pd.read_excel('../../data/raw/rwa_demo_trans_transpez_labeled.xlsx')

# Print original values and total
print("\nOriginal Gender Identity values:")
original_counts = df['Gender identity'].value_counts()
print(original_counts)
print(f"\nTotal before recoding: {len(df)}")

# First map the clear categories
df['Gender identity'] = df['Gender identity'].replace({
    'weiblich': 'Woman (AMAB)',
    'männlich': 'Man (AFAB)'
})

# Then map everything else to Non-binary (AMAB/AFAB)
mask = ~df['Gender identity'].isin(['Woman (AMAB)', 'Man (AFAB)'])
df.loc[mask, 'Gender identity'] = 'Non-binary (AMAB/AFAB)'

# Print recoded values and total
print("\nRecoded Gender Identity values:")
recoded_counts = df['Gender identity'].value_counts()
print(recoded_counts)
print(f"\nTotal after recoding: {len(df)}")

# Verify the sums
print("\nVerification:")
print(f"Original sum: {original_counts.sum()}")
print(f"Recoded sum: {recoded_counts.sum()}")

# Save back to the same file
df.to_excel('../../data/raw/rwa_demo_trans_transpez_labeled.xlsx', index=False) 