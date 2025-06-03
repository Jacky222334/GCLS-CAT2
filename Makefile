# Language Policy:
# - Project Communication/Chat: German
# - Code/Comments: English
# - Documentation: English
# - Analysis Outputs: English (APA Style)
# - Manuscript: English (APA Style)

.PHONY: all clean pdf md tex setup check-structure organize validate-structure

# Directories
DATA_DIR = data
RAW_DIR = $(DATA_DIR)/raw
PROCESSED_DIR = $(DATA_DIR)/processed
RESULTS_DIR = $(DATA_DIR)/results
FIGURES_DIR = figures
OUTPUT_DIR = output
TABLES_DIR = $(OUTPUT_DIR)/tables
TEMP_DIR = $(OUTPUT_DIR)/temp

# Default target
all: check-structure setup organize

# Directory structure validation
check-structure:
	@echo "Checking project structure..."
	@mkdir -p $(RAW_DIR) $(PROCESSED_DIR) $(RESULTS_DIR)
	@mkdir -p $(FIGURES_DIR)
	@mkdir -p $(TABLES_DIR)
	@mkdir -p $(TEMP_DIR)
	@mkdir -p docs/references
	@mkdir -p manuscript/tex manuscript/pdf manuscript/md/figures
	@mkdir -p R/scripts R/functions
	@test -d $(RAW_DIR) || (echo "Missing raw data directory" && exit 1)
	@test -d $(PROCESSED_DIR) || (echo "Missing processed data directory" && exit 1)
	@test -d $(RESULTS_DIR) || (echo "Missing results directory" && exit 1)
	@test -d $(FIGURES_DIR) || (echo "Missing figures directory" && exit 1)
	@test -d docs/references || (echo "Missing references directory" && exit 1)

# Organize files into correct directories
organize:
	@echo "Organizing output files..."
	@# Move PDF files to figures directory
	@find $(OUTPUT_DIR) -name "*.pdf" -exec mv {} $(FIGURES_DIR)/ \;
	@# Move HTML files to temp directory
	@find $(OUTPUT_DIR) -name "*.html" -exec mv {} $(TEMP_DIR)/ \;
	@# Move text files to tables directory
	@find $(OUTPUT_DIR) -name "*.txt" -exec mv {} $(TABLES_DIR)/ \;
	@# Clean up any empty directories in output
	@find $(OUTPUT_DIR) -type d -empty -delete
	@echo "File organization complete"

# Validate structure and clean up
validate-structure: check-structure organize
	@echo "Project structure validated and organized"

# Setup directories and templates
setup: validate-structure
	@echo "Setup complete"

# Clean generated files
clean:
	rm -rf $(OUTPUT_DIR)/*
	rm -rf $(FIGURES_DIR)/*
	rm -rf $(TABLES_DIR)/*
	rm -rf $(TEMP_DIR)/*

# Clean all generated files and directories
clean-all: clean
	rm -rf $(PROCESSED_DIR)/*
	rm -rf $(RESULTS_DIR)/*

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Create directories and organize files (default)"
	@echo "  check-structure - Verify project directory structure"
	@echo "  organize     - Move files to appropriate directories"
	@echo "  clean        - Remove generated files"
	@echo "  clean-all    - Remove all generated files and directories"
	@echo "  help         - Show this help message"

# Convert RMarkdown to PDF
pdf: manuscript/md/manuscript.Rmd
	cd manuscript/md && \
	Rscript -e "rmarkdown::render('manuscript.Rmd', \
		output_format = rmarkdown::pdf_document(template = '../templates/apa7.tex'), \
		output_file = '../pdf/manuscript.pdf')"

# Convert RMarkdown to Markdown
md: manuscript/md/manuscript.Rmd
	cd manuscript/md && \
	Rscript -e "rmarkdown::render('manuscript.Rmd', \
		output_format = 'md_document', \
		output_file = '../md/manuscript.md')"

# Convert RMarkdown to LaTeX
tex: manuscript/md/manuscript.Rmd
	cd manuscript/md && \
	Rscript -e "rmarkdown::render('manuscript.Rmd', \
		output_format = rmarkdown::latex_document(template = '../templates/apa7.tex'), \
		output_file = '../tex/manuscript.tex')"

# Run analysis
analysis: validate-structure
	Rscript R/scripts/analysis.R

# Generate all figures
figures: validate-structure
	Rscript R/scripts/figures.R

# Install required R packages
install:
	Rscript -e "repos <- getOption('repos'); repos['CRAN'] <- 'https://cloud.r-project.org'; options(repos=repos); install.packages(c('knitr', 'kableExtra', 'tidyverse', 'psych', 'rmarkdown', 'tinytex'))"
	Rscript -e "tinytex::install_tinytex(force = TRUE)"

# Full reproduction with structure validation
reproduce: clean validate-structure install analysis figures all 

code . 