#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Analyze the polarity of questionnaire items and their translations
"""

import pandas as pd
import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns
from textblob import TextBlob
import spacy
from collections import defaultdict

def set_style():
    """Set publication-ready style for plots."""
    plt.style.use('seaborn-v0_8-paper')
    sns.set_palette("deep")
    plt.rcParams['font.family'] = 'sans-serif'
    plt.rcParams['font.sans-serif'] = ['Arial']
    plt.rcParams['font.size'] = 11
    plt.rcParams['axes.labelsize'] = 12
    plt.rcParams['axes.titlesize'] = 14
    plt.rcParams['figure.titlesize'] = 16
    plt.rcParams['figure.dpi'] = 300

def analyze_polarity(text, lang='en'):
    """Analyze polarity of text using TextBlob."""
    if lang == 'de':
        # For German text, we need to handle special characters
        text = text.replace('ä', 'ae').replace('ö', 'oe').replace('ü', 'ue').replace('ß', 'ss')
    return TextBlob(text).sentiment.polarity

def classify_polarity(polarity):
    """Classify polarity into categories."""
    if polarity < -0.1:
        return 'Negative'
    elif polarity > 0.1:
        return 'Positive'
    else:
        return 'Neutral'

def analyze_items():
    """Analyze polarity of all questionnaire items."""
    items = [
        ("I have avoided social situations and/or interactions", 
         "Ich habe soziale Situationen und/oder Interaktionen vermieden"),
        ("I did not go to school/university/work", 
         "Ich bin nicht zur Schule/Universität/Arbeit gegangen"),
        ("I was unable to form emotional relationships with other people", 
         "Ich bin nicht in der Lage gewesen, emotionale Beziehungen zu anderen Menschen zu knüpfen"),
        ("I suffered from anxiety", 
         "Ich habe unter Angst gelitten"),
        ("I was unable to be physically intimate with other people", 
         "Ich bin nicht in der Lage gewesen, mit anderen Menschen körperlich intim zu sein"),
        ("I was unable to leave the house", 
         "Ich bin unfähig gewesen, das Haus zu verlassen"),
        ("I found it difficult to make friends", 
         "Ich habe es schwer gefunden, Freundschaften zu schließen"),
        ("I thought about cutting or injuring my chest, genitals, and/or surrounding areas", 
         "Ich habe darüber nachgedacht, meine Brust, Genitalien und/oder angrenzende Bereiche zu schneiden oder zu verletzen"),
        ("I felt that life was meaningless", 
         "Ich hatte das Gefühl, dass das Leben bedeutungslos ist"),
        ("I did not enjoy my life", 
         "Ich habe mein Leben nicht genossen"),
        ("I did not engage in leisure activities", 
         "Ich bin keinen Freizeitaktivitäten nachgegangen"),
        ("I suffered from low mood", 
         "Ich habe unter gedrückter Stimmung gelitten"),
        ("I thought about hurting myself or taking my life", 
         "Ich habe darüber nachgedacht, mich zu verletzen oder mir das Leben zu nehmen"),
        ("Touching my genitals was distressing to me because they do not match my gender identity", 
         "Die Berührung meiner Genitalien war eine Belastung für mich, da sie nicht meiner Geschlechtsidentität entsprechen"),
        ("I felt so distressed about my chest that I was not able to live a fulfilling life", 
         "Ich habe mich aufgrund meiner Brust so sehr belastet gefühlt, dass ich nicht in der Lage war, ein erfülltes Leben zu führen"),
        ("I felt comfortable with how others perceived my gender", 
         "Ich habe mich wohl damit gefühlt, wie andere mein Geschlecht wahrgenommen haben"),
        ("I felt that my body hair did not match my gender identity", 
         "Ich hatte das Gefühl, dass meine Körperbehaarung nicht zu meiner Geschlechtsidentität passt"),
        ("I felt that my chest did not match my gender identity", 
         "Ich hatte das Gefühl, dass meine Brust nicht meiner Geschlechtsidentität entspricht"),
        ("I was distressed that others did not address me according to my gender identity", 
         "Es hat mich belastet, dass andere mich nicht entsprechend meiner Geschlechtsidentität angesprochen haben"),
        ("I was satisfied with the pronouns others used when talking about me", 
         "Ich war zufrieden mit den Pronomen, die andere nutzen, wenn sie über mich reden"),
        ("I was unhappy about my genitals because they do not match my gender identity", 
         "Ich war unglücklich über meine Genitalien, da sie nicht meiner Geschlechtsidentität entsprechen"),
        ("I felt comfortable with how others perceived my gender based on my physical appearance", 
         "Ich habe mich damit wohlgefühlt, wie andere Menschen mein Geschlecht aufgrund meiner körperlichen Erscheinung wahrnehmen"),
        ("I felt that my voice affected how others perceived my gender identity – and that distressed me", 
         "Ich hatte das Gefühl, dass meine Stimme beeinflusst hat, wie andere Menschen meine Geschlechtsidentität wahrnehmen – das hat mich belastet"),
        ("I felt that my facial hair did not match my gender identity", 
         "Ich hatte das Gefühl, dass meine Gesichtsbehaarung nicht meiner Geschlechtsidentität entspricht"),
        ("I felt that my genitals matched my gender identity", 
         "Ich hatte das Gefühl, dass meine Genitalien meiner Geschlechtsidentität entsprechen"),
        ("I felt that genital surgery could reduce my dissatisfaction related to my gender", 
         "Ich hatte das Gefühl, dass eine Genitaloperation meine Unzufriedenheit in Bezug auf mein Geschlecht reduzieren kann"),
        ("I was unable to live a fulfilling life because I was dissatisfied with my genitals", 
         "Ich war nicht in der Lage, ein erfülltes Leben zu führen, da ich mit meinen Genitalien unzufrieden war"),
        ("I felt extremely distressed when looking at my chest", 
         "Ich war extrem belastet, wenn ich meine Brust angesehen habe"),
        ("I felt extremely distressed when looking at my genitals", 
         "Ich war extrem belastet, wenn ich meine Genitalien angesehen habe"),
        ("I was satisfied with my chest", 
         "Ich war zufrieden mit meiner Brust"),
        ("I was satisfied at school/university/at work", 
         "Ich war in der Schule/Universität/bei der Arbeit zufrieden"),
        ("I was satisfied with my emotional relationship(s)", 
         "Ich war zufrieden mit meiner emotionalen Beziehung(en)"),
        ("I was satisfied with my sex life", 
         "Ich war zufrieden mit meinem Sexualleben"),
        ("I was satisfied with my leisure activities and hobbies", 
         "Ich war zufrieden mit meinen Freizeitaktivitäten und Hobbies"),
        ("I was dissatisfied with my friendships", 
         "Ich war unzufrieden mit meinen Freundschaften"),
        ("I was satisfied with the support I received from people significant to me", 
         "Ich war zufrieden mit der Unterstützung, die ich von Menschen erhalten habe, die mir wichtig sind"),
        ("I was not satisfied with my health", 
         "Ich war nicht zufrieden mit meiner Gesundheit"),
        ("I was satisfied with my life", 
         "Ich war zufrieden mit meinem Leben")
    ]
    
    results = []
    for i, (en, de) in enumerate(items, 1):
        en_polarity = analyze_polarity(en, 'en')
        de_polarity = analyze_polarity(de, 'de')
        
        results.append({
            'item_number': i,
            'en_text': en,
            'de_text': de,
            'en_polarity': en_polarity,
            'de_polarity': de_polarity,
            'en_category': classify_polarity(en_polarity),
            'de_category': classify_polarity(de_polarity),
            'polarity_match': classify_polarity(en_polarity) == classify_polarity(de_polarity)
        })
    
    return pd.DataFrame(results)

def create_polarity_comparison(df, output_path):
    """Create visualization comparing English and German polarities."""
    plt.figure(figsize=(12, 6))
    
    # Create scatter plot
    plt.scatter(df['en_polarity'], df['de_polarity'], alpha=0.6)
    
    # Add diagonal line
    lims = [
        min(plt.xlim()[0], plt.ylim()[0]),
        max(plt.xlim()[1], plt.ylim()[1])
    ]
    plt.plot(lims, lims, 'k--', alpha=0.5, label='Perfect Match')
    
    # Add labels for outliers
    for idx, row in df.iterrows():
        if abs(row['en_polarity'] - row['de_polarity']) > 0.2:
            plt.annotate(f"Item {row['item_number']}", 
                        (row['en_polarity'], row['de_polarity']))
    
    plt.xlabel('English Item Polarity')
    plt.ylabel('German Item Polarity')
    plt.title('Comparison of Item Polarities between Languages', pad=20)
    plt.grid(True, alpha=0.3)
    plt.legend()
    
    plt.tight_layout()
    plt.savefig(output_path / 'polarity_comparison.png', bbox_inches='tight')
    plt.close()

def create_category_heatmap(df, output_path):
    """Create heatmap of polarity categories."""
    # Create contingency table
    contingency = pd.crosstab(df['en_category'], df['de_category'])
    
    plt.figure(figsize=(10, 8))
    sns.heatmap(contingency, annot=True, fmt='d', cmap='YlOrRd')
    
    plt.title('Distribution of Polarity Categories', pad=20)
    plt.xlabel('German Category')
    plt.ylabel('English Category')
    
    plt.tight_layout()
    plt.savefig(output_path / 'polarity_categories.png', bbox_inches='tight')
    plt.close()

def main():
    # Set up paths
    script_dir = Path(__file__).parent
    output_path = script_dir.parent / 'reports' / 'figures'
    output_path.mkdir(exist_ok=True)
    
    # Set style
    set_style()
    
    # Analyze items
    df = analyze_items()
    
    # Create visualizations
    create_polarity_comparison(df, output_path)
    create_category_heatmap(df, output_path)
    
    # Print statistics
    print("\nPolarity Statistics:")
    print("\nEnglish Items:")
    print(df.groupby('en_category').size())
    print("\nGerman Items:")
    print(df.groupby('de_category').size())
    
    print("\nPolarity Matching:")
    print(f"Items with matching polarity: {sum(df['polarity_match'])} ({sum(df['polarity_match'])/len(df)*100:.1f}%)")
    
    # Save detailed results
    results_path = script_dir.parent / 'reports' / 'polarity_analysis.xlsx'
    df.to_excel(results_path, index=False)
    print(f"\nDetailed results saved to: {results_path}")

if __name__ == '__main__':
    main() 