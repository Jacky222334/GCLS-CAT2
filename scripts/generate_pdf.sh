#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p manuscript/pdf

# Convert to PDF using pandoc with Unicode support
pandoc manuscript/header.yaml manuscript/manuscript_consolidated.md \
  --pdf-engine=xelatex \
  --from=markdown \
  -V geometry:margin=1in \
  -V documentclass=article \
  --standalone \
  --number-sections \
  -V fontenc=T1 \
  -V babel-lang=english \
  --output=manuscript/pdf/manuscript_complete.pdf

echo "PDF generation complete. Output file: manuscript/pdf/manuscript_complete.pdf" 