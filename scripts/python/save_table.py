import pandas as pd
import numpy as np
from calculate_gcls_scores import calculate_gcls_scores

def create_formatted_table():
    # Read raw data
    raw_data = pd.read_excel("data/raw/deutsch_data_numeric_recoded.xlsx")
    other_data = pd.read_excel("data/raw/raw_quest_all.xlsx")
    
    # Calculate GCLS scores
    gcls_scores, _ = calculate_gcls_scores(raw_data)  # Unpack tuple
    
    # Calculate descriptive statistics
    stats = pd.DataFrame()
    for col in gcls_scores.columns:
        stats.loc['M', col] = gcls_scores[col].mean()
        stats.loc['SD', col] = gcls_scores[col].std()
        stats.loc['Range', col] = f"{gcls_scores[col].min():.1f}-{gcls_scores[col].max():.1f}"
    
    # Add SF-12 and ZUF-8 stats
    for col, name in [('pcs12', 'SF-12 PCS'), ('mcs12', 'SF-12 MCS'), ('zuf_score', 'ZUF-8')]:
        stats.loc['M', name] = other_data[col].mean()
        stats.loc['SD', name] = other_data[col].std()
        stats.loc['Range', name] = f"{other_data[col].min():.1f}-{other_data[col].max():.1f}"
    
    # Create correlation matrix
    corr = pd.DataFrame()
    
    # Add correlations between GCLS subscales
    for col1 in gcls_scores.columns:
        for col2 in gcls_scores.columns:
            if col1 <= col2:  # Only upper triangle
                corr.loc[col1, col2] = gcls_scores[col1].corr(gcls_scores[col2], method='spearman')
    
    # Add correlations with SF-12 and ZUF-8
    for gcls_col in gcls_scores.columns:
        corr.loc[gcls_col, 'SF-12 PCS'] = gcls_scores[gcls_col].corr(other_data['pcs12'], method='spearman')
        corr.loc[gcls_col, 'SF-12 MCS'] = gcls_scores[gcls_col].corr(other_data['mcs12'], method='spearman')
        corr.loc[gcls_col, 'ZUF-8'] = gcls_scores[gcls_col].corr(other_data['zuf_score'], method='spearman')
    
    # Create Excel writer
    with pd.ExcelWriter('tables/correlation_table.xlsx', engine='openpyxl') as writer:
        # Write correlation matrix
        corr.round(2).to_excel(writer, sheet_name='Correlations')
        
        # Write descriptive statistics
        stats.round(2).to_excel(writer, sheet_name='Descriptives')
        
        # Format worksheets
        workbook = writer.book
        
        # Format correlation sheet
        ws_corr = writer.sheets['Correlations']
        ws_corr.column_dimensions['A'].width = 45  # Adjust first column width
        
        # Format descriptives sheet
        ws_stats = writer.sheets['Descriptives']
        ws_stats.column_dimensions['A'].width = 45  # Adjust first column width
    
    print("Tables saved to tables/correlation_table.xlsx")
    print("- Sheet 'Correlations': Correlation matrix")
    print("- Sheet 'Descriptives': Descriptive statistics")

if __name__ == "__main__":
    create_formatted_table() 