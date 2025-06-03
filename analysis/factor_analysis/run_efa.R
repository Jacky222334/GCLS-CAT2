# Load required packages
library(psych)
library(lavaan)
library(semTools)
library(tidyverse)
library(readxl)
source("analysis/factor_analysis/visualize_efa.R")

# Create output directories if they don't exist
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# Read and prepare data
data <- read_excel("/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_EFA_26.xlsx")

# Convert to numeric matrix for EFA
data_matrix <- as.matrix(data)
mode(data_matrix) <- "numeric"

# Run EFA
efa_results <- fa(data_matrix, 
                 nfactors = 7,
                 rotate = "oblimin",
                 fm = "ml",  # Maximum Likelihood
                 scores = TRUE)

# Get rotated loadings
loadings <- efa_results$loadings

# Create and save heatmap
pdf("output/figures/efa_heatmap_dendrogram.pdf", width = 12, height = 10)
ht <- visualize_efa_results(loadings)
dev.off()

# Create and save separate dendrogram
pdf("output/figures/item_clustering_dendrogram.pdf", width = 10, height = 12)
plot_item_dendrogram(loadings)
dev.off()

# Calculate and print factor correlations
print("Factor Correlations:")
print(efa_results$r.scores)  # Korrelationen zwischen den Faktoren

# Calculate explained variance
print("Explained Variance:")
print(efa_results$values)  # Eigenwerte
print(efa_results$Vaccounted)  # Varianzaufklärung

# Calculate fit indices
print("Fit Indices:")
print(efa_results$STATISTIC)  # Chi-square
print(efa_results$RMSEA)      # RMSEA
print(efa_results$TLI)        # Tucker-Lewis Index

# Save detailed results
sink("output/efa_results_detailed.txt")
print("EFA Results Summary")
print("===================")
print("\nFactor Loadings:")
print(loadings)
print("\nFactor Correlations:")
print(efa_results$r.scores)
print("\nEigenvalues:")
print(efa_results$values)
print("\nVariance Accounted For:")
print(efa_results$Vaccounted)
print("\nFit Indices:")
print(efa_results$STATISTIC)
print(efa_results$RMSEA)
print(efa_results$TLI)
sink()

# Optional: Calculate and save factor scores
factor_scores <- efa_results$scores
write.csv(factor_scores, "output/factor_scores.csv") 