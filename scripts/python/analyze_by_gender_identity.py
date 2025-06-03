import pandas as pd
import numpy as np

# Read the cleaned data
df = pd.read_excel('data/processed/transition_data_cleaned.xlsx')

# Define gender identity groups with assigned sex at birth
def categorize_gender_and_assigned_sex(row):
    identity = row['Gender identity']
    assigned_sex = row['Sex assigned at birth']
    
    if identity == 'weiblich':
        if assigned_sex == 'Männlich (AMAB: Assigned Male At Birth)':
            return 'Women (AMAB)'
        else:
            return 'Women (AFAB)'
    elif identity == 'männlich':
        if assigned_sex == 'Weiblich (AFAB: Assigned Female At Birth)':
            return 'Men (AFAB)'
        else:
            return 'Men (AMAB)'
    else:  # non binär/abinär, genderfluid, anderes
        if assigned_sex == 'Männlich (AMAB: Assigned Male At Birth)':
            return 'Non-binary (AMAB)'
        else:
            return 'Non-binary (AFAB)'

# Add gender category
df['gender_category'] = df.apply(categorize_gender_and_assigned_sex, axis=1)

# Define the transition-related columns
transition_cols = ['EHT', 'AA', 'THT', 'VT', 'LE', 'FFS', 'CMS', 'BA', 'HE', 'NV', 'PH', 'VCS', 'CR', 'OMI']

# Print group sizes
print("\nGruppengröße:")
women_amab_count = len(df[df['gender_category'] == 'Women (AMAB)'])
men_afab_count = len(df[df['gender_category'] == 'Men (AFAB)'])
nonbin_amab_count = len(df[df['gender_category'] == 'Non-binary (AMAB)'])
nonbin_afab_count = len(df[df['gender_category'] == 'Non-binary (AFAB)'])

print(f"Women (AMAB): n = {women_amab_count}")
print(f"Men (AFAB): n = {men_afab_count}")
print(f"Non-binary (AMAB/AFAB): n = {nonbin_amab_count + nonbin_afab_count} ({nonbin_amab_count}/{nonbin_afab_count})")
print("\n")

# Create frequency table
print("Interventionshäufigkeiten nach Geschlechtsidentität:")
print("-" * 100)
print(f"{'Intervention':<40} {'Women (AMAB)':<20} {'Men (AFAB)':<20} {'Non-binary (AMAB/AFAB)':<20}")
print("-" * 100)

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

# Prepare data for CSV
results_data = []

for col in transition_cols:
    women_amab_df = df[df['gender_category'] == 'Women (AMAB)']
    men_afab_df = df[df['gender_category'] == 'Men (AFAB)']
    nonbin_amab_df = df[df['gender_category'] == 'Non-binary (AMAB)']
    nonbin_afab_df = df[df['gender_category'] == 'Non-binary (AFAB)']
    
    women_amab_n = women_amab_df[col].sum()
    women_amab_pct = (women_amab_n / len(women_amab_df)) * 100 if len(women_amab_df) > 0 else 0
    
    men_afab_n = men_afab_df[col].sum()
    men_afab_pct = (men_afab_n / len(men_afab_df)) * 100 if len(men_afab_df) > 0 else 0
    
    nonbin_amab_n = nonbin_amab_df[col].sum()
    nonbin_afab_n = nonbin_afab_df[col].sum()
    nonbin_total = len(nonbin_amab_df) + len(nonbin_afab_df)
    nonbin_pct = ((nonbin_amab_n + nonbin_afab_n) / nonbin_total) * 100 if nonbin_total > 0 else 0
    
    print(f"{interventions[col]:<40} {f'n={int(women_amab_n)} ({women_amab_pct:.1f}%)':<20} {f'n={int(men_afab_n)} ({men_afab_pct:.1f}%)':<20} {f'n={int(nonbin_amab_n + nonbin_afab_n)} ({nonbin_amab_n}/{nonbin_afab_n}) ({nonbin_pct:.1f}%)':<20}")
    
    # Add data to results
    results_data.append({
        'Intervention': interventions[col],
        'Women_AMAB_n': int(women_amab_n),
        'Women_AMAB_%': round(women_amab_pct, 1),
        'Men_AFAB_n': int(men_afab_n),
        'Men_AFAB_%': round(men_afab_pct, 1),
        'Non_binary_n': int(nonbin_amab_n + nonbin_afab_n),
        'Non_binary_AMAB_n': int(nonbin_amab_n),
        'Non_binary_AFAB_n': int(nonbin_afab_n),
        'Non_binary_%': round(nonbin_pct, 1),
        'Total_n': int(women_amab_n + men_afab_n + nonbin_amab_n + nonbin_afab_n),
        'Total_%': round(((women_amab_n + men_afab_n + nonbin_amab_n + nonbin_afab_n) / len(df)) * 100, 1)
    })

print("-" * 100)

# Save results
results = pd.DataFrame(results_data)
results.to_csv('data/processed/transition_measures_by_identity.csv', index=False) 