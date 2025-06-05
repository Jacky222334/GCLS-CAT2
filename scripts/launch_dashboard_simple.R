# =============================================================================
# Simple GCLS-G CAT Dashboard Launcher
# Assumes all packages are already installed
# =============================================================================

# Load required packages
suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(DT)
  library(plotly)
  library(tidyverse)
  library(psych)
})

cat("=== GCLS-G CAT Dashboard ===\n")
cat("Simple launcher - assuming packages are installed\n\n")

# Navigate to scripts directory if needed
if (!file.exists("cat_demonstration.R") && file.exists("scripts/cat_demonstration.R")) {
  setwd("scripts")
}

# Check required files
if (!file.exists("cat_demonstration.R") || !file.exists("cat_dashboard.R")) {
  stop("Missing required files. Please ensure you're in the correct directory.")
}

cat("Starting dashboard...\n")
cat("Dashboard will open in your browser shortly.\n\n")

# Run the dashboard
source("cat_dashboard.R") 