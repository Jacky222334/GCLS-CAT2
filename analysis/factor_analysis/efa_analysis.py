import pandas as pd
import numpy as np
from factor_analyzer import FactorAnalyzer
from factor_analyzer.factor_analyzer import calculate_kmo, calculate_bartlett_sphericity
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import os

# Create results directory
RESULTS_DIR = 'efa_results'
os.makedirs(RESULTS_DIR, exist_ok=True)

# Read the data
print("Reading Excel file...")
df = pd.read_excel('../../data/raw/dat_EFA_26.xlsx')

# Print data info
print("\nDataset Info:")
print(df.info())

print("\nColumn names:")
print(df.columns.tolist())

def prepare_data(df):
    """Prepare data for EFA"""
    # First, identify numeric columns that could be items
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    print(f"\nNumeric columns: {len(numeric_cols)}")
    print(numeric_cols.tolist())
    
    # Remove any missing values
    data_clean = df[numeric_cols].dropna()
    print(f"\nShape after cleaning: {data_clean.shape}")
    
    # Check for low variance columns
    variances = data_clean.var()
    low_var_cols = variances[variances < 0.001].index
    if len(low_var_cols) > 0:
        print(f"\nRemoving {len(low_var_cols)} low variance columns:")
        print(low_var_cols.tolist())
        data_clean = data_clean.drop(columns=low_var_cols)
    
    # Standardize the data
    data_scaled = stats.zscore(data_clean)
    return pd.DataFrame(data_scaled, columns=data_clean.columns)

def check_efa_suitability(data):
    """Check if data is suitable for EFA using KMO and Bartlett's test"""
    try:
        print("\nChecking EFA suitability...")
        print(f"Data shape: {data.shape}")
        
        # Calculate KMO
        kmo_all, kmo_model = calculate_kmo(data)
        print("\nKMO scores:")
        print(f"Overall KMO: {kmo_model:.3f}")
        print("\nKMO scores for each variable:")
        for var, kmo in zip(data.columns, kmo_all):
            print(f"{var}: {kmo:.3f}")
        
        # Calculate Bartlett's test
        chi_square_value, p_value = calculate_bartlett_sphericity(data)
        print("\nBartlett's test of sphericity:")
        print(f"Chi-square: {chi_square_value:.3f}")
        print(f"p-value: {p_value:.3e}")
        
        return kmo_model, p_value
    except Exception as e:
        print(f"Error in checking EFA suitability: {str(e)}")
        return None, None

def determine_n_factors(data):
    """Determine optimal number of factors using multiple methods"""
    try:
        print("\nDetermining number of factors...")
        print(f"Data shape: {data.shape}")
        
        # Initialize factor analyzer
        fa = FactorAnalyzer(rotation=None, n_factors=data.shape[1])
        fa.fit(data)
        
        # Scree plot
        ev, v = fa.get_eigenvalues()
        plt.figure(figsize=(10, 6))
        plt.plot(range(1, len(ev) + 1), ev)
        plt.title('Scree Plot')
        plt.xlabel('Factors')
        plt.ylabel('Eigenvalue')
        plt.axhline(y=1, color='r', linestyle='--')
        plt.savefig(os.path.join(RESULTS_DIR, 'scree_plot.png'))
        plt.close()
        
        # Parallel Analysis
        n_iterations = 1000
        n_vars = data.shape[1]
        n_samples = data.shape[0]
        
        # Generate random eigenvalues
        random_evals = np.zeros((n_iterations, n_vars))
        for i in range(n_iterations):
            random_data = np.random.normal(size=(n_samples, n_vars))
            fa_random = FactorAnalyzer(rotation=None, n_factors=n_vars)
            fa_random.fit(random_data)
            random_evals[i, :], _ = fa_random.get_eigenvalues()
        
        # Get 95th percentile of random eigenvalues
        percentile_95 = np.percentile(random_evals, 95, axis=0)
        
        # Plot parallel analysis
        plt.figure(figsize=(10, 6))
        plt.plot(range(1, len(ev) + 1), ev, 'b', label='Actual Data')
        plt.plot(range(1, len(percentile_95) + 1), percentile_95, 'r--', label='95th Percentile of Random Data')
        plt.title('Parallel Analysis')
        plt.xlabel('Factors')
        plt.ylabel('Eigenvalue')
        plt.legend()
        plt.savefig(os.path.join(RESULTS_DIR, 'parallel_analysis.png'))
        plt.close()
        
        # Determine number of factors
        n_factors = sum(ev > percentile_95)
        print(f"\nSuggested number of factors from parallel analysis: {n_factors}")
        
        # Save eigenvalues to file
        with open(os.path.join(RESULTS_DIR, 'eigenvalues.txt'), 'w') as f:
            f.write("Eigenvalues:\n")
            for i, eigenvalue in enumerate(ev, 1):
                f.write(f"Factor {i}: {eigenvalue:.3f}\n")
            f.write("\nCumulative variance explained:\n")
            cumulative = np.cumsum(ev) / sum(ev) * 100
            for i, cum_var in enumerate(cumulative, 1):
                f.write(f"Factor 1-{i}: {cum_var:.1f}%\n")
        
        return n_factors
    except Exception as e:
        print(f"Error in determining number of factors: {str(e)}")
        return None

def perform_efa(data, n_factors):
    """Perform EFA with different rotation methods"""
    try:
        print(f"\nPerforming EFA with {n_factors} factors...")
        print(f"Data shape: {data.shape}")
        
        rotations = ['varimax', 'promax', 'oblimin']
        results = {}
        
        for rotation in rotations:
            print(f"\nPerforming {rotation} rotation...")
            # Initialize and fit factor analyzer
            fa = FactorAnalyzer(rotation=rotation, n_factors=n_factors)
            fa.fit(data)
            
            # Get loadings
            loadings = pd.DataFrame(
                fa.loadings_,
                columns=[f'Factor{i+1}' for i in range(n_factors)],
                index=data.columns
            )
            
            # Get variance explained
            var_explained = fa.get_factor_variance()
            variance = pd.DataFrame(
                var_explained,
                columns=['SS Loadings', 'Proportion Var', 'Cumulative Var'],
                index=[f'Factor{i+1}' for i in range(n_factors)]
            )
            
            if rotation in ['promax', 'oblimin']:
                # Get factor correlations for oblique rotations
                factor_corr = pd.DataFrame(
                    fa.corr_,
                    columns=[f'Factor{i+1}' for i in range(n_factors)],
                    index=[f'Factor{i+1}' for i in range(n_factors)]
                )
            else:
                factor_corr = None
            
            results[rotation] = {
                'loadings': loadings,
                'variance': variance,
                'factor_corr': factor_corr
            }
            
            # Create heatmap of factor loadings
            plt.figure(figsize=(12, 8))
            sns.heatmap(loadings, annot=True, cmap='RdBu', center=0, fmt='.3f')
            plt.title(f'Factor Loadings ({rotation} rotation)')
            plt.tight_layout()
            plt.savefig(os.path.join(RESULTS_DIR, f'loadings_{rotation}.png'))
            plt.close()
            
            # Save results to file
            with open(os.path.join(RESULTS_DIR, f'efa_results_{rotation}.txt'), 'w') as f:
                f.write(f"EFA Results - {rotation} rotation\n")
                f.write("=" * 50 + "\n\n")
                f.write("Factor Loadings:\n")
                f.write(loadings.to_string())
                f.write("\n\nVariance Explained:\n")
                f.write(variance.to_string())
                if factor_corr is not None:
                    f.write("\n\nFactor Correlations:\n")
                    f.write(factor_corr.to_string())
                
                # Add factor interpretation
                f.write("\n\nFactor Interpretation:\n")
                f.write("-" * 30 + "\n")
                for factor in range(n_factors):
                    f.write(f"\nFactor {factor + 1}:\n")
                    # Get items with significant loadings (> 0.4)
                    sig_items = loadings[loadings[f'Factor{factor+1}'].abs() > 0.4]
                    sig_items = sig_items.sort_values(by=f'Factor{factor+1}', key=abs, ascending=False)
                    f.write(f"Significant items (|loading| > 0.4):\n")
                    for item, loading in sig_items[f'Factor{factor+1}'].items():
                        f.write(f"{item}: {loading:.3f}\n")
        
        return results
    except Exception as e:
        print(f"Error in performing EFA: {str(e)}")
        return None

def main():
    try:
        # Prepare data
        print("Preparing data...")
        data = prepare_data(df)
        print(f"Analyzing {len(data.columns)} variables with {len(data)} complete cases")
        
        # Check suitability
        kmo, bartlett_p = check_efa_suitability(data)
        
        if kmo is not None and bartlett_p is not None:
            if kmo < 0.5 or bartlett_p > 0.05:
                print("\nWarning: Data may not be suitable for EFA!")
                print(f"KMO: {kmo:.3f} (should be > 0.5)")
                print(f"Bartlett's p-value: {bartlett_p:.3e} (should be < 0.05)")
                if input("Continue anyway? (y/n): ").lower() != 'y':
                    return
        
        # Determine number of factors
        n_factors = determine_n_factors(data)
        
        if n_factors is not None and n_factors > 0:
            # Perform EFA
            results = perform_efa(data, n_factors)
            
            if results is not None:
                print("\nAnalysis complete! Results have been saved to the 'efa_results' directory.")
            else:
                print("\nError occurred during EFA. Please check the error messages above.")
        else:
            print("\nError occurred while determining number of factors. Please check the error messages above.")
    
    except Exception as e:
        print(f"\nAn error occurred: {str(e)}")

if __name__ == "__main__":
    main() 