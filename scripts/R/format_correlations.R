# Load required libraries
library(tidyverse)
library(readxl)
library(knitr)
library(kableExtra)

# Read data
raw_data <- read_excel("data/raw/deutsch_data_numeric_unreversed.xlsx")
other_data <- read_excel("data/raw/raw_quest_all.xlsx")

# Define GCLS subscales
subscales <- list(
  "Psychological Functioning" = c("I1", "I2", "I4", "I6", "I7", "I8", "I9", "I11", "I12", "I13"),
  "Genitalia" = c("I14", "I21", "I25", "I26", "I27", "I29"),
  "Social Gender Role Recognition" = c("I16", "I19", "I20", "I22"),
  "Physical and Emotional Intimacy" = c("I3", "I5", "I32", "I33"),
  "Chest" = c("I15", "I18", "I28", "I30"),
  "Other Secondary Sex Characteristics" = c("I17", "I23", "I24"),
  "Life Satisfaction" = c("I10", "I31", "I34", "I35", "I36", "I37", "I38")
)

# Initialize gcls_scores with the first subscale
first_scale <- names(subscales)[1]
first_items <- subscales[[first_scale]]
gcls_scores <- data.frame(
  rowMeans(raw_data[first_items], na.rm = TRUE)
)
names(gcls_scores) <- first_scale

# Add remaining subscales
for (name in names(subscales)[-1]) {
  items <- subscales[[name]]
  gcls_scores[[name]] <- rowMeans(raw_data[items], na.rm = TRUE)
}

# Add total score (excluding item 26)
all_items <- unlist(subscales)
all_items <- all_items[all_items != "I26"]
gcls_scores$"Total Score" <- rowMeans(raw_data[all_items], na.rm = TRUE)

# Add SF-12 and ZUF-8 scores
gcls_scores$"SF-12 PCS" <- other_data$pcs12
gcls_scores$"SF-12 MCS" <- other_data$mcs12
gcls_scores$"ZUF-8" <- other_data$zuf_score

# Calculate descriptive statistics
stats <- data.frame(
  Scale = names(gcls_scores),
  M = sapply(gcls_scores, mean, na.rm = TRUE),
  SD = sapply(gcls_scores, sd, na.rm = TRUE),
  Range = sapply(gcls_scores, function(x) paste0(round(min(x, na.rm = TRUE), 1), "-", round(max(x, na.rm = TRUE), 1)))
)

# Calculate correlation matrix
cor_matrix <- cor(gcls_scores, method = "spearman", use = "pairwise.complete.obs")

# Format correlations with significance stars
format_correlation <- function(x) {
  if (is.na(x)) return("-")
  if (abs(x) >= 0.4) return(sprintf("%.2f**", x))
  if (abs(x) >= 0.3) return(sprintf("%.2f*", x))
  return(sprintf("%.2f", x))
}

# Create formatted matrix
formatted_matrix <- matrix("", nrow = nrow(cor_matrix), ncol = ncol(cor_matrix))
for (i in 1:nrow(cor_matrix)) {
  for (j in 1:ncol(cor_matrix)) {
    if (i <= j) {
      formatted_matrix[i,j] <- format_correlation(cor_matrix[i,j])
    }
  }
}

# Create final table
final_table <- data.frame(
  Scale = stats$Scale,
  "M (SD)" = sprintf("%.2f (%.2f)", stats$M, stats$SD),
  Range = stats$Range,
  matrix(formatted_matrix, nrow = nrow(stats))
)

# Rename columns
colnames(final_table)[4:14] <- paste0(1:11)

# Print table in APA format
cat("\nTable 3\n")
cat("Spearman's Rho Correlations Between G-GCLS, SF-12, and ZUF-8 (N = 293)\n")
cat(paste(rep("=", 120), collapse = ""), "\n\n")

# Print table
print(kable(final_table, format = "simple", align = c("l", "r", "r", rep("r", 11))))

# Print note
cat("\nNote. All correlations significant at p < .001. Lower G-GCLS scores indicate better outcomes.\n")
cat("Higher SF-12 and ZUF-8 scores indicate better outcomes. PCS = Physical Component Score;\n")
cat("MCS = Mental Component Score.\n\n")
cat("* p < .05\n")
cat("** p < .001\n")

# Create processed directory if it doesn't exist
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)

# Save table to file
write.csv(final_table, "data/processed/correlation_table_apa.csv", row.names = FALSE) 