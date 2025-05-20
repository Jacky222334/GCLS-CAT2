# EFA Prerequisites Analysis
# This script checks EFA assumptions and requirements

# Load required packages and utilities
source("manuscript/R/apa_style_utils.R")
library(psych)
library(tidyverse)

#' Check Prerequisites for Exploratory Factor Analysis
#' 
#' @description
#' Performs comprehensive checks for EFA prerequisites including:
#' - Sample size adequacy
#' - KMO test (Kaiser-Meyer-Olkin criterion)
#' - Bartlett's test of sphericity
#' - Correlation matrix analysis
#'
#' @param data Dataframe containing the variables for factor analysis
#' @return List containing all test results and APA formatted tables/figures
check_efa_prerequisites <- function(data) {
  # 1. Sample Size Check
  n <- nrow(data)
  k <- ncol(data)
  subject_item_ratio <- n/k
  
  # 2. KMO Test for sampling adequacy
  kmo_result <- KMO(cor(data))
  
  # 3. Bartlett's Test of sphericity
  bartlett_result <- cortest.bartlett(cor(data), n=n)
  
  # 4. Correlation Matrix Analysis
  correlation_matrix <- cor(data)
  
  # Create summary table in APA format
  summary_df <- data.frame(
    Criterion = c("Sample Size", "Variables", "Subject-to-Item Ratio", 
                 "KMO Overall", "Bartlett's χ²", "Bartlett's p-value"),
    Value = c(n, k, round(subject_item_ratio, 2),
              round(kmo_result$MSA, 3),
              round(bartlett_result$chisq, 2),
              format_p_value(bartlett_result$p.value))
  )
  
  # Create APA table with interpretation notes
  apa_summary_table <- create_apa_table(
    data = summary_df,
    caption = "Table 1. Prerequisites for Exploratory Factor Analysis",
    note = paste("Note. KMO values > .80 indicate good sampling adequacy.",
                format_p_value(bartlett_result$p.value),
                "for Bartlett's test suggests appropriate correlation structure.")
  )
  
  # Create correlation matrix plot in APA style
  create_correlation_matrix(
    data = data,
    filename = "figures/correlation_matrix.png",
    vars = names(data)
  )
  
  # Create detailed KMO results table
  kmo_df <- data.frame(
    Variable = names(data),
    KMO = round(kmo_result$MSAi, 3)
  )
  
  apa_kmo_table <- create_apa_table(
    data = kmo_df,
    caption = "Table 2. KMO Values for Individual Variables",
    note = "Note. KMO values > .80 indicate good sampling adequacy for individual variables."
  )
  
  # Return results as list with APA formatted components
  return(list(
    summary_table = apa_summary_table,
    kmo_table = apa_kmo_table,
    sample_size = n,
    variables = k,
    subject_item_ratio = subject_item_ratio,
    kmo = kmo_result,
    bartlett = bartlett_result,
    correlation_matrix = correlation_matrix
  ))
}

# Example usage:
# print(results$summary_table)  # Displays APA formatted summary table
# print(results$kmo_table)     # Displays APA formatted KMO table 