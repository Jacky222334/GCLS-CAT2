# =============================================================================
# Package Installation Script for GCLS-G CAT Dashboard
# Run this first if you encounter package installation issues
# =============================================================================

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Required packages
required_packages <- c(
  "shiny",           # Web application framework
  "shinydashboard",  # Dashboard layout
  "DT",             # Interactive tables
  "plotly",         # Interactive plots
  "tidyverse",      # Data manipulation
  "psych"           # Psychometric functions
)

# Optional packages (for full CAT functionality)
optional_packages <- c(
  "mirt",           # Multidimensional IRT
  "catR"            # CAT algorithms
)

cat("=== GCLS-G CAT Dashboard Package Installation ===\n\n")
cat("This script will install required R packages for the dashboard.\n")
cat("Installation may take several minutes...\n\n")

# Function to install packages safely
safe_install <- function(packages, package_type = "required") {
  cat("Installing", package_type, "packages:\n")
  
  success_count <- 0
  fail_count <- 0
  
  for (pkg in packages) {
    cat("Installing", pkg, "... ")
    
    if (pkg %in% installed.packages()[,"Package"]) {
      cat("already installed ✓\n")
      success_count <- success_count + 1
    } else {
      tryCatch({
        install.packages(pkg, dependencies = TRUE, quiet = TRUE)
        cat("success ✓\n")
        success_count <- success_count + 1
      }, error = function(e) {
        cat("failed ✗\n")
        cat("  Error:", e$message, "\n")
        fail_count <- fail_count + 1
      })
    }
  }
  
  cat("\n", package_type, "packages summary:\n")
  cat("  ✓ Success:", success_count, "/", length(packages), "\n")
  cat("  ✗ Failed: ", fail_count, "/", length(packages), "\n\n")
  
  return(fail_count == 0)
}

# Install required packages
required_success <- safe_install(required_packages, "required")

# Install optional packages
cat("Installing optional packages (these may fail without affecting basic functionality):\n")
optional_success <- safe_install(optional_packages, "optional")

# Test package loading
cat("Testing package loading:\n")
load_success <- TRUE
for (pkg in required_packages) {
  tryCatch({
    library(pkg, character.only = TRUE, quietly = TRUE)
    cat("✓", pkg, "loads correctly\n")
  }, error = function(e) {
    cat("✗", pkg, "failed to load:", e$message, "\n")
    load_success <- FALSE
  })
}

# Final summary
cat("\n=== Installation Summary ===\n")
if (required_success && load_success) {
  cat("✓ All required packages installed and working!\n")
  cat("✓ Dashboard is ready to run.\n\n")
  cat("To start the dashboard:\n")
  cat("  source('scripts/launch_dashboard_simple.R')\n\n")
} else {
  cat("✗ Some packages failed to install or load.\n")
  cat("Please install missing packages manually:\n")
  for (pkg in required_packages) {
    if (!pkg %in% installed.packages()[,"Package"]) {
      cat("  install.packages('", pkg, "')\n", sep = "")
    }
  }
  cat("\nAlternatively, try running individual package installations:\n")
  cat("  install.packages(c('shiny', 'shinydashboard', 'DT', 'plotly'))\n")
  cat("  install.packages('tidyverse')\n")
  cat("  install.packages('psych')\n")
}

cat("\nR version:", as.character(getRversion()), "\n")
cat("Platform:", R.version$platform, "\n") 