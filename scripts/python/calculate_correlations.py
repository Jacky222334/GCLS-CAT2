import pandas as pd
import numpy as np
from scipy import stats

# Read the data
data = pd.read_excel("data/raw/raw_quest_all.xlsx")

# Define GCLS subscales (using g1-g38 columns)
subscales = {
    'Psychological functioning': ['g1', 'g2', 'g3', 'g4', 'g5', 'g6', 'g7'],
    'Gender role recognition': ['g8', 'g9', 'g10', 'g11', 'g12'],
    'Social support': ['g13', 'g14', 'g15', 'g16', 'g17'],
    'Physical and emotional intimacy': ['g18', 'g19', 'g20', 'g21'],
    'Other secondary sex characteristics': ['g22', 'g23', 'g24', 'g25', 'g26'],
    'Life satisfaction': ['g27', 'g28', 'g29', 'g30', 'g31', 'g32'],
    'Global': list(f'g{i}' for i in range(1, 39))  # g1 through g38
}

# Calculate subscale means
for subscale, items in subscales.items():
    data[f'gcls_{subscale.lower().replace(" ", "_")}'] = data[items].mean(axis=1)

# Calculate correlations with ZUF-8
correlations = []
p_values = []

for subscale in subscales.keys():
    gcls_col = f'gcls_{subscale.lower().replace(" ", "_")}'
    corr, p = stats.spearmanr(data[gcls_col], data['zuf_score'], nan_policy='omit')
    correlations.append(corr)
    p_values.append(p)

# Create results table
results = pd.DataFrame({
    'GCLS subscales': list(subscales.keys()),
    'ZUF-8': [f'{corr:.2f}{"**" if p < 0.001 else "*" if p < 0.05 else ""}' 
              for corr, p in zip(correlations, p_values)]
})

# Print table
print("\nTable. One-tailed Spearman's Rho correlations between the GCLS and the ZUF-8")
print("(trans-gender participants only).")
print("\nGCLS subscales" + " " * 30 + "ZUF-8")
print("-" * 50)
for _, row in results.iterrows():
    print(f"{row['GCLS subscales']:<40}{row['ZUF-8']:>5}")
print("\nNote: GCLS: Gender Congruence and Life Satisfaction Scale; ZUF-8: Patient Satisfaction Questionnaire-8")
print("* p < .05;")
print("** p < .001;")

def calculate_correlations():
    """
    Calculate Spearman correlations between GCLS subscales and ZUF-8.
    """
    # Read GCLS data
    gcls_data = pd.read_excel("data/raw/deutsch_data_numeric_recoded.xlsx")
    
    # Read questionnaire data
    quest_data = pd.read_excel("data/raw/raw_quest_all.xlsx")
    
    # GCLS subscales
    gcls_subscales = {
        'GCLS psychological functioning': ['I1', 'I2', 'I4', 'I6', 'I7', 'I8', 'I9', 'I11', 'I12', 'I13'],
        'GCLS genitalia': ['I14', 'I21', 'I25', 'I26', 'I27', 'I29'],
        'GCLS social gender role recognition': ['I16', 'I19', 'I20', 'I22'],
        'GCLS physical and emotional intimacy': ['I3', 'I5', 'I32', 'I33'],
        'GCLS chest': ['I15', 'I18', 'I28', 'I30'],
        'GCLS other secondary sex characteristics': ['I17', 'I23', 'I24'],
        'GCLS life satisfaction': ['I10', 'I31', 'I34', 'I35', 'I36', 'I37', 'I38'],
        'GCLS total score': ['I' + str(i) for i in range(1, 39) if i != 26]  # Excluding item 26
    }
    
    # Calculate GCLS subscale scores
    scores = pd.DataFrame()
    for subscale, items in gcls_subscales.items():
        scores[subscale] = gcls_data[items].mean(axis=1)
    
    # Add ZUF-8 scores
    zuf_items = {
        'ZUF-8 Item 1 (Qualität)': 'zuf_1',
        'ZUF-8 Item 2 (Erwartung)': 'zuf_2',
        'ZUF-8 Item 3 (Bedürfnisse)': 'zuf_3',
        'ZUF-8 Item 4 (Weiterempfehlung)': 'zuf_4',
        'ZUF-8 Item 5 (Ausmaß der Hilfe)': 'zuf_5',
        'ZUF-8 Item 6 (Umgang)': 'zuf_6',
        'ZUF-8 Item 7 (Zufriedenheit gesamt)': 'zuf_7',
        'ZUF-8 Item 8 (Wiederkommen)': 'zuf_8',
        'ZUF-8 Gesamtscore': 'zuf_score'
    }
    
    # Add ZUF-8 scores from quest_data
    for measure_name, column in zuf_items.items():
        if column in quest_data.columns:
            scores[measure_name] = quest_data[column].values[:len(scores)]
    
    # Calculate correlation matrix
    corr_matrix = scores.corr(method='spearman')
    
    # Format for printing
    def format_correlation(val):
        if pd.isna(val):
            return '-'
        return f"{val:.2f}"
    
    # Print formatted matrix
    print("\nSpearman's Rho Korrelationsmatrix zwischen GCLS und ZUF-8:")
    print("=" * 120)
    
    # Number the columns
    cols = corr_matrix.columns
    print("\n" + " " * 45 + "".join(f"{i+1:>8}" for i in range(len(cols))))
    
    # Print each row with numbers and correlations
    for i, row in enumerate(cols):
        # Print row name with number
        print(f"{i+1:2d} {row[:42]:42s}", end="")
        
        # Print correlations
        for j, col in enumerate(cols):
            if j >= i:  # Only print upper triangle
                val = corr_matrix.loc[row, col]
                print(f"{format_correlation(val):>8}", end="")
            else:
                print(" " * 8, end="")
        print()  # New line after each row
    
    # Print legend
    print("\nLegende:")
    for i, col in enumerate(cols, 1):
        print(f"{i:2d}: {col}")
    
    # Save to file
    corr_matrix.round(2).to_csv('data/processed/correlation_matrix_zuf8.csv')
    
    return corr_matrix

if __name__ == "__main__":
    correlations = calculate_correlations() 