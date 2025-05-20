.PHONY: all clean pdf md tex setup

all: setup pdf md tex

# Setup directories and templates
setup:
	mkdir -p manuscript/tex manuscript/pdf manuscript/md/figures
	mkdir -p data/raw data/processed data/output
	mkdir -p R/scripts R/functions
	mkdir -p figures references docs

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

# Clean generated files
clean:
	rm -f manuscript/pdf/*.pdf
	rm -f manuscript/tex/*.tex
	rm -f manuscript/md/*.md
	rm -f figures/*.png
	rm -f data/output/*.json

# Run analysis
analysis:
	Rscript R/scripts/analysis.R

# Generate all figures
figures:
	Rscript R/scripts/figures.R

# Install required R packages
install:
	Rscript -e "repos <- getOption('repos'); repos['CRAN'] <- 'https://cloud.r-project.org'; options(repos=repos); install.packages(c('knitr', 'kableExtra', 'tidyverse', 'psych', 'rmarkdown', 'tinytex'))"
	Rscript -e "tinytex::install_tinytex(force = TRUE)"

# Full reproduction
reproduce: clean setup install analysis figures all 