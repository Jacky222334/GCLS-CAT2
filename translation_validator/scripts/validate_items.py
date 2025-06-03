#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script to validate selected questionnaire items
"""

import os
from pathlib import Path
from translation_validator import TranslationValidator

def main():
    # Get the path to the config file
    script_dir = Path(__file__).parent
    config_path = script_dir.parent / 'config' / 'config.yaml'
    
    validator = TranslationValidator(config_path=str(config_path))

    # Test a few items
    items = [
        ('I have avoided social situations and/or interactions', 
         'Ich habe soziale Situationen und/oder Interaktionen vermieden'),
        ('I was unable to form emotional relationships with other people',
         'Ich bin nicht in der Lage gewesen, emotionale Beziehungen zu anderen Menschen zu knüpfen'),
        ('I felt that my chest did not match my gender identity',
         'Ich hatte das Gefühl, dass meine Brust nicht meiner Geschlechtsidentität entspricht')
    ]

    for source, target in items:
        result = validator.validate_item(source, target)
        print(f'\nValidating:\nEN: {source}\nDE: {target}\n')
        print(f'Semantic similarity: {result["semantic"]["similarity"]:.3f}')
        print(f'Passes threshold: {result["semantic"]["passes_threshold"]}')
        print(f'Sentiment difference: {result["sentiment"]["difference"]:.3f}')
        print('Named entities:', result['ner'])
        print('-' * 80)

if __name__ == '__main__':
    main() 