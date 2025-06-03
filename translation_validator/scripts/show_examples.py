#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Show examples of items with different polarity between languages
"""

import pandas as pd
from pathlib import Path

def main():
    # Load results
    script_dir = Path(__file__).parent
    results_path = script_dir.parent / 'reports' / 'polarity_analysis.xlsx'
    df = pd.read_excel(results_path)
    
    # Show examples with large differences
    print("\nBeispiele mit großen Unterschieden in der Polarität:")
    print("=" * 80)
    
    for _, row in df.iterrows():
        if abs(row['en_polarity'] - row['de_polarity']) > 0.2:
            print(f"\nItem {row['item_number']}:")
            print(f"EN: {row['en_text']}")
            print(f"Polarität: {row['en_polarity']:.3f} ({row['en_category']})")
            print(f"\nDE: {row['de_text']}")
            print(f"Polarität: {row['de_polarity']:.3f} ({row['de_category']})")
            print("-" * 80)
    
    # Show examples with matching polarity
    print("\n\nBeispiele mit übereinstimmender Polarität:")
    print("=" * 80)
    
    matches = 0
    for _, row in df.iterrows():
        if row['polarity_match'] and matches < 3:
            matches += 1
            print(f"\nItem {row['item_number']}:")
            print(f"EN: {row['en_text']}")
            print(f"Polarität: {row['en_polarity']:.3f} ({row['en_category']})")
            print(f"\nDE: {row['de_text']}")
            print(f"Polarität: {row['de_polarity']:.3f} ({row['de_category']})")
            print("-" * 80)

if __name__ == '__main__':
    main() 