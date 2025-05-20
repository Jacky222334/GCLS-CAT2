# German Validation of the Gender Congruence and Life Satisfaction Scale (G-GCLS)

This repository contains the validation study of the German version of the Gender Congruence and Life Satisfaction Scale (G-GCLS).

## Language Policy

- Project Communication/Chat: German
- Code and Documentation: English
- Analysis Outputs: English (APA Style)
- Manuscript: English (APA Style)
- Reference Materials: Original language (English/German)

## Project Structure

```
.
├── data/               # Data files
│   ├── raw/           # Original survey data (not tracked in git)
│   ├── processed/     # Cleaned and prepared data
│   ├── results/       # Analysis outputs
│   └── archive/       # Archived data files
├── docs/              # Documentation
│   ├── literature/    # Scientific publications
│   └── methods/       # Methodological documents
├── figures/           # Generated visualizations (300 DPI, APA style)
├── manuscript/        # Manuscript files
│   ├── md/           # Markdown source
│   ├── pdf/          # PDF output
│   └── tex/          # LaTeX files
└── R/                 # R code
    ├── functions/     # Utility functions
    └── scripts/       # Analysis scripts
```

## Directory Guidelines

### Data Directory
- Raw data files containing personal information must not be committed to git
- File naming format: `YYYYMMDD_description.ext`
- All variable names in English
- Document data cleaning steps in processing scripts

### Documentation Directory
- Literature: Original research papers and publications
- Methods: Study protocols and methodological documents
- File naming format: `YYYY_author_description.ext`
- Version numbers included where applicable

### Figures Directory
- All figure text in English
- APA 7th Edition formatting
- Resolution: 300 DPI minimum
- Format: PNG for web, PDF for publication
- Font: Times New Roman
- Naming: `analysis_type_description_YYYYMMDD.ext`

### R Code Directory
- All code comments in English
- Variable names in English
- Function documentation in English
- Output formatting follows APA 7th Edition guidelines

## Setup and Usage

1. Install dependencies:
```