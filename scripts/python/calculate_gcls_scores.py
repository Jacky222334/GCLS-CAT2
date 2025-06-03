import pandas as pd
import numpy as np

def calculate_gcls_scores(data):
    """
    Calculate GCLS subscale scores with proper handling of item 26.
    
    Parameters:
    data (pd.DataFrame): DataFrame containing GCLS items (I1-I38)
    
    Returns:
    pd.DataFrame: DataFrame with subscale scores
    """
    # Define subscales
    subscales = {
        'GEN': ['I14', 'I21', 'I25', 'I26', 'I27', 'I29'],
        'CH': ['I15', 'I18', 'I28', 'I30'],
        'SSC': ['I17', 'I23', 'I24'],
        'SGR': ['I16', 'I19', 'I20', 'I22'],
        'PEI': ['I3', 'I5', 'I32', 'I33'],
        'PF': ['I1', 'I2', 'I4', 'I6', 'I7', 'I8', 'I9', 'I11', 'I12', 'I13'],
        'LS': ['I10', 'I31', 'I34', 'I35', 'I36', 'I37', 'I38']
    }
    
    # Define reverse-coded items
    reverse_items = ['I16', 'I20', 'I22', 'I25', 'I30', 'I31', 'I32', 'I33', 'I34', 'I36', 'I38']
    
    # Create copy of data
    df = data.copy()
    
    # Reverse code items (5-point scale: 1->5, 2->4, 3->3, 4->2, 5->1)
    for item in reverse_items:
        if item in df.columns:
            df[item] = 6 - df[item]
    
    # Calculate subscale scores
    scores = pd.DataFrame()
    
    for subscale, items in subscales.items():
        # Special handling for GEN subscale (item 26)
        if subscale == 'GEN':
            # Calculate GEN score with item 26
            gen_with_26 = df[items].mean(axis=1)
            # Calculate GEN score without item 26
            gen_without_26 = df[[i for i in items if i != 'I26']].mean(axis=1)
            # Store both scores
            scores[f'{subscale}_with_26'] = gen_with_26
            scores[f'{subscale}_without_26'] = gen_without_26
        else:
            # Calculate regular subscale scores
            scores[subscale] = df[items].mean(axis=1)
    
    # Calculate total score (excluding item 26)
    all_items_except_26 = [item for sublist in subscales.values() 
                          for item in sublist if item != 'I26']
    scores['TOTAL_without_26'] = df[all_items_except_26].mean(axis=1)
    
    # Calculate descriptive statistics
    stats = scores.describe()
    
    return scores, stats

def print_gcls_summary(stats):
    """Print a formatted summary of GCLS scores."""
    print("\nGCLS Subscale Scores Summary:")
    print("=" * 60)
    for column in stats.columns:
        print(f"\n{column}:")
        print(f"  Mean (SD): {stats.loc['mean', column]:.2f} ({stats.loc['std', column]:.2f})")
        print(f"  Range: {stats.loc['min', column]:.2f} - {stats.loc['max', column]:.2f}")
        print(f"  N: {int(stats.loc['count', column])}")
        print(f"  Quartiles: {stats.loc['25%', column]:.2f} | {stats.loc['50%', column]:.2f} | {stats.loc['75%', column]:.2f}")

if __name__ == "__main__":
    # Example usage:
    data = pd.read_csv("your_data.csv")  # Load your data
    scores, stats = calculate_gcls_scores(data)
    print_gcls_summary(stats) 