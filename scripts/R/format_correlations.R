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

# Add SF-12, ZUF-8, and WHOQOL-BREF scores
gcls_scores$"SF-12 PCS" <- other_data$pcs12
gcls_scores$"SF-12 MCS" <- other_data$mcs12
gcls_scores$"ZUF-8" <- other_data$zuf_score

# Add WHOQOL-BREF domains
gcls_scores$"WHOQOL Physical" <- other_data$phys
gcls_scores$"WHOQOL Psychological" <- other_data$psych
gcls_scores$"WHOQOL Social" <- other_data$social
gcls_scores$"WHOQOL Environmental" <- other_data$envir

# Calculate descriptive statistics
stats <- data.frame(
  Scale = names(gcls_scores),
  M = sapply(gcls_scores, mean, na.rm = TRUE),
  SD = sapply(gcls_scores, sd, na.rm = TRUE),
  Range = sapply(gcls_scores, function(x) paste0(round(min(x, na.rm = TRUE), 1), "-", round(max(x, na.rm = TRUE), 1)))
)

# Calculate correlation matrix
cor_matrix <- cor(gcls_scores, method = "spearman", use = "pairwise.complete.obs")

# Function to calculate p-values for correlations
cor_test_p <- function(x, y) {
  test <- cor.test(x, y, method = "spearman", use = "pairwise.complete.obs")
  return(test$p.value)
}

# Calculate p-value matrix
n_vars <- ncol(gcls_scores)
p_matrix <- matrix(NA, n_vars, n_vars)
for(i in 1:n_vars) {
  for(j in 1:n_vars) {
    if(i != j) {
      p_matrix[i,j] <- cor_test_p(gcls_scores[,i], gcls_scores[,j])
    }
  }
}

# Format correlations with significance stars based on p-values
format_correlation_with_p <- function(r, p) {
  if (is.na(r) || is.na(p)) return("—")
  if (p < 0.001) return(sprintf("%.2f***", r))
  if (p < 0.01) return(sprintf("%.2f**", r))
  if (p < 0.05) return(sprintf("%.2f*", r))
  return(sprintf("%.2f", r))
}

# Create variable labels
var_labels <- c(
  "GCLS: Psychological Functioning",
  "GCLS: Genitalia", 
  "GCLS: Social Gender Role Recognition",
  "GCLS: Physical and Emotional Intimacy",
  "GCLS: Chest",
  "GCLS: Other Secondary Sex Characteristics", 
  "GCLS: Life Satisfaction",
  "GCLS: Total Score",
  "SF-12: PCS",
  "SF-12: MCS", 
  "ZUF-8",
  "WHOQOL: Physical",
  "WHOQOL: Psychological",
  "WHOQOL: Social", 
  "WHOQOL: Environmental"
)

# Create compact correlation matrix (lower triangle only)
compact_matrix <- data.frame(
  Variable = paste0(1:n_vars, " ", var_labels),
  stringsAsFactors = FALSE
)

# Add correlation columns
for(j in 1:n_vars) {
  col_name <- as.character(j)
  compact_matrix[[col_name]] <- ""
  
  for(i in 1:n_vars) {
    if(i == j) {
      compact_matrix[i, col_name] <- "—"
    } else if(i > j) {
      compact_matrix[i, col_name] <- format_correlation_with_p(cor_matrix[i,j], p_matrix[i,j])
    } else {
      compact_matrix[i, col_name] <- ""
    }
  }
}

# Print compact table
cat("\nTable 3\n")
cat("Spearman's Rho Correlation Matrix Between GCLS, SF-12, ZUF-8, and WHOQOL-BREF (N = 293)\n\n")

# Print the table
print(kable(compact_matrix, format = "simple", align = c("l", rep("r", n_vars))))

# Print note
cat("\nNote. GCLS = Gender Congruence and Life Satisfaction Scale; SF-12 = Short Form Health Survey;\n")
cat("ZUF-8 = Client Satisfaction Questionnaire; WHOQOL-BREF = World Health Organization Quality of Life-Brief.\n")
cat("* p < .05. ** p < .01. *** p < .001.\n")

# Create processed directory if it doesn't exist
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)

# Save table to file
write.csv(compact_matrix, "data/processed/correlation_table_apa.csv", row.names = FALSE) 