# Script to calculate score statistics by group
library(readxl)
library(tidyverse)

# Read the data
data <- read_excel("data/raw/raw_quest_all.xlsx")

# Function to format mean and SD
format_mean_sd <- function(mean, sd) {
  sprintf("%.1f (%.1f)", mean, sd)
}

# Function to perform t-test and format results
perform_ttest <- function(data, var, group_var) {
  # Remove Intersex group and NA values
  test_data <- data %>%
    filter(!is.na(!!sym(var))) %>%
    filter(!!sym(group_var) %in% c("Männlich (AMAB: Assigned Male At Birth)", 
                                  "Weiblich (AFAB: Assigned Female At Birth)"))
  
  # Perform t-test
  t_result <- t.test(as.formula(paste(var, "~", group_var)), data = test_data)
  
  # Format results
  sprintf("t(%d) = %.2f, p = %.3f", 
          round(t_result$parameter),
          t_result$statistic,
          t_result$p.value)
}

# Calculate statistics by group and add test statistics
variables <- c(
  "pcs12", "mcs12", "zuf_score",
  "phys", "psych", "social", "envir", "global"
)

group_var <- "@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen"

# Calculate descriptive statistics
score_stats <- data %>%
  group_by(!!sym(group_var)) %>%
  summarise(across(all_of(variables), 
    list(
      range = ~sprintf("%.1f-%.1f", min(., na.rm = TRUE), max(., na.rm = TRUE)),
      mean_sd = ~format_mean_sd(mean(., na.rm = TRUE), sd(., na.rm = TRUE))
    )
  ), .groups = "drop")

# Calculate test statistics
test_stats <- map_chr(variables, ~perform_ttest(data, .x, group_var))
names(test_stats) <- variables

# Print results
cat("\nDescriptive Statistics:\n")
print(score_stats, width = Inf)

cat("\nTest Statistics (AMAB vs AFAB):\n")
for(i in seq_along(test_stats)) {
  cat(sprintf("%s: %s\n", names(test_stats)[i], test_stats[i]))
} 