#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Tests for the Translation Validator
"""

import pytest
from pathlib import Path
import sys
import numpy as np

# Add the parent directory to the Python path
sys.path.append(str(Path(__file__).parent.parent))

from scripts.translation_validator import TranslationValidator

@pytest.fixture
def validator():
    """Create a TranslationValidator instance for testing."""
    return TranslationValidator()

def test_semantic_equivalence(validator):
    """Test semantic equivalence checking."""
    source = "This is a test sentence."
    target = "Dies ist ein Testsatz."
    
    similarity, passes = validator.check_semantic_equivalence(source, target)
    
    assert isinstance(similarity, (float, np.float32))
    assert isinstance(passes, bool)
    assert 0 <= float(similarity) <= 1

def test_named_entities(validator):
    """Test named entity comparison."""
    source = "John lives in Berlin."
    target = "John wohnt in Berlin."
    
    result = validator.compare_named_entities(source, target)
    
    assert isinstance(result, dict)
    assert 'matched' in result
    assert 'source_only' in result
    assert 'target_only' in result

def test_sentiment_analysis(validator):
    """Test sentiment analysis."""
    source = "I am very happy."
    target = "Ich bin sehr glücklich."
    
    result = validator.analyze_sentiment_valence(source, target)
    
    assert isinstance(result, dict)
    assert 'source_score' in result
    assert 'target_score' in result
    assert 'difference' in result
    assert 'significant_difference' in result

def test_cause_effect(validator):
    """Test cause-effect relationship detection."""
    text = "Ich bin müde, weil ich nicht geschlafen habe."
    
    result = validator.check_cause_effect(text)
    
    assert isinstance(result, list)
    assert len(result) > 0
    assert 'marker' in result[0]
    assert 'cause' in result[0]
    assert 'effect' in result[0]

def test_validate_item(validator):
    """Test complete item validation."""
    source = "The patient feels anxious."
    target = "Der Patient fühlt sich ängstlich."
    
    result = validator.validate_item(source, target)
    
    assert isinstance(result, dict)
    assert 'semantic' in result
    assert 'ner' in result
    assert 'sentiment' in result
    assert 'cause_effect' in result 