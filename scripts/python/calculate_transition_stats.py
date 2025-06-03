import pandas as pd
import numpy as np

# Read the data
df = pd.read_excel('data/raw/raw_transspezifische_eng.xlsx')

# Define the transition-related columns
transition_cols = ['EHT', 'AA', 'THT', 'VT', 'LE', 'FFS', 'CMS', 'BA', 'HE', 'NV', 'PH', 'VCS', 'CR', 'OMI']

# Create a function to calculate statistics
def calculate_stats(data, group_name=""):
    stats = []
    for col in transition_cols:
        if col in data.columns:
            n = data[col].sum()
            pct = (data[col].sum() / len(data)) * 100 if len(data) > 0 else 0
            stats.append({
                'Group': group_name,
                'Intervention': col,
                'n': n,
                'Percentage': f"{pct:.1f}"
            })
    return pd.DataFrame(stats)

# Split data by sex assigned at birth
amab_df = df[df['Sex assigned at birth'] == 'Männlich (AMAB: Assigned Male At Birth)']
afab_df = df[df['Sex assigned at birth'] == 'Weiblich (AFAB: Assigned Female At Birth)']

# Calculate statistics for each group
amab_stats = calculate_stats(amab_df, "AMAB")
afab_stats = calculate_stats(afab_df, "AFAB")
total_stats = calculate_stats(df, "Total")

# Combine all statistics
all_stats = pd.concat([amab_stats, afab_stats, total_stats])

# Save results
all_stats.to_csv('data/processed/transition_measures_frequency_by_group.csv', index=False)

# Print table in markdown format
print("\nTable X")
print("Medical Transition Interventions by Sex Assigned at Birth (N = 293)")
print(f"AMAB: n = {len(amab_df)}, AFAB: n = {len(afab_df)}")
print("\n| Intervention | AMAB (n) | AMAB % | AFAB (n) | AFAB % | Total (n) | Total % |")
print("|--------------|-----------|---------|-----------|---------|-----------|---------|")

interventions = {
    'EHT': 'Estrogen hormone therapy (EHT)',
    'AA': 'Anti-androgen therapy (AA)',
    'THT': 'Testosterone hormone therapy (THT)',
    'VT': 'Voice therapy (VT)',
    'LE': 'Laser epilation (LE)',
    'FFS': 'Facial feminization surgery (FFS)',
    'CMS': 'Chest masculinization surgery (CMS)',
    'BA': 'Breast augmentation (BA)',
    'HE': 'Hysterectomy (HE)',
    'NV': 'Neovaginoplasty (NV)',
    'PH': 'Phalloplasty (PH)',
    'VCS': 'Vocal cord surgery (VCS)',
    'CR': 'Chondrolaryngoplasty (CR)',
    'OMI': 'Other medical interventions (OMI)'
}

for intervention in transition_cols:
    amab_row = amab_stats[amab_stats['Intervention'] == intervention].iloc[0]
    afab_row = afab_stats[afab_stats['Intervention'] == intervention].iloc[0]
    total_row = total_stats[total_stats['Intervention'] == intervention].iloc[0]
    
    print(f"| {interventions[intervention]} | {int(amab_row['n'])} | {amab_row['Percentage']} | {int(afab_row['n'])} | {afab_row['Percentage']} | {int(total_row['n'])} | {total_row['Percentage']} |")

print("\nResults have been saved to data/processed/transition_measures_frequency_by_group.csv") 