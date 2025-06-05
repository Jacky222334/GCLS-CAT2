# =============================================================================
# GCLS-G CAT Dashboard Launcher
# Interactive Testing Interface for Computerized Adaptive Testing
# =============================================================================

# Set CRAN mirror first
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Install required packages if not already installed
required_packages <- c("shiny", "shinydashboard", "DT", "plotly", 
                      "tidyverse", "psych", "mirt", "catR")

install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    cat("Installing missing packages:", paste(new_packages, collapse = ", "), "\n")
    cat("This may take a few minutes...\n\n")
    
    # Try to install packages with error handling
    for(pkg in new_packages) {
      cat("Installing", pkg, "...\n")
      tryCatch({
        install.packages(pkg, dependencies = TRUE, quiet = FALSE)
        cat("✓", pkg, "installed successfully\n")
      }, error = function(e) {
        cat("✗ Failed to install", pkg, ":", e$message, "\n")
        cat("Please install manually: install.packages('", pkg, "')\n", sep = "")
      })
    }
  } else {
    cat("✓ All required packages are already installed.\n")
  }
}

# Check R version
if (getRversion() < "4.0.0") {
  warning("R version 4.0.0 or higher is recommended for best compatibility.")
}

cat("=== GCLS-G CAT Dashboard ===\n")
cat("Starting interactive dashboard for Computerized Adaptive Testing...\n\n")

# Check and install packages
install_if_missing(required_packages)

cat("\nLoading packages...\n")
# Load packages with error handling
package_load_success <- TRUE
for(pkg in required_packages) {
  tryCatch({
    library(pkg, character.only = TRUE, quietly = TRUE)
    cat("✓", pkg, "loaded\n")
  }, error = function(e) {
    cat("✗ Failed to load", pkg, ":", e$message, "\n")
    package_load_success <<- FALSE
  })
}

if (!package_load_success) {
  stop("Some packages failed to load. Please install missing packages manually and try again.")
}

cat("\nDashboard Features:\n")
cat("• Interactive CAT testing with real-time feedback\n")
cat("• Performance analysis and simulation\n")
cat("• Item pool visualization\n")
cat("• Configurable algorithm settings\n\n")

cat("The dashboard will open in your default web browser.\n")
cat("If it doesn't open automatically, navigate to the URL shown below.\n\n")

# Set working directory to scripts folder if needed
original_dir <- getwd()
if (!file.exists("cat_demonstration.R")) {
  if (file.exists("scripts/cat_demonstration.R")) {
    cat("Switching to scripts directory...\n")
    setwd("scripts")
  } else {
    stop("Error: cat_demonstration.R not found. Please run from the project root directory.")
  }
}

# Check if required files exist
required_files <- c("cat_demonstration.R", "cat_dashboard.R")
missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
  stop("Missing required files: ", paste(missing_files, collapse = ", "))
}

# Source the dashboard
cat("Starting dashboard...\n")
tryCatch({
  source("cat_dashboard.R")
}, error = function(e) {
  cat("Error starting dashboard:", e$message, "\n")
  cat("Please check that all required files are in the correct location.\n")
  cat("Required files:\n")
  cat("- scripts/cat_demonstration.R\n")
  cat("- scripts/cat_dashboard.R\n")
}, finally = {
  # Restore original directory
  setwd(original_dir)
})

cat("\nDashboard session ended.\n") 