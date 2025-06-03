import pandas as pd
import numpy as np
from itertools import combinations
from collections import Counter
from scipy import stats
from datetime import datetime
import matplotlib.pyplot as plt
import seaborn as sns
import os
from io import StringIO
import sys

# Create results directory if it doesn't exist
RESULTS_DIR = 'visualization_results'
os.makedirs(RESULTS_DIR, exist_ok=True)

# Set style
plt.style.use('default')
sns.set_theme(style="whitegrid")

# Read the data
df = pd.read_excel('../../data/processed/transition_data_cleaned.xlsx')

# Print birth year information
print("\nBirth year data inspection:")
print("-" * 50)
print("\nFirst few birth years:")
print(df['geb'].head())
print("\nData type:", df['geb'].dtype)
print("\nUnique values:")
print(df['geb'].unique())

def excel_date_to_year(excel_date):
    """Convert Excel date number to year"""
    try:
        # Excel dates are counted from 1900-01-01
        date = pd.Timestamp('1900-01-01') + pd.Timedelta(days=int(excel_date))
        return date.year
    except:
        return np.nan

# Print all column names
print("\nAll available columns:")
print(df.columns.tolist())
print("\n")

# Define intervention columns
interventions = ['EHT', 'AA', 'THT', 'VT', 'LE', 'FFS', 'CMS', 'BA', 'HE', 'NV', 'PH', 'VCS', 'CR', 'OMI']

# Define GCLS subscales
gcls_subscales = {
    'Psychological': ['GCLS_1', 'GCLS_2', 'GCLS_3', 'GCLS_4', 'GCLS_5', 'GCLS_6', 'GCLS_7'],
    'Social': ['GCLS_8', 'GCLS_9', 'GCLS_10', 'GCLS_11', 'GCLS_12'],
    'Medical': ['GCLS_13', 'GCLS_14', 'GCLS_15'],
    'Sexual': ['GCLS_16', 'GCLS_17', 'GCLS_18'],
    'Total': ['GCLS_' + str(i) for i in range(1, 19)]
}

# Create dictionary for intervention names
intervention_names = {
    'EHT': 'Estrogen HT',
    'AA': 'Anti-androgens',
    'THT': 'Testosterone HT',
    'VT': 'Voice therapy',
    'LE': 'Laser epilation',
    'FFS': 'Facial feminization',
    'CMS': 'Chest masculinization',
    'BA': 'Breast augmentation',
    'HE': 'Hysterectomy',
    'NV': 'Neovaginoplasty',
    'PH': 'Phalloplasty',
    'VCS': 'Vocal cord surgery',
    'CR': 'Chondrolaryngoplasty',
    'OMI': 'Other interventions'
}

# Define potentially conflicting combinations
conflicting_pairs = [
    ('EHT', 'THT'),  # Estrogen and Testosterone
    ('BA', 'CMS'),   # Breast augmentation and Chest masculinization
    ('NV', 'PH'),    # Neovaginoplasty and Phalloplasty
]

# Define expected combinations based on gender identity
expected_combinations = {
    'weiblich': {
        'primary': ['EHT', 'AA', 'BA', 'NV'],
        'secondary': ['LE', 'VT', 'FFS', 'VCS', 'CR'],
        'unusual': ['THT', 'CMS', 'PH', 'HE']
    },
    'männlich': {
        'primary': ['THT', 'CMS', 'PH', 'HE'],
        'secondary': ['VT'],
        'unusual': ['EHT', 'AA', 'BA', 'NV', 'LE', 'FFS', 'VCS', 'CR']
    }
}

def check_anomalies(row, gender):
    anomalies = []
    
    # Check for conflicting interventions
    for int1, int2 in conflicting_pairs:
        if row[int1] == 1 and row[int2] == 1:
            anomalies.append(f"Conflicting interventions: {intervention_names[int1]} and {intervention_names[int2]}")
    
    # Check for unusual combinations based on gender identity
    if gender in expected_combinations:
        for intervention in expected_combinations[gender]['unusual']:
            if row[intervention] == 1:
                anomalies.append(f"Unusual for {gender}: {intervention_names[intervention]}")
    
    return anomalies

def calculate_gcls_scores(df):
    scores = {}
    for scale, items in gcls_subscales.items():
        scores[scale] = df[items].mean(axis=1)
    return pd.DataFrame(scores)

def visualize_timeline(cases, group_name, anomaly_type=""):
    """Create timeline visualization for coming out patterns"""
    birth_years = pd.to_numeric(cases['geb'].dt.year, errors='coerce')
    inner_co_ages = pd.to_numeric(cases['inwelchemalterhattensieihrinnerescomingout'], errors='coerce')
    outer_co_ages = pd.to_numeric(cases['inwelchemalterhattensieihraeusserescomingout'], errors='coerce')
    
    # Calculate coming out years
    inner_co_years = birth_years + inner_co_ages
    outer_co_years = birth_years + outer_co_ages
    
    # Create figure
    plt.figure(figsize=(12, 6))
    
    # Plot density curves for coming out years
    if len(inner_co_years.dropna()) > 0:
        sns.kdeplot(data=inner_co_years.dropna(), label='Inner Coming Out', fill=True, alpha=0.3)
    if len(outer_co_years.dropna()) > 0:
        sns.kdeplot(data=outer_co_years.dropna(), label='Outer Coming Out', fill=True, alpha=0.3)
    
    plt.title(f'Coming Out Timeline Distribution - {group_name}\n{anomaly_type}')
    plt.xlabel('Year')
    plt.ylabel('Density')
    plt.legend()
    
    # Save plot
    filename = os.path.join(RESULTS_DIR, f'timeline_{group_name.lower().replace(" ", "_")}_{anomaly_type.lower().replace(" ", "_")}.png')
    plt.savefig(filename)
    plt.close()

def visualize_intervention_patterns(group_df, group_name):
    """Create heatmap of intervention co-occurrence"""
    # Create co-occurrence matrix
    n_interventions = len(interventions)
    cooccurrence = np.zeros((n_interventions, n_interventions))
    
    for _, row in group_df.iterrows():
        for i, int1 in enumerate(interventions):
            for j, int2 in enumerate(interventions):
                if row[int1] == 1 and row[int2] == 1:
                    cooccurrence[i, j] += 1
    
    # Create heatmap
    plt.figure(figsize=(12, 10))
    sns.heatmap(cooccurrence, 
                xticklabels=interventions,
                yticklabels=interventions,
                annot=True,
                fmt='g',
                cmap='YlOrRd')
    
    plt.title(f'Intervention Co-occurrence Pattern - {group_name}')
    plt.tight_layout()
    
    # Save plot
    filename = os.path.join(RESULTS_DIR, f'intervention_pattern_{group_name.lower().replace(" ", "_")}.png')
    plt.savefig(filename)
    plt.close()

def calculate_coming_out_years(group_df, anomaly_indices):
    """Calculate and compare actual coming out years"""
    print("\nComing Out Timeline Analysis:")
    print("-" * 50)
    
    # Split into anomaly and non-anomaly groups
    anomaly_cases = group_df.loc[anomaly_indices]
    non_anomaly_cases = group_df.drop(anomaly_indices)
    
    def analyze_timeline(cases, group_name):
        print(f"\n{group_name} (n={len(cases)}):")
        
        # Convert birth years and coming out ages to numeric
        birth_years = pd.to_numeric(cases['geb'].dt.year, errors='coerce')
        inner_co_ages = pd.to_numeric(cases['inwelchemalterhattensieihrinnerescomingout'], errors='coerce')
        outer_co_ages = pd.to_numeric(cases['inwelchemalterhattensieihraeusserescomingout'], errors='coerce')
        
        # Calculate mean years and ages
        current_year = datetime.now().year
        mean_birth = birth_years.mean()
        mean_age = current_year - mean_birth if not pd.isna(mean_birth) else np.nan
        
        if not pd.isna(mean_birth):
            print(f"Mean birth year: {int(mean_birth)}")
            print(f"Current mean age: {mean_age:.1f}")
            print("\nComing Out Timeline:")
            
            # Calculate coming out years
            inner_co_years = birth_years + inner_co_ages
            outer_co_years = birth_years + outer_co_ages
            
            mean_inner = inner_co_years.mean()
            mean_outer = outer_co_years.mean()
            
            if not pd.isna(mean_inner):
                print(f"Inner Coming Out: mean age {inner_co_ages.mean():.1f} years (around year {int(mean_inner)})")
            if not pd.isna(mean_outer):
                print(f"Outer Coming Out: mean age {outer_co_ages.mean():.1f} years (around year {int(mean_outer)})")
            
            # Calculate time between coming outs
            valid_both = ~(inner_co_ages.isna() | outer_co_ages.isna())
            if valid_both.sum() > 0:
                time_between = outer_co_ages[valid_both] - inner_co_ages[valid_both]
                print(f"\nTime between coming outs:")
                print(f"Mean: {time_between.mean():.1f} years")
                print(f"Median: {time_between.median():.1f} years")
                print(f"Range: {time_between.min():.1f} to {time_between.max():.1f} years")
                
                # Distribution of time between coming outs
                bins = [-np.inf, 0, 1, 2, 5, 10, np.inf]
                labels = ['Same year', '1 year', '2 years', '2-5 years', '5-10 years', 'More than 10 years']
                time_dist = pd.cut(time_between, bins=bins, labels=labels)
                time_counts = time_dist.value_counts()
                
                print("\nDistribution of time between coming outs:")
                for label, count in time_counts.items():
                    print(f"{label}: {count} cases ({count/len(time_between)*100:.1f}%)")
                
                # Age distribution at coming out
                print("\nAge distribution at coming out:")
                print("Inner Coming Out:")
                print(f"Range: {inner_co_ages[valid_both].min():.1f} to {inner_co_ages[valid_both].max():.1f} years")
                print(f"Mean: {inner_co_ages[valid_both].mean():.1f} years")
                print(f"Median: {inner_co_ages[valid_both].median():.1f} years")
                
                print("\nOuter Coming Out:")
                print(f"Range: {outer_co_ages[valid_both].min():.1f} to {outer_co_ages[valid_both].max():.1f} years")
                print(f"Mean: {outer_co_ages[valid_both].mean():.1f} years")
                print(f"Median: {outer_co_ages[valid_both].median():.1f} years")
    
    # Analyze both groups
    analyze_timeline(anomaly_cases, group_df.name if hasattr(group_df, 'name') else "Group")
    visualize_timeline(anomaly_cases, group_df.name if hasattr(group_df, 'name') else "Group", "With Anomalies")
    visualize_timeline(non_anomaly_cases, group_df.name if hasattr(group_df, 'name') else "Group", "Without Anomalies")

def compare_outcomes(group_df, anomaly_indices):
    """Compare outcomes between cases with and without anomalies"""
    print("\nOutcome Comparison:")
    print("-" * 50)
    
    # Split into anomaly and non-anomaly groups
    anomaly_cases = group_df.loc[anomaly_indices]
    non_anomaly_cases = group_df.drop(anomaly_indices)
    
    # Compare regret rates if available
    if 'retest_regret' in group_df.columns:
        print("\nRegret Analysis:")
        anomaly_regret = anomaly_cases['retest_regret'].mean()
        non_anomaly_regret = non_anomaly_cases['retest_regret'].mean()
        
        print(f"Anomaly cases (n={len(anomaly_cases)}): {anomaly_regret:.2f}")
        print(f"Non-anomaly cases (n={len(non_anomaly_cases)}): {non_anomaly_regret:.2f}")
        
        # Statistical test
        t_stat, p_val = stats.ttest_ind(
            anomaly_cases['retest_regret'].dropna(),
            non_anomaly_cases['retest_regret'].dropna()
        )
        print(f"T-test: t={t_stat:.2f}, p={p_val:.3f}")
    
    # Calculate and compare coming out years
    calculate_coming_out_years(group_df, anomaly_indices)

def visualize_combined_timeline(group_df, anomaly_indices, group_name):
    """Create timeline visualization comparing anomaly and non-anomaly cases"""
    # Split into anomaly and non-anomaly groups
    anomaly_cases = group_df.loc[anomaly_indices]
    non_anomaly_cases = group_df.drop(anomaly_indices)
    
    # Create figure
    plt.figure(figsize=(12, 8))
    
    # Get age data
    inner_co_ages_anomaly = pd.to_numeric(anomaly_cases['inwelchemalterhattensieihrinnerescomingout'], errors='coerce')
    inner_co_ages_non_anomaly = pd.to_numeric(non_anomaly_cases['inwelchemalterhattensieihrinnerescomingout'], errors='coerce')
    outer_co_ages_anomaly = pd.to_numeric(anomaly_cases['inwelchemalterhattensieihraeusserescomingout'], errors='coerce')
    outer_co_ages_non_anomaly = pd.to_numeric(non_anomaly_cases['inwelchemalterhattensieihraeusserescomingout'], errors='coerce')
    
    # Plot all curves
    if len(inner_co_ages_anomaly.dropna()) > 0:
        sns.kdeplot(data=inner_co_ages_anomaly.dropna(), label='Inneres CO (mit Anomalien)', color='darkred', linestyle='-')
    if len(outer_co_ages_anomaly.dropna()) > 0:
        sns.kdeplot(data=outer_co_ages_anomaly.dropna(), label='Äußeres CO (mit Anomalien)', color='red', linestyle='--')
    if len(inner_co_ages_non_anomaly.dropna()) > 0:
        sns.kdeplot(data=inner_co_ages_non_anomaly.dropna(), label='Inneres CO (ohne Anomalien)', color='darkblue', linestyle='-')
    if len(outer_co_ages_non_anomaly.dropna()) > 0:
        sns.kdeplot(data=outer_co_ages_non_anomaly.dropna(), label='Äußeres CO (ohne Anomalien)', color='blue', linestyle='--')
    
    # Add mean age indicators
    means = {
        'Inneres CO (mit Anomalien)': inner_co_ages_anomaly.mean(),
        'Äußeres CO (mit Anomalien)': outer_co_ages_anomaly.mean(),
        'Inneres CO (ohne Anomalien)': inner_co_ages_non_anomaly.mean(),
        'Äußeres CO (ohne Anomalien)': outer_co_ages_non_anomaly.mean()
    }
    
    # Add vertical lines and annotations for means
    colors = {'mit Anomalien': ['darkred', 'red'], 'ohne Anomalien': ['darkblue', 'blue']}
    y_offset = 0.02
    
    for label, mean in means.items():
        if not pd.isna(mean):
            color = 'darkred' if 'mit Anomalien' in label and 'Inneres' in label else \
                   'red' if 'mit Anomalien' in label else \
                   'darkblue' if 'ohne Anomalien' in label and 'Inneres' in label else 'blue'
            plt.axvline(x=mean, color=color, linestyle=':', alpha=0.5)
            plt.text(mean, y_offset, f'{mean:.1f}J', 
                    color=color, 
                    horizontalalignment='center',
                    verticalalignment='bottom')
    
    plt.title(f'Coming Out Zeitlinien - {group_name}\n(n={len(group_df)}, davon {len(anomaly_indices)} mit Anomalien)')
    plt.xlabel('Alter')
    plt.ylabel('Dichte')
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.tight_layout()
    
    # Save plot
    filename = os.path.join(RESULTS_DIR, f'timeline_comparison_{group_name.lower().replace(" ", "_")}.png')
    plt.savefig(filename, bbox_inches='tight')
    plt.close()

def analyze_combinations(group_df, group_name):
    print(f"\nAnalyzing combinations for {group_name} (n={len(group_df)})")
    print("-" * 50)
    
    # Get all combinations of interventions for each person
    person_combinations = []
    for _, row in group_df.iterrows():
        interventions_received = [col for col in interventions if row[col] == 1]
        if interventions_received:
            person_combinations.append(tuple(sorted(interventions_received)))
    
    # Count frequency of each unique combination
    combination_counts = Counter(person_combinations)
    
    # Print top 5 most common combinations
    print("\nMost common intervention combinations:")
    for combo, count in combination_counts.most_common(5):
        percentage = (count / len(group_df)) * 100
        combo_names = [intervention_names[int_code] for int_code in combo]
        print(f"{' + '.join(combo_names)}: {count} ({percentage:.1f}%)")
    
    # Analyze common pairs
    print("\nMost common intervention pairs:")
    pair_counts = Counter()
    for combo in person_combinations:
        if len(combo) >= 2:
            for pair in combinations(combo, 2):
                pair_counts[pair] += 1
    
    for (int1, int2), count in pair_counts.most_common(5):
        percentage = (count / len(group_df)) * 100
        print(f"{intervention_names[int1]} + {intervention_names[int2]}: {count} ({percentage:.1f}%)")
    
    # Check for anomalies
    print("\nAnomaly Analysis:")
    anomaly_count = 0
    anomaly_indices = []
    
    for idx, row in group_df.iterrows():
        anomalies = check_anomalies(row, row['Gender identity'])
        if anomalies:
            anomaly_count += 1
            anomaly_indices.append(idx)
            print(f"\nCase {idx}:")
            interventions_received = [intervention_names[col] for col in interventions if row[col] == 1]
            print(f"Interventions: {', '.join(interventions_received)}")
            print("Anomalies detected:")
            for anomaly in anomalies:
                print(f"- {anomaly}")
    
    if anomaly_count == 0:
        print("No anomalies detected.")
    else:
        print(f"\nTotal cases with anomalies: {anomaly_count} ({(anomaly_count/len(group_df))*100:.1f}%)")
        
        # Compare outcomes between anomaly and non-anomaly cases
        compare_outcomes(group_df, anomaly_indices)
        
        # Create combined timeline visualization
        visualize_combined_timeline(group_df, anomaly_indices, group_name)

    # Add visualization call
    visualize_intervention_patterns(group_df, group_name)

# Analyze by gender identity
print("\nIntervention Combination Patterns, Anomaly Detection, and Timeline Analysis")
print("=" * 80)

# Women (AMAB)
women_amab = df[df['Gender identity'] == 'weiblich']
analyze_combinations(women_amab, "Women (AMAB)")

# Men (AFAB)
men_afab = df[df['Gender identity'] == 'männlich']
analyze_combinations(men_afab, "Men (AFAB)")

# Non-binary
nonbin = df[df['Gender identity'].isin(['non binär/abinär', 'genderfluid', 'anderes'])]
analyze_combinations(nonbin, "Non-binary")

# Set names for the groups to improve plot titles
women_amab.name = "Women (AMAB)"
men_afab.name = "Men (AFAB)"
nonbin.name = "Non-binary"

# Run analysis with visualizations
print("\nIntervention Combination Patterns, Anomaly Detection, and Timeline Analysis")
print("=" * 80)

analyze_combinations(women_amab, "Women (AMAB)")
analyze_combinations(men_afab, "Men (AFAB)")
analyze_combinations(nonbin, "Non-binary")

# Save detailed results
with open('combination_analysis_results.txt', 'w') as f:
    f.write("Detailed Intervention Combination Analysis\n")
    f.write("=======================================\n")
    # Add more detailed analysis here if needed

# At the end of the script, save the detailed results
analysis_results = []

def save_analysis_results(content, filename):
    """Save analysis results to a text file"""
    filepath = os.path.join(RESULTS_DIR, filename)
    with open(filepath, 'w') as f:
        f.write(content)

def analyze_group_and_save(group_df, group_name):
    print(f"\nAnalyzing {group_name}")
    print("=" * 50)
    
    # Create a string buffer to capture output
    output = StringIO()
    original_stdout = sys.stdout
    sys.stdout = output
    
    # Run the analysis
    analyze_combinations(group_df, group_name)
    
    # Restore stdout and get the output
    sys.stdout = original_stdout
    analysis_text = output.getvalue()
    output.close()
    
    # Save the results
    save_analysis_results(analysis_text, f'analysis_{group_name.lower().replace(" ", "_")}.txt')
    
    # Print the analysis to console as well
    print(analysis_text)

# Analyze each group
analyze_group_and_save(women_amab, "Women (AMAB)")
analyze_group_and_save(men_afab, "Men (AFAB)")
analyze_group_and_save(nonbin, "Non-binary") 