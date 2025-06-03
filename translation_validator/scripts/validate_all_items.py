#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script to validate all questionnaire items and generate statistics
"""

import os
from pathlib import Path
import pandas as pd
import numpy as np
from translation_validator import TranslationValidator

# All items from the questionnaire
ITEMS = [
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
    ("I felt that my body hair did not match my gender identity – either because I have it and don't like it, or because I would like to have it", 
     "Ich hatte das Gefühl, dass meine Körperbehaarung nicht zu meiner Geschlechtsidentität passt – entweder weil ich welche habe und sie nicht mag oder weil ich welche haben möchte"),
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
    ("I felt that my facial hair did not match my gender identity – either because I have it and don't like it, or because I would like to have it", 
     "Ich hatte das Gefühl, dass meine Gesichtsbehaarung nicht meiner Geschlechtsidentität entspricht – entweder weil ich welche habe und sie nicht mag oder weil ich gerne welche hätte"),
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

def analyze_results(results_df):
    """Generate statistical analysis of validation results."""
    stats = {
        'Semantic Similarity': {
            'Mean': results_df['semantic_similarity'].mean(),
            'Std': results_df['semantic_similarity'].std(),
            'Min': results_df['semantic_similarity'].min(),
            'Max': results_df['semantic_similarity'].max(),
            'Items below threshold': sum(~results_df['passes_threshold'])
        },
        'Sentiment Difference': {
            'Mean': results_df['sentiment_difference'].mean(),
            'Std': results_df['sentiment_difference'].std(),
            'Min': results_df['sentiment_difference'].min(),
            'Max': results_df['sentiment_difference'].max(),
            'Significant differences': sum(results_df['significant_sentiment_diff'])
        }
    }
    
    # Calculate distribution of similarity scores
    bins = [0, 0.7, 0.8, 0.85, 0.9, 0.95, 1.0]
    hist = np.histogram(results_df['semantic_similarity'], bins=bins)[0]
    stats['Similarity Distribution'] = {
        f'{bins[i]:.2f}-{bins[i+1]:.2f}': hist[i] for i in range(len(hist))
    }
    
    return stats

def main():
    # Get the path to the config file
    script_dir = Path(__file__).parent
    config_path = script_dir.parent / 'config' / 'config.yaml'
    
    validator = TranslationValidator(config_path=str(config_path))
    
    # Store results for analysis
    results = []
    
    # Process all items
    for idx, (source, target) in enumerate(ITEMS, 1):
        result = validator.validate_item(source, target)
        
        # Print individual results
        print(f'\nItem {idx}/37:')
        print(f'EN: {source}')
        print(f'DE: {target}\n')
        print(f'Semantic similarity: {result["semantic"]["similarity"]:.3f}')
        print(f'Passes threshold: {result["semantic"]["passes_threshold"]}')
        print(f'Sentiment difference: {result["sentiment"]["difference"]:.3f}')
        print('Named entities:', result['ner'])
        print('-' * 80)
        
        # Store results for analysis
        results.append({
            'item_number': idx,
            'source_text': source,
            'target_text': target,
            'semantic_similarity': result['semantic']['similarity'],
            'passes_threshold': result['semantic']['passes_threshold'],
            'sentiment_difference': result['sentiment']['difference'],
            'significant_sentiment_diff': result['sentiment']['significant_difference'],
            'matched_entities': len(result['ner']['matched']),
            'source_only_entities': len(result['ner']['source_only']),
            'target_only_entities': len(result['ner']['target_only'])
        })
    
    # Create DataFrame and analyze results
    results_df = pd.DataFrame(results)
    stats = analyze_results(results_df)
    
    # Print statistics
    print('\nSTATISTICAL ANALYSIS')
    print('=' * 50)
    
    print('\nSemantic Similarity Statistics:')
    for key, value in stats['Semantic Similarity'].items():
        print(f'{key}: {value:.3f}')
    
    print('\nSentiment Difference Statistics:')
    for key, value in stats['Sentiment Difference'].items():
        print(f'{key}: {value:.3f}')
    
    print('\nSimilarity Score Distribution:')
    for range_str, count in stats['Similarity Distribution'].items():
        print(f'{range_str}: {count} items')
    
    # Save results to Excel
    output_path = script_dir.parent / 'reports' / 'validation_results.xlsx'
    results_df.to_excel(output_path, index=False)
    print(f'\nDetailed results saved to: {output_path}')

if __name__ == '__main__':
    main() 