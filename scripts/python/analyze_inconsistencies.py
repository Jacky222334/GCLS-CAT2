import pandas as pd
import numpy as np

# Read the data
df = pd.read_excel('data/raw/raw_transspezifische_eng.xlsx')

# Define unexpected combinations
unexpected_amab = {
    'CMS': 'Chest masculinization surgery',
    'THT': 'Testosterone hormone therapy',
    'HE': 'Hysterectomy',
    'PH': 'Phalloplasty'
}

unexpected_afab = {
    'EHT': 'Estrogen hormone therapy',
    'AA': 'Anti-androgen therapy',
    'FFS': 'Facial feminization surgery',
    'BA': 'Breast augmentation',
    'NV': 'Neovaginoplasty',
    'CR': 'Chondrolaryngoplasty'
}

# Function to check individual cases
def check_cases(data, group_name, unexpected_interventions):
    print(f"\nAnalyzing unexpected cases for {group_name}:")
    for intervention, description in unexpected_interventions.items():
        if intervention in data.columns:
            cases = data[data[intervention] == 1]
            if len(cases) > 0:
                print(f"\n{description} ({intervention}):")
                print(f"Number of cases: {len(cases)}")
                # Print relevant information for each case
                for idx, row in cases.iterrows():
                    print(f"\nCase {idx}:")
                    print(f"Gender identity: {row['Gender identity'] if 'Gender identity' in row else 'N/A'}")
                    # Print other relevant medical interventions
                    interventions = [col for col in data.columns if col in ['EHT', 'AA', 'THT', 'VT', 'LE', 'FFS', 'CMS', 'BA', 'HE', 'NV', 'PH', 'VCS', 'CR', 'OMI']]
                    print("Other interventions:", [col for col in interventions if row[col] == 1])

# Analyze unexpected cases
amab_df = df[df['Sex assigned at birth'] == 'Männlich (AMAB: Assigned Male At Birth)']
afab_df = df[df['Sex assigned at birth'] == 'Weiblich (AFAB: Assigned Female At Birth)']

print("=== Analysis of Potentially Inconsistent Medical Intervention Data ===")
check_cases(amab_df, "AMAB", unexpected_amab)
check_cases(afab_df, "AFAB", unexpected_afab) 