import pandas as pd
import numpy as np

# Read the data
df = pd.read_excel('data/raw/raw_transspezifische_eng.xlsx')

# Create a copy of the original data
df_cleaned = df.copy()

# Function to identify cases to remove
def mark_invalid_cases(row):
    # Initialize as valid
    is_valid = True
    
    # Check AMAB cases
    if row['Sex assigned at birth'] == 'Männlich (AMAB: Assigned Male At Birth)':
        # Remove cases with HE (Hysterectomy)
        if row['HE'] == 1:
            is_valid = False
            
    # Check AFAB cases
    if row['Sex assigned at birth'] == 'Weiblich (AFAB: Assigned Female At Birth)':
        # Remove cases with NV (Neovaginoplasty)
        if row['NV'] == 1:
            is_valid = False
            
    # Keep non-binary/genderfluid cases
    if row['Gender identity'] in ['non binär/abinär', 'genderfluid', 'anderes']:
        is_valid = True
        
    return is_valid

# Apply cleaning
df_cleaned['is_valid'] = df_cleaned.apply(mark_invalid_cases, axis=1)

# Count removed cases
removed_cases = len(df) - len(df_cleaned[df_cleaned['is_valid']])
print(f"\nNumber of cases removed: {removed_cases}")

# Save cleaned data
df_cleaned[df_cleaned['is_valid']].to_excel('data/processed/transition_data_cleaned.xlsx', index=False)

# Recalculate statistics with cleaned data
clean_df = df_cleaned[df_cleaned['is_valid']]

# Define the transition-related columns
transition_cols = ['EHT', 'AA', 'THT', 'VT', 'LE', 'FFS', 'CMS', 'BA', 'HE', 'NV', 'PH', 'VCS', 'CR', 'OMI']

# Split data by sex assigned at birth
amab_df = clean_df[clean_df['Sex assigned at birth'] == 'Männlich (AMAB: Assigned Male At Birth)']
afab_df = clean_df[clean_df['Sex assigned at birth'] == 'Weiblich (AFAB: Assigned Female At Birth)']

# Print updated statistics
print("\nUpdated Statistics:")
print(f"Total valid cases: {len(clean_df)}")
print(f"AMAB cases: {len(amab_df)}")
print(f"AFAB cases: {len(afab_df)}")

# Create updated frequency table
print("\nUpdated Intervention Frequencies:")
print("| Intervention | AMAB (n) | AMAB % | AFAB (n) | AFAB % | Total (n) | Total % |")
print("|--------------|-----------|---------|-----------|---------|-----------|---------|")

for col in transition_cols:
    amab_n = amab_df[col].sum()
    amab_pct = (amab_n / len(amab_df)) * 100 if len(amab_df) > 0 else 0
    
    afab_n = afab_df[col].sum()
    afab_pct = (afab_n / len(afab_df)) * 100 if len(afab_df) > 0 else 0
    
    total_n = clean_df[col].sum()
    total_pct = (total_n / len(clean_df)) * 100 if len(clean_df) > 0 else 0
    
    print(f"| {col} | {int(amab_n)} | {amab_pct:.1f} | {int(afab_n)} | {afab_pct:.1f} | {int(total_n)} | {total_pct:.1f} |") 