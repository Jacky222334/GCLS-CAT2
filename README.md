# German Validation of the Gender Congruence and Life Satisfaction Scale (G-GCLS)

This repository contains the validation study of the German version of the Gender Congruence and Life Satisfaction Scale (G-GCLS).

## Language Policy

- Project Communication/Chat: German
- Code and Documentation: English
- Analysis Outputs: English (APA Style)
- Manuscript: English (APA Style)
- Reference Materials: Original language (English/German)

## Project Structure

```mermaid
graph TD
    A[GCLS German Validation] --> B[data]
    A --> C[docs]
    A --> D[R]
    A --> E[manuscript]
    A --> F[figures]
    A --> G[references]
    A --> H[output]

    B --> B1[raw]
    B --> B2[processed]
    B --> B3[results]
    B --> B4[archive]
    B3 --> B3_1[tables]

    C --> C1[literature]
    C --> C2[methods]

    D --> D1[functions]
    D --> D2[scripts]
    D2 --> D2_1[analysis_main.R]
    D2 --> D2_2[data_preparation.R]
    D2 --> D2_3[factor_analysis.R]
    D2 --> D2_4[reliability_validity.R]

    E --> E1[md]

    H --> H1[tables]
    H --> H2[reports]
```

```
.
├── data/               # Data files
│   ├── raw/           # Original survey data (not tracked in git)
│   ├── processed/     # Cleaned and prepared data
│   ├── results/       # Analysis outputs
│   │   └── tables/    # Analysis tables (CSV, RData)
│   └── archive/       # Archived data files
├── docs/              # Documentation
│   ├── literature/    # Scientific publications
│   └── methods/       # Methodological documents
├── figures/           # Generated visualizations (300 DPI, APA style)
├── manuscript/        # Manuscript files
│   └── md/           # Markdown source
├── output/            # Final outputs for publication
│   ├── tables/       # Publication-ready tables
│   └── reports/      # HTML reports and visualizations
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

### Output Directory
- `tables/`: Final, publication-ready tables (Markdown, LaTeX, PDF)
- `reports/`: HTML reports and visualizations for review
- All outputs follow APA 7th Edition guidelines

### R Code Directory
- All code comments in English
- Variable names in English
- Function documentation in English
- Output formatting follows APA 7th Edition guidelines

#### Structure
- `functions/`: Utility functions and helper code
  - `apa_style_utils.R`: Functions for APA-compliant output formatting
  
- `scripts/`: Analysis scripts
  - `analysis_main.R`: Main analysis coordinator
  - `data_preparation.R`: Data cleaning and preparation
  - `descriptive_analysis.R`: Descriptive statistics
  - `efa_prerequisites.R`: EFA assumptions checking
  - `factor_analysis.R`: Factor analysis implementation
  - `reliability_validity.R`: Reliability and validity analyses

#### Usage
All scripts are called from `analysis_main.R`. To run the complete analysis:

```R
source("R/scripts/analysis_main.R")
```

## Setup and Usage

1. Install R dependencies:
```r
# Install required R packages
install.packages("papaja")
install.packages(c("knitr", "kableExtra", "tidyverse", "psych"))
```

2. Install LaTeX:
   - Eine LaTeX-Distribution (z.B. TeX Live oder MiKTeX)
   - XeLaTeX wird für Unicode-Unterstützung benötigt

3. Manuscript Compilation with papaja::apa6_pdf:

Die Vorlage ist in der YAML-Konfiguration des Manuskripts eingerichtet:

```yaml
output:
  papaja::apa6_pdf:
    citation_package: natbib
    latex_engine: xelatex
    includes:
      in_header: "../templates/apa7.tex"
```

Das Manuskript kann auf zwei Arten kompiliert werden:

a) In RStudio:
   - Öffne `manuscript/md/manuscript.Rmd`
   - Klicke auf "Knit"

b) Via Kommandozeile:
```r
rmarkdown::render('manuscript/md/manuscript.Rmd')
```

### Troubleshooting

- Unicode-Probleme: XeLaTeX-Engine verwenden
- Zitationsprobleme: BibTeX-Datei auf Vollständigkeit prüfen
- Formatierungsprobleme: apa7.tex auf Konflikte prüfen