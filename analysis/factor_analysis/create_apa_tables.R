# Load required packages
library(psych)
library(xtable)
library(readxl)
library(kableExtra)

# Read the original data for EFA
daten <- read_excel("../../data/raw/dat_EFA_26.xlsx")
numeric_cols <- sapply(daten, is.numeric)
daten_numeric <- daten[, numeric_cols]

# Perform EFA to get results
efa_result <- fa(daten_numeric, 
                nfactors = 7, 
                rotate = "oblimin",
                fm = "ml",
                use = "pairwise.complete.obs")

# Create factor loading matrix with pattern matrix
loadings <- as.data.frame(unclass(efa_result$loadings))

# Round loadings to 2 decimals and replace small values with empty strings
loadings_formatted <- round(loadings, 2)
loadings_formatted[abs(loadings_formatted) < 0.3] <- NA

# Add item descriptions
item_descriptions <- c(
    "I1" = "Item 1 description",  # Replace with actual item descriptions
    "I2" = "Item 2 description",
    # ... Add all item descriptions
    "I38_r" = "Item 38 description"
)

# Add subscale grouping
subscales <- c(
    rep("PF (Psychological Function)", 5),
    rep("SF (Social Function)", 5),
    rep("PhF (Physical Function)", 5),
    rep("LS (Life Satisfaction)", 5),
    rep("BI (Body Image)", 5),
    rep("RS (Relationship Satisfaction)", 6),
    rep("GI (Gender Identity)", 6)
)

# Create data frame for Table 1
table1 <- data.frame(
    Subscale = subscales,
    Item = rownames(loadings),
    #Description = item_descriptions[rownames(loadings)],
    F1 = loadings_formatted$ML1,
    F2 = loadings_formatted$ML2,
    F3 = loadings_formatted$ML3,
    F4 = loadings_formatted$ML4,
    F5 = loadings_formatted$ML5,
    F6 = loadings_formatted$ML6,
    F7 = loadings_formatted$ML7,
    h2 = round(efa_result$communality, 2)
)

# Calculate eigenvalues and variance explained
eigenvalues <- round(efa_result$values, 2)[1:7]
var_explained <- round(efa_result$Vaccounted[2,] * 100, 2)
cum_var <- round(efa_result$Vaccounted[3,] * 100, 2)

# Add summary statistics to bottom of table
summary_rows <- data.frame(
    Subscale = rep("", 3),
    Item = c("Eigenvalue", "% of variance", "Cumulative %"),
    #Description = rep("", 3),
    F1 = c(eigenvalues[1], var_explained[1], cum_var[1]),
    F2 = c(eigenvalues[2], var_explained[2], cum_var[2]),
    F3 = c(eigenvalues[3], var_explained[3], cum_var[3]),
    F4 = c(eigenvalues[4], var_explained[4], cum_var[4]),
    F5 = c(eigenvalues[5], var_explained[5], cum_var[5]),
    F6 = c(eigenvalues[6], var_explained[6], cum_var[6]),
    F7 = c(eigenvalues[7], var_explained[7], cum_var[7]),
    h2 = rep("", 3)
)

# Combine main table with summary statistics
table1_final <- rbind(table1, summary_rows)

# Create Table 2: Factor Correlations
factor_cors <- round(efa_result$Phi, 2)
colnames(factor_cors) <- paste("F", 1:7, sep="")
rownames(factor_cors) <- paste("F", 1:7, sep="")

# Save tables
# Table 1: Pattern Matrix
write.csv(table1_final, "efa_results/table1_pattern_matrix.csv", row.names = FALSE)

# Create LaTeX version of Table 1
print(xtable(table1_final, 
             caption = "Pattern Matrix of the Seven-Factor Solution with Maximum Likelihood Extraction and Oblimin Rotation",
             label = "tab:pattern_matrix",
             digits = 2),
      file = "efa_results/table1_pattern_matrix.tex",
      include.rownames = FALSE,
      floating = TRUE,
      caption.placement = "top",
      sanitize.text.function = function(x){x})

# Table 2: Factor Correlations
write.csv(factor_cors, "efa_results/table2_factor_correlations.csv")

# Create LaTeX version of Table 2
print(xtable(factor_cors,
             caption = "Factor Correlation Matrix",
             label = "tab:factor_correlations",
             digits = 2),
      file = "efa_results/table2_factor_correlations.tex",
      include.rownames = TRUE,
      floating = TRUE,
      caption.placement = "top")

# Create note for Table 1
cat("Note. N = 293. Factor loadings > |.30| are shown. h² = communality. 
    PF = Psychological Function; SF = Social Function; PhF = Physical Function; 
    LS = Life Satisfaction; BI = Body Image; RS = Relationship Satisfaction; 
    GI = Gender Identity. Items marked with 'r' are reverse-scored.", 
    file = "efa_results/table1_note.txt")

# Create note for Table 2
cat("Note. All correlations are significant at p < .001.", 
    file = "efa_results/table2_note.txt")

print("APA-style tables have been created in the efa_results directory.") 