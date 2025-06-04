# EFA Analysis with Item 26 included
# Load required packages
library(readxl)      # For reading Excel files
library(psych)       # For factor analysis
library(GPArotation) # For factor rotation
library(corrplot)    # For correlation visualization
library(nFactors)    # For determining number of factors
library(tidyverse)   # For data manipulation
library(ggplot2)     # For enhanced plotting

# Create results directory
dir.create("efa_results_with_i26", showWarnings = FALSE)

# Read the data WITH Item 26
cat("Reading data with Item 26...\n")
data <- read_excel("/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Print initial data information
cat("\nInitial data structure:\n")
str(data)
cat("\nColumn names:\n")
print(colnames(data))

# Check specifically for Item 26
item_cols <- grep("I[0-9]+", colnames(data), value = TRUE)
cat("\nItem columns found:\n")
print(sort(item_cols))
cat("\nTotal items found:", length(item_cols), "\n")

# Check if Item 26 exists
has_i26 <- "I26" %in% colnames(data)
cat("\nItem 26 present:", has_i26, "\n")

# Function to prepare data for EFA
prepare_data <- function(data) {
  # Select only GCLS item columns (I1-I38)
  item_cols <- paste0("I", 1:38)
  available_items <- item_cols[item_cols %in% colnames(data)]
  
  cat("\nSelecting GCLS items...\n")
  cat("Available items:", length(available_items), "\n")
  cat("Missing items:", setdiff(item_cols, available_items), "\n")
  
  # Select the item data
  gcls_data <- data[, available_items, drop = FALSE]
  
  # Convert to numeric if needed
  gcls_data <- gcls_data %>% mutate_all(as.numeric)
  
  # Check for missing values
  missing_summary <- colSums(is.na(gcls_data))
  cat("\nMissing values per item:\n")
  print(missing_summary)
  
  # Remove cases with missing data
  complete_data <- na.omit(gcls_data)
  
  cat("\nDimensions after cleaning:\n")
  cat("Original:", nrow(data), "rows,", ncol(gcls_data), "items\n")
  cat("After cleaning:", nrow(complete_data), "rows,", ncol(complete_data), "items\n")
  
  # Check if we have Item 26
  if("I26" %in% colnames(complete_data)) {
    cat("\n✅ Item 26 IS included in the analysis!\n")
  } else {
    cat("\n❌ Item 26 is NOT included in the analysis!\n")
  }
  
  return(complete_data)
}

# Function to run comprehensive EFA
run_efa_analysis <- function(data) {
  # Check EFA suitability
  cat("\nChecking EFA suitability...\n")
  
  # KMO test
  kmo_result <- KMO(data)
  cat("KMO Overall:", round(kmo_result$MSA, 3), "\n")
  
  # Bartlett's test
  bartlett_result <- cortest.bartlett(cor(data), n = nrow(data))
  cat("Bartlett's test p-value:", formatC(bartlett_result$p.value, format = "e", digits = 2), "\n")
  
  # Determine optimal number of factors
  cat("\nDetermining number of factors...\n")
  
  # Parallel analysis
  pa_result <- fa.parallel(data, fa = "fa", fm = "ml")
  
  # Try 7-factor solution (as in original)
  cat("\nRunning 7-factor EFA with oblique rotation...\n")
  fa_result <- fa(data, nfactors = 7, rotate = "oblimin", fm = "ml")
  
  # Print basic results
  cat("\nFit indices:\n")
  cat("RMSEA:", round(fa_result$RMSEA[1], 3), "\n")
  cat("TLI:", round(fa_result$TLI, 3), "\n")
  cat("BIC:", round(fa_result$BIC, 1), "\n")
  
  # Check variance explained
  variance_explained <- fa_result$Vaccounted
  cat("\nVariance explained by factors:\n")
  print(round(variance_explained, 3))
  
  # Print factor loadings
  loadings_matrix <- unclass(fa_result$loadings)
  
  # Save detailed results
  sink("efa_results_with_i26/efa_results_detailed.txt")
  cat("EFA Results with Item 26\n")
  cat("========================\n\n")
  cat("Sample size:", nrow(data), "\n")
  cat("Number of items:", ncol(data), "\n")
  cat("Items included:", paste(colnames(data), collapse = ", "), "\n\n")
  
  cat("Fit Indices:\n")
  cat("RMSEA:", fa_result$RMSEA[1], "\n")
  cat("TLI:", fa_result$TLI, "\n") 
  cat("BIC:", fa_result$BIC, "\n")
  cat("Chi-square:", fa_result$chi, "\n")
  cat("df:", fa_result$dof, "\n\n")
  
  cat("KMO test:", kmo_result$MSA, "\n")
  cat("Bartlett's test p-value:", bartlett_result$p.value, "\n\n")
  
  cat("Factor Loadings:\n")
  print(round(loadings_matrix, 3))
  
  if(!is.null(fa_result$Phi)) {
    cat("\nFactor Correlations:\n")
    print(round(fa_result$Phi, 3))
  }
  
  cat("\nVariance Explained:\n")
  print(variance_explained)
  sink()
  
  # Save loadings as CSV
  loadings_df <- as.data.frame(loadings_matrix)
  loadings_df$Item <- rownames(loadings_df)
  write.csv(loadings_df, "efa_results_with_i26/factor_loadings_with_i26.csv", row.names = FALSE)
  
  # Create factor loading table for manuscript
  create_manuscript_table(loadings_df, fa_result)
  
  return(fa_result)
}

# Function to create manuscript-ready table
create_manuscript_table <- function(loadings_df, fa_result) {
  # Round loadings
  loadings_rounded <- loadings_df
  loadings_rounded[,1:7] <- round(loadings_rounded[,1:7], 2)
  
  # Add factor labels (you may need to adjust these based on content)
  factor_labels <- c("ML1", "ML2", "ML3", "ML4", "ML5", "ML6", "ML7")
  colnames(loadings_rounded)[1:7] <- factor_labels
  
  # Save for manuscript
  write.csv(loadings_rounded, "efa_results_with_i26/manuscript_table_loadings.csv", row.names = FALSE)
  
  # Check if Item 26 is included
  if("I26" %in% loadings_rounded$Item) {
    i26_loadings <- loadings_rounded[loadings_rounded$Item == "I26", 1:7]
    cat("\n✅ Item 26 loadings:\n")
    print(i26_loadings)
  }
  
  cat("\nManuscript table saved to: efa_results_with_i26/manuscript_table_loadings.csv\n")
}

# Main execution
main <- function() {
  cat("=== EFA Analysis with Item 26 ===\n")
  
  # Prepare data
  prepared_data <- prepare_data(data)
  
  # Run EFA
  fa_result <- run_efa_analysis(prepared_data)
  
  cat("\n=== Analysis Complete ===\n")
  cat("Results saved in: efa_results_with_i26/\n")
  cat("Key files:\n")
  cat("- efa_results_detailed.txt: Complete results\n")
  cat("- factor_loadings_with_i26.csv: Factor loadings\n")
  cat("- manuscript_table_loadings.csv: Table for manuscript\n")
  
  return(fa_result)
}

# Run the analysis
result <- main() 