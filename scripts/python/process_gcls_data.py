import pandas as pd
from calculate_gcls_scores import calculate_gcls_scores, print_gcls_summary

def load_gcls_data(file_path):
    """
    Load GCLS data from Excel file and prepare it for analysis.
    """
    try:
        # Read the Excel file
        data = pd.read_excel(file_path)
        
        # Ensure all GCLS items are present
        expected_items = [f'I{i}' for i in range(1, 39)]
        missing_items = [item for item in expected_items if item not in data.columns]
        
        if missing_items:
            print(f"Warning: Missing items: {missing_items}")
            return None
            
        # Select only GCLS items
        gcls_data = data[expected_items]
        
        return gcls_data
        
    except Exception as e:
        print(f"Error loading data: {e}")
        return None

def main():
    # Use the correct data file
    file_path = "data/raw/deutsch_data_numeric_recoded.xlsx"
    
    print(f"\nLoading data from {file_path}...")
    data = load_gcls_data(file_path)
    
    if data is None:
        print("Could not load the data file.")
        return
    
    print(f"Successfully loaded data")
    
    # Calculate GCLS scores
    print("\nCalculating GCLS scores...")
    scores, stats = calculate_gcls_scores(data)
    
    # Print summary
    print_gcls_summary(stats)
    
    # Save results
    try:
        scores.to_csv("data/processed/gcls_scores.csv", index=False)
        stats.to_csv("data/processed/gcls_statistics.csv")
        print("\nResults saved to data/processed/gcls_scores.csv and gcls_statistics.csv")
    except Exception as e:
        print(f"\nError saving results: {e}")

if __name__ == "__main__":
    main() 