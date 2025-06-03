# German Validation of the Gender Congruence and Life Satisfaction Scale (G-GCLS)

This repository contains the validation study of the German version of the Gender Congruence and Life Satisfaction Scale (G-GCLS).

## Project Structure

```
.
├── data/               # Data files
│   ├── raw/           # Original survey data
│   ├── processed/     # Cleaned and prepared data
│   └── results/       # Analysis outputs and tables
├── docs/              # Documentation and literature
├── manuscript/        # Manuscript files and drafts
├── figures/           # Visualizations (300 DPI, APA style)
└── R/                 # R code and scripts
```

## File Guidelines

### Data Files
- Keep raw data separate from processed data
- File naming: `YYYYMMDD_description.ext`
- All variable names in English
- Document all data processing steps

### Figures
- All text in English
- APA 7th Edition style
- 300 DPI minimum
- PNG format
- Times New Roman font

### R Scripts
- Comments in English
- Variable names in English
- Document analysis steps

## Setup

1. Install R packages:
```r
# Install required R packages
install.packages("papaja")
install.packages(c("knitr", "kableExtra", "tidyverse", "psych"))
```

2. Install LaTeX:
   - Install a LaTeX distribution (e.g., TeX Live or MiKTeX)
   - XeLaTeX is required for Unicode support 