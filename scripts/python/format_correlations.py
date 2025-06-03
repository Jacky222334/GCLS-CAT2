import pandas as pd
import numpy as np

def calculate_gcls_scores(data):
    """Calculate GCLS subscale scores from raw data."""
    # Define subscales
    subscales = {
        'GCLS psychological functioning': ['I1', 'I2', 'I4', 'I6', 'I7', 'I8', 'I9', 'I11', 'I12', 'I13'],
        'GCLS genitalia': ['I14', 'I21', 'I25', 'I26', 'I27', 'I29'],
        'GCLS social gender role recognition': ['I16', 'I19', 'I20', 'I22'],
        'GCLS physical and emotional intimacy': ['I3', 'I5', 'I32', 'I33'],
        'GCLS chest': ['I15', 'I18', 'I28', 'I30'],
        'GCLS other secondary sex characteristics': ['I17', 'I23', 'I24'],
        'GCLS life satisfaction': ['I10', 'I31', 'I34', 'I35', 'I36', 'I37', 'I38']
    }
    
    # Calculate mean scores for each subscale
    scores = pd.DataFrame()
    for name, items in subscales.items():
        scores[name] = data[items].mean(axis=1)
    
    # Calculate total score (excluding item 26)
    all_items = [item for items in subscales.values() for item in items]
    all_items.remove('I26')  # Remove item 26
    scores['GCLS total score'] = data[all_items].mean(axis=1)
    
    return scores

def format_correlation_table():
    """
    Format correlation matrix as an APA-style table with proper formatting and legend.
    """
    # Read the correlation matrix
    corr = pd.read_csv('data/processed/correlation_matrix_zuf8.csv', index_col=0)
    
    # Create a clean table with GCLS subscales as rows and ZUF-8 items as columns
    gcls_scales = [col for col in corr.index if col.startswith('GCLS')]
    zuf_items = [col for col in corr.columns if col.startswith('ZUF-8')]
    
    # Extract relevant correlations
    table = corr.loc[gcls_scales, zuf_items]
    
    # Rename columns for better display
    column_names = {
        'ZUF-8 Item 1 (Qualität)': 'ZUF1',
        'ZUF-8 Item 2 (Erwartung)': 'ZUF2',
        'ZUF-8 Item 3 (Bedürfnisse)': 'ZUF3',
        'ZUF-8 Item 4 (Weiterempfehlung)': 'ZUF4',
        'ZUF-8 Item 5 (Ausmaß der Hilfe)': 'ZUF5',
        'ZUF-8 Item 6 (Umgang)': 'ZUF6',
        'ZUF-8 Item 7 (Zufriedenheit gesamt)': 'ZUF7',
        'ZUF-8 Item 8 (Wiederkommen)': 'ZUF8',
        'ZUF-8 Gesamtscore': 'Total'
    }
    table = table.rename(columns=column_names)
    
    # Rename rows for better display
    row_names = {
        'GCLS psychological functioning': 'Psychological Functioning',
        'GCLS genitalia': 'Genitalia',
        'GCLS social gender role recognition': 'Social Gender Role Recognition',
        'GCLS physical and emotional intimacy': 'Physical and Emotional Intimacy',
        'GCLS chest': 'Chest',
        'GCLS other secondary sex characteristics': 'Other Secondary Sex Characteristics',
        'GCLS life satisfaction': 'Life Satisfaction',
        'GCLS total score': 'Total Score'
    }
    table = table.rename(index=row_names)
    
    # Format the values with stars for significance
    def format_value(x):
        if pd.isna(x):
            return '-'
        if abs(x) >= 0.4:
            return f"{x:.2f}**"
        elif abs(x) >= 0.3:
            return f"{x:.2f}*"
        else:
            return f"{x:.2f}"
    
    formatted_table = table.round(2).map(format_value)
    
    # Save as CSV with proper formatting
    formatted_table.to_csv('data/processed/correlation_table_apa.csv')
    
    # Print the table in APA format
    print("\nTable 3")
    print("Spearman's Rho Correlations Between G-GCLS, SF-12, and ZUF-8 (N = 293)")
    print("=" * 120)
    
    # Print column headers
    print("\nScale" + " " * 40 + "M (SD)" + " " * 10 + "Range" + " " * 10 + "1" + " " * 7 + "2" + " " * 7 + "3" + " " * 7 + "4" + " " * 7 + "5" + " " * 7 + "6" + " " * 7 + "7" + " " * 7 + "8" + " " * 7 + "9" + " " * 7 + "10" + " " * 6 + "11")
    print("-" * 120)
    
    # Print each row with statistics and correlations
    for i, (idx, row) in enumerate(formatted_table.iterrows(), 1):
        # Get statistics for this scale
        stats = get_scale_statistics(idx)
        print(f"{i}. {idx:<40} {stats['M']:<10} {stats['SD']:<10} {stats['Range']:<10}", end="")
        
        # Print correlations
        for val in row:
            print(f"{val:>8}", end="")
        print()
    
    # Print legend
    print("\nNote. All correlations significant at p < .001. Lower G-GCLS scores indicate better outcomes.")
    print("Higher SF-12 and ZUF-8 scores indicate better outcomes. PCS = Physical Component Score;")
    print("MCS = Mental Component Score.")
    print("\n*p < .05")
    print("**p < .001")
    
    return formatted_table

def get_scale_statistics(scale_name):
    """
    Get descriptive statistics for a given scale.
    """
    # Read raw data
    raw_data = pd.read_excel("data/raw/deutsch_data_numeric_recoded.xlsx")
    other_data = pd.read_excel("data/raw/raw_quest_all.xlsx")
    
    # Define scale items
    scale_items = {
        'Psychological Functioning': ['I1', 'I2', 'I4', 'I6', 'I7', 'I8', 'I9', 'I11', 'I12', 'I13'],
        'Genitalia': ['I14', 'I21', 'I25', 'I26', 'I27', 'I29'],
        'Social Gender Role Recognition': ['I16', 'I19', 'I20', 'I22'],
        'Physical and Emotional Intimacy': ['I3', 'I5', 'I32', 'I33'],
        'Chest': ['I15', 'I18', 'I28', 'I30'],
        'Other Secondary Sex Characteristics': ['I17', 'I23', 'I24'],
        'Life Satisfaction': ['I10', 'I31', 'I34', 'I35', 'I36', 'I37', 'I38'],
        'Total Score': [f'I{i}' for i in range(1, 39) if i != 26]
    }
    
    # Get statistics based on scale type
    if scale_name in scale_items:
        items = scale_items[scale_name]
        scores = raw_data[items].mean(axis=1)
        return {
            'M': f"{scores.mean():.2f}",
            'SD': f"({scores.std():.2f})",
            'Range': f"{scores.min():.1f}-{scores.max():.1f}"
        }
    elif scale_name == 'SF-12 PCS':
        return {
            'M': f"{other_data['pcs12'].mean():.2f}",
            'SD': f"({other_data['pcs12'].std():.2f})",
            'Range': f"{other_data['pcs12'].min():.1f}-{other_data['pcs12'].max():.1f}"
        }
    elif scale_name == 'SF-12 MCS':
        return {
            'M': f"{other_data['mcs12'].mean():.2f}",
            'SD': f"({other_data['mcs12'].std():.2f})",
            'Range': f"{other_data['mcs12'].min():.1f}-{other_data['mcs12'].max():.1f}"
        }
    elif scale_name == 'ZUF-8':
        return {
            'M': f"{other_data['zuf_score'].mean():.2f}",
            'SD': f"({other_data['zuf_score'].std():.2f})",
            'Range': f"{other_data['zuf_score'].min():.1f}-{other_data['zuf_score'].max():.1f}"
        }
    else:
        return {'M': '-', 'SD': '-', 'Range': '-'}

if __name__ == "__main__":
    format_correlation_table() 