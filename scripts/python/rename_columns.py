import pandas as pd

# Read the Excel file
file_path = 'data/raw/raw_transspezifische_eng.xlsx'
df = pd.read_excel(file_path)

# Define the new column names using a dictionary
column_renames = {
    'Sex assigned at birth': 'Sex assigned at birth',
    'Self-identified gender identity': 'Gender identity',
    'Work': 'Employment status',
    'hrt_e': 'EHT',    # Estrogen hormone therapy
    't_block': 'AA',   # Anti-androgen therapy
    'hrt_t': 'THT',    # Testosterone hormone therapy
    'speech_t': 'VT',  # Voice therapy
    'laser_e': 'LE',   # Laser epilation
    'ffs': 'FFS',      # Facial feminization surgery
    'mastec': 'CMS',   # Chest masculinization surgery
    'ba': 'BA',        # Breast augmentation
    'hyst': 'HE',      # Hysterectomy
    'vag': 'NV',       # Neovaginoplasty
    'phallo': 'PH',    # Phalloplasty
    'vcs': 'VCS',      # Vocal cord surgery
    'trac': 'CR',      # Chondrolaryngoplasty
    'other': 'OMI'     # Other medical interventions
}

# Rename the columns
df = df.rename(columns=column_renames)

# Save the modified DataFrame back to Excel
df.to_excel(file_path, index=False)

print("Column names have been updated successfully.") 