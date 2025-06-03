#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Batch Processor for Translation Validation
This script processes multiple items from a CSV file and generates a comprehensive report.
"""

import logging
import pandas as pd
from pathlib import Path
from typing import Optional
from translation_validator import TranslationValidator

class BatchProcessor:
    def __init__(self, validator: Optional[TranslationValidator] = None):
        """Initialize the batch processor."""
        self.validator = validator or TranslationValidator()
        self.logger = self._setup_logging()
        
    def _setup_logging(self) -> logging.Logger:
        """Set up logging configuration."""
        logger = logging.getLogger(__name__)
        logger.setLevel(logging.INFO)
        
        # Create handlers
        c_handler = logging.StreamHandler()
        f_handler = logging.FileHandler('logs/batch_processing.log')
        
        # Create formatters
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        c_handler.setFormatter(formatter)
        f_handler.setFormatter(formatter)
        
        # Add handlers
        logger.addHandler(c_handler)
        logger.addHandler(f_handler)
        
        return logger
    
    def process_file(self, 
                    input_file: str, 
                    output_file: Optional[str] = None) -> pd.DataFrame:
        """
        Process all items in the input file and generate a report.
        
        Args:
            input_file: Path to the input CSV file
            output_file: Optional path for the output report
            
        Returns:
            DataFrame containing the validation results
        """
        # Read input file
        df = pd.read_csv(input_file)
        self.logger.info(f"Loaded {len(df)} items from {input_file}")
        
        # Process each item
        results = []
        for idx, row in df.iterrows():
            self.logger.info(f"Processing item {idx + 1}/{len(df)}")
            
            try:
                result = self.validator.validate_item(
                    row['source_text'], 
                    row['target_text']
                )
                
                # Add metadata
                result['item_id'] = row.get('item_id', idx)
                result['domain'] = row.get('domain', 'unknown')
                
                results.append(result)
                
            except Exception as e:
                self.logger.error(f"Error processing item {idx + 1}: {str(e)}")
                continue
        
        # Create report DataFrame
        report_df = self._create_report(results)
        
        # Save report if output file specified
        if output_file:
            report_df.to_excel(output_file, index=False)
            self.logger.info(f"Saved report to {output_file}")
        
        return report_df
    
    def _create_report(self, results: list) -> pd.DataFrame:
        """
        Create a structured report from validation results.
        
        Args:
            results: List of validation results
            
        Returns:
            DataFrame containing the structured report
        """
        # Extract relevant metrics
        report_data = []
        for result in results:
            row = {
                'item_id': result['item_id'],
                'domain': result['domain'],
                'semantic_similarity': result['semantic']['similarity'],
                'passes_threshold': result['semantic']['passes_threshold'],
                'matched_entities': len(result['ner']['matched']),
                'missing_entities': len(result['ner']['source_only']),
                'extra_entities': len(result['ner']['target_only']),
                'sentiment_difference': result['sentiment']['difference'],
                'significant_sentiment_diff': result['sentiment']['significant_difference'],
                'cause_effect_relations': len(result['cause_effect'])
            }
            report_data.append(row)
        
        return pd.DataFrame(report_data)

def main():
    """Main execution function."""
    # Set up logging
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    
    # Initialize processor
    processor = BatchProcessor()
    
    # Process example file
    input_file = "data/raw/example_items.csv"
    output_file = "reports/validation_report.xlsx"
    
    try:
        report = processor.process_file(input_file, output_file)
        logger.info("Processing completed successfully")
        
    except Exception as e:
        logger.error(f"Error during processing: {str(e)}")
        raise

if __name__ == "__main__":
    main() 