#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Translation Validation Pipeline
This script implements a structured pipeline for validating translated items
using various NLP techniques including semantic similarity, NER, and sentiment analysis.
"""

import logging
from pathlib import Path
from typing import List, Dict, Tuple, Optional

import numpy as np
import pandas as pd
from sentence_transformers import SentenceTransformer
import spacy
from transformers import pipeline

class TranslationValidator:
    def __init__(self, config_path: str = "config/config.yaml"):
        """Initialize the translation validator with configuration."""
        self.config = self._load_config(config_path)
        self.semantic_model = self._init_semantic_model()
        self.ner_model = self._init_ner_model()
        self.sentiment_model = self._init_sentiment_model()
        
    def _load_config(self, config_path: str) -> dict:
        """Load configuration from YAML file."""
        import yaml
        with open(config_path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    
    def _init_semantic_model(self) -> SentenceTransformer:
        """Initialize the sentence transformer model."""
        return SentenceTransformer('paraphrase-multilingual-mpnet-base-v2')
    
    def _init_ner_model(self) -> spacy.language.Language:
        """Initialize spaCy NER model."""
        return spacy.load('de_core_news_lg')
    
    def _init_sentiment_model(self):
        """Initialize sentiment analysis model."""
        return pipeline("sentiment-analysis", 
                      model="oliverguhr/german-sentiment-bert")
    
    def check_semantic_equivalence(self, 
                                 source_text: str, 
                                 target_text: str) -> Tuple[float, bool]:
        """
        Check semantic equivalence between source and target texts.
        Returns similarity score and whether it passes threshold.
        """
        embeddings = self.semantic_model.encode([source_text, target_text])
        similarity = float(np.dot(embeddings[0], embeddings[1]) / (
            np.linalg.norm(embeddings[0]) * np.linalg.norm(embeddings[1])))
        
        passes_threshold = similarity >= self.config['similarity_threshold']
        return similarity, passes_threshold
    
    def compare_named_entities(self, 
                             source_text: str, 
                             target_text: str) -> Dict[str, List[str]]:
        """
        Compare named entities between source and target texts.
        Returns dictionary of matched and unmatched entities.
        """
        source_doc = self.ner_model(source_text)
        target_doc = self.ner_model(target_text)
        
        source_ents = {(ent.text, ent.label_) for ent in source_doc.ents}
        target_ents = {(ent.text, ent.label_) for ent in target_doc.ents}
        
        return {
            'matched': list(source_ents & target_ents),
            'source_only': list(source_ents - target_ents),
            'target_only': list(target_ents - source_ents)
        }
    
    def analyze_sentiment_valence(self, 
                                source_text: str, 
                                target_text: str) -> Dict[str, float]:
        """
        Analyze sentiment valence in source and target texts.
        Returns sentiment scores and difference.
        """
        source_sentiment = self.sentiment_model(source_text)[0]
        target_sentiment = self.sentiment_model(target_text)[0]
        
        difference = abs(source_sentiment['score'] - target_sentiment['score'])
        
        return {
            'source_score': source_sentiment['score'],
            'target_score': target_sentiment['score'],
            'difference': difference,
            'significant_difference': difference > self.config['valence_threshold']
        }
    
    def check_cause_effect(self, text: str) -> List[Dict[str, str]]:
        """
        Identify cause-effect relationships in text.
        Returns list of identified relationships.
        """
        doc = self.ner_model(text)
        relationships = []
        
        # Check for causal markers
        causal_markers = self.config.get('causal_markers', [])
        for token in doc:
            if token.text.lower() in causal_markers:
                # Find the surrounding clauses
                prev_clause = ' '.join([t.text for t in token.doc[:token.i]])
                next_clause = ' '.join([t.text for t in token.doc[token.i+1:]])
                
                if prev_clause and next_clause:
                    relationships.append({
                        'marker': token.text,
                        'cause': next_clause.strip(),
                        'effect': prev_clause.strip()
                    })
        
        return relationships
    
    def validate_item(self, 
                     source_text: str, 
                     target_text: str) -> Dict[str, any]:
        """
        Run complete validation pipeline on a single item pair.
        Returns comprehensive validation results.
        """
        results = {}
        
        # Semantic equivalence check
        similarity, passes_threshold = self.check_semantic_equivalence(
            source_text, target_text)
        results['semantic'] = {
            'similarity': similarity,
            'passes_threshold': passes_threshold
        }
        
        # Named entity comparison
        results['ner'] = self.compare_named_entities(source_text, target_text)
        
        # Sentiment analysis
        results['sentiment'] = self.analyze_sentiment_valence(
            source_text, target_text)
        
        # Cause-effect analysis
        results['cause_effect'] = self.check_cause_effect(target_text)
        
        return results
    
    def generate_report(self, results: List[Dict[str, any]]) -> pd.DataFrame:
        """
        Generate a comprehensive validation report.
        Returns DataFrame with validation results.
        """
        report_data = []
        for result in results:
            row = {
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
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    
    # Initialize validator
    validator = TranslationValidator()
    
    # Example usage
    source_text = "This item measures anxiety levels."
    target_text = "Dieses Item misst das Angstniveau."
    
    results = validator.validate_item(source_text, target_text)
    logger.info(f"Validation results: {results}")

if __name__ == "__main__":
    main() 