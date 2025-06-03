import pandas as pd
import plotly.graph_objects as go
import numpy as np

def create_sankey_diagram():
    # Read the data
    data = pd.read_excel("data/raw/raw_quest_all.xlsx")
    
    # Clean up column names for better display
    birth_sex_map = {
        'Männlich (AMAB: Assigned Male At Birth)': 'AMAB',
        'Weiblich (AFAB: Assigned Female At Birth)': 'AFAB',
        'Intergeschlechtlich': 'Inter'
    }
    
    identity_map = {
        'weiblich': 'Weiblich',
        'männlich': 'Männlich',
        'non binär/abinär': 'Non-binär'
    }
    
    # Extract and clean data
    birth_sex = data['@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen'].map(birth_sex_map)
    identity = data['@7welchegeschlechtsidentitaetordnensiesichselbstzu'].map(identity_map)
    
    # Define medical measures
    operative_measures = {
        'Mastektomie': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_g',
        'Brustaufbau': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_h',
        'Hysterektomie': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_i',
        'Gesichtsfeminisierung': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_f',
        'Neovaginoplastik': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_j',
        'Phalloplastik': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_k',
        'Stimmbandop': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_l',
        'Adamsapfelreduktion': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_m'
    }
    
    non_operative_measures = {
        'Hormontherapie Östrogen': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_a',
        'Testosteron-Blocker': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_b',
        'Hormontherapie Testosteron': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_c',
        'Logopädie': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_d',
        'Laserepilation': '@9fallssiediefrage\xa08mitjabeantwortethabenbeantwortensiebittef_e'
    }
    
    # Calculate scores and categorize them
    def categorize_score(score, thresholds):
        if pd.isna(score):
            return 'Niedrig'
        if score <= thresholds.iloc[0]:
            return 'Niedrig'
        elif score <= thresholds.iloc[1]:
            return 'Mittel'
        else:
            return 'Hoch'
    
    # GCLS Score calculation
    gcls_cols = [f'g{i}' for i in range(1, 39)]  # g1 through g38
    data['gcls_score'] = data[gcls_cols].mean(axis=1)
    gcls_thresholds = data['gcls_score'].quantile([0.33, 0.66])
    data['gcls_category'] = data['gcls_score'].apply(lambda x: categorize_score(x, gcls_thresholds))
    
    # SF-12 Scores (PCS and MCS)
    data['sf12_mean'] = data[['pcs12', 'mcs12']].mean(axis=1)
    sf12_thresholds = data['sf12_mean'].quantile([0.33, 0.66])
    data['sf12_category'] = data['sf12_mean'].apply(lambda x: categorize_score(x, sf12_thresholds))
    
    # WHOQOL Score
    whoqol_cols = ['phys', 'psych', 'social', 'envir']
    data['whoqol_score'] = data[whoqol_cols].mean(axis=1)
    whoqol_thresholds = data['whoqol_score'].quantile([0.33, 0.66])
    data['whoqol_category'] = data['whoqol_score'].apply(lambda x: categorize_score(x, whoqol_thresholds))
    
    # Create source-target pairs and values
    source_target_pairs = []
    values = []
    
    # First connection: Birth sex to identity
    for sex in birth_sex.unique():
        for id_type in identity.unique():
            count = len(data[(birth_sex == sex) & (identity == id_type)])
            if count > 0:
                source_target_pairs.append((sex, id_type))
                values.append(count)
    
    # Second connection: Identity to medical measures
    # For operative measures
    for id_type in identity.unique():
        has_operative = False
        for measure_name, measure_col in operative_measures.items():
            if len(data[(identity == id_type) & (data[measure_col] == 1)]) > 0:
                has_operative = True
                break
        if has_operative:
            source_target_pairs.append((id_type, "Operative Maßnahmen"))
            values.append(len(data[identity == id_type]))
    
    # For non-operative measures
    for id_type in identity.unique():
        has_non_operative = False
        for measure_name, measure_col in non_operative_measures.items():
            if len(data[(identity == id_type) & (data[measure_col] == 1)]) > 0:
                has_non_operative = True
                break
        if has_non_operative:
            source_target_pairs.append((id_type, "Nicht-operative Maßnahmen"))
            values.append(len(data[identity == id_type]))
    
    # Third connection: Medical measures to score categories
    measure_types = ["Operative Maßnahmen", "Nicht-operative Maßnahmen"]
    
    # Function to check if person has any measures of given type
    def has_measures_of_type(row, measures_dict):
        return any(row[col] == 1 for col in measures_dict.values())
    
    # Connect measures to GCLS categories
    for measure_type in measure_types:
        measures_dict = operative_measures if measure_type == "Operative Maßnahmen" else non_operative_measures
        for gcls_cat in data['gcls_category'].unique():
            count = len(data[data.apply(lambda row: has_measures_of_type(row, measures_dict), axis=1) & 
                            (data['gcls_category'] == gcls_cat)])
            if count > 0:
                source_target_pairs.append((measure_type, f'GCLS {gcls_cat}'))
                values.append(count)
    
    # Connect measures to SF-12 categories
    for measure_type in measure_types:
        measures_dict = operative_measures if measure_type == "Operative Maßnahmen" else non_operative_measures
        for sf12_cat in data['sf12_category'].unique():
            count = len(data[data.apply(lambda row: has_measures_of_type(row, measures_dict), axis=1) & 
                            (data['sf12_category'] == sf12_cat)])
            if count > 0:
                source_target_pairs.append((measure_type, f'SF-12 {sf12_cat}'))
                values.append(count)
    
    # Connect measures to WHOQOL categories
    for measure_type in measure_types:
        measures_dict = operative_measures if measure_type == "Operative Maßnahmen" else non_operative_measures
        for whoqol_cat in data['whoqol_category'].unique():
            count = len(data[data.apply(lambda row: has_measures_of_type(row, measures_dict), axis=1) & 
                            (data['whoqol_category'] == whoqol_cat)])
            if count > 0:
                source_target_pairs.append((measure_type, f'WHOQOL {whoqol_cat}'))
                values.append(count)
    
    # Create nodes list
    all_nodes = (
        list(birth_sex.unique()) +
        list(identity.unique()) +
        measure_types +
        [f'GCLS {cat}' for cat in ['Niedrig', 'Mittel', 'Hoch']] +
        [f'SF-12 {cat}' for cat in ['Niedrig', 'Mittel', 'Hoch']] +
        [f'WHOQOL {cat}' for cat in ['Niedrig', 'Mittel', 'Hoch']]
    )
    node_indices = {node: i for i, node in enumerate(all_nodes)}
    
    # Create source and target lists
    sources = [node_indices[pair[0]] for pair in source_target_pairs]
    targets = [node_indices[pair[1]] for pair in source_target_pairs]
    
    # Define node colors
    n_birth = len(birth_sex.unique())
    n_identity = len(identity.unique())
    n_measures = len(measure_types)
    n_score_cats = 9  # 3 categories each for GCLS, SF-12, and WHOQOL
    
    node_colors = (
        ['#1f77b4'] * n_birth +  # Blue for birth sex
        ['#2ca02c'] * n_identity +  # Green for identity
        ['#ff7f0e'] * n_measures +  # Orange for medical measures
        ['#d62728'] * 3 +  # Red for GCLS
        ['#9467bd'] * 3 +  # Purple for SF-12
        ['#e377c2'] * 3   # Pink for WHOQOL
    )
    
    # Create the Sankey diagram
    fig = go.Figure(data=[go.Sankey(
        node = dict(
            pad = 15,
            thickness = 20,
            line = dict(color = "black", width = 0.5),
            label = all_nodes,
            color = node_colors
        ),
        link = dict(
            source = sources,
            target = targets,
            value = values
        )
    )])
    
    # Update layout
    fig.update_layout(
        title_text="Zusammenhänge zwischen Geburtsgeschlecht, Transition und Lebensqualität",
        font_size=10,
        height=800,
        width=1200
    )
    
    # Save the figure
    fig.write_html("output/sankey_diagram_measures_scores.html")
    
    # Print summary statistics
    print("\nZusammenfassung der Daten:")
    print("=" * 50)
    print("\nGeburtsgeschlecht:")
    print(birth_sex.value_counts())
    print("\nGeschlechtsidentität:")
    print(identity.value_counts())
    print("\nOperative Maßnahmen:")
    for measure, col in operative_measures.items():
        count = len(data[data[col] == 1])
        print(f"{measure}: {count}")
    print("\nNicht-operative Maßnahmen:")
    for measure, col in non_operative_measures.items():
        count = len(data[data[col] == 1])
        print(f"{measure}: {count}")
    print("\nScore-Kategorien:")
    print("\nGCLS:")
    print(data['gcls_category'].value_counts())
    print("\nSF-12:")
    print(data['sf12_category'].value_counts())
    print("\nWHOQOL:")
    print(data['whoqol_category'].value_counts())

if __name__ == "__main__":
    create_sankey_diagram() 