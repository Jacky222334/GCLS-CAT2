import pandas as pd
import numpy as np

def format_correlation_table():
    """
    Format correlation matrix as a clean table with proper labels and formatting.
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
        'GCLS psychological functioning': 'Psychologisches Funktionieren',
        'GCLS genitalia': 'Genitalien',
        'GCLS social gender role recognition': 'Soziale Geschlechtsrolle',
        'GCLS physical and emotional intimacy': 'Körperl./Emot. Intimität',
        'GCLS chest': 'Brust',
        'GCLS other secondary sex characteristics': 'Sek. Geschlechtsmerkmale',
        'GCLS life satisfaction': 'Lebenszufriedenheit',
        'GCLS total score': 'Gesamtscore'
    }
    table = table.rename(index=row_names)
    
    # Format the values with stars for significance
    def format_value(x):
        if abs(x) >= 0.4:
            return f"{x:.2f}**"
        elif abs(x) >= 0.3:
            return f"{x:.2f}*"
        else:
            return f"{x:.2f}"
    
    formatted_table = table.round(2).map(format_value)
    
    # Save as CSV with proper formatting
    formatted_table.to_csv('data/processed/correlation_table_formatted.csv')
    
    # Print the table
    print("\nKorrelationstabelle zwischen GCLS und ZUF-8:")
    print("=" * 80)
    print("\nKorrelationskoeffizienten (Spearman's Rho)")
    print(formatted_table.to_string())
    print("\nAnmerkungen:")
    print("* |r| ≥ 0.30")
    print("** |r| ≥ 0.40")
    print("\nAlle Korrelationen sind negativ aufgrund der unterschiedlichen Skalierung")
    print("(GCLS: niedrige Werte = besser; ZUF-8: hohe Werte = besser)")
    
    return formatted_table

if __name__ == "__main__":
    table = format_correlation_table() 