# Simplified EFA Analysis with Item 26 - Direct 7-Factor Solution
library(readxl)
library(psych)
library(GPArotation)
library(corrplot)

# Read the data WITH Item 26
cat("Reading data with Item 26...\n")
data <- read_excel("/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Select only GCLS items (I1 to I38)
gcls_items <- data[, paste0("I", 1:38)]
cat("Items selected: I1 to I38 (38 items total)\n")
cat("Sample size:", nrow(gcls_items), "\n")

# Check for missing values
missing_summary <- colSums(is.na(gcls_items))
cat("Missing values per item:\n")
print(missing_summary)

# Basic descriptives
cat("\nDescriptive statistics:\n")
print(psych::describe(gcls_items))

# Check EFA suitability
kmo_result <- psych::KMO(gcls_items)
bartlett_result <- psych::cortest.bartlett(gcls_items)

cat("\n=== EFA Suitability ===\n")
cat("KMO Overall:", round(kmo_result$MSA, 3), "\n")
cat("Bartlett's test p-value:", format(bartlett_result$p.value, scientific = TRUE), "\n")

# Direct 7-Factor EFA with oblique rotation
cat("\n=== Running 7-Factor EFA ===\n")
efa_result <- psych::fa(gcls_items, 
                       nfactors = 7,
                       rotate = "oblimin",
                       fm = "ml",
                       scores = "tenBerge")

# Print results
cat("\n=== Factor Analysis Results ===\n")
print(efa_result)

# Save factor loadings
loadings_matrix <- efa_result$loadings
class(loadings_matrix) <- "matrix"

# Create a clean loadings table
loadings_df <- as.data.frame(loadings_matrix)
loadings_df$Item <- paste0("I", 1:38)
loadings_df <- loadings_df[, c("Item", paste0("ML", 1:7))]

# Round to 3 decimal places
loadings_df[, 2:8] <- round(loadings_df[, 2:8], 3)

# Print loadings table
cat("\n=== Factor Loadings Table ===\n")
print(loadings_df)

# Save results to CSV
write.csv(loadings_df, "factor_loadings_38items.csv", row.names = FALSE)
cat("\nResults saved to: factor_loadings_38items.csv\n")

# Model fit statistics
fit_stats <- list(
  Chi_square = efa_result$STATISTIC,
  df = efa_result$dof,
  p_value = efa_result$PVAL,
  TLI = efa_result$TLI,
  RMSEA = efa_result$RMSEA[1],
  BIC = efa_result$BIC
)

cat("\n=== Model Fit Statistics ===\n")
print(fit_stats)

cat("\n✅ Analysis completed successfully with all 38 items including Item 26!\n") 