# Data Preparation Script for GCLS Validation
# Datenaufbereitungs-Skript für GCLS-Validierung

library(tidyverse)
library(haven)     # For reading SPSS/SAS files
library(mice)      # For missing data handling
library(psych)     # For item analysis

#' Load and Prepare GCLS Data
#' @param file_path Path to the raw data file
#' @param missing_handling Method for handling missing data ("listwise", "pairwise", or "imputation")
#' @return List containing prepared datasets and data quality report
load_and_prepare_data <- function(file_path, missing_handling = "listwise") {
  # Read data based on file extension
  data <- read_data(file_path)
  
  # Define GCLS subscales with item numbers
  subscales <- list(
    GEN = paste0("I", c(14, 21, 25, 26, 27, 29)),    # Genitalia
    CH = paste0("I", c(15, 18, 28, 30)),             # Chest
    SSC = paste0("I", c(17, 23, 24)),                # Secondary Sex Characteristics
    SGR = paste0("I", c(16, 19, 20, 22)),            # Social Gender Role Recognition
    PEI = paste0("I", c(3, 5, 32, 33)),              # Physical/Emotional Intimacy
    PF = paste0("I", c(1, 2, 4, 6, 7, 8, 9, 11, 12, 13)),  # Psychological Functioning
    LS = paste0("I", c(10, 31, 34, 35, 36, 37, 38))  # Life Satisfaction
  )
  
  # Define reverse-coded items
  reverse_items <- paste0("I", c(16, 20, 22, 25, 30, 31, 32, 33, 34, 36, 38))
  
  # Check data quality
  quality_report <- check_data_quality(data, subscales)
  
  # Handle missing data
  data_cleaned <- handle_missing_data(data, method = missing_handling)
  
  # Recode reverse items
  data_recoded <- recode_items(data_cleaned, reverse_items)
  
  # Calculate subscale scores
  data_with_scores <- calculate_subscale_scores(data_recoded, subscales)
  
  # Create analysis datasets
  analysis_data <- list(
    full = data_with_scores,
    items_only = select(data_with_scores, starts_with("I")),
    subscales_only = select(data_with_scores, ends_with("_score")),
    demographics = select(data_with_scores, -starts_with("I"), -ends_with("_score"))
  )
  
  # Create data quality summary table
  quality_table <- create_apa_table(
    data = data.frame(
      Criterion = c(
        "Total Sample Size",
        "Complete Cases",
        "Missing Data Rate",
        "Items with >5% Missing",
        "Range of Item Means",
        "Range of Item SDs"
      ),
      Value = c(
        nrow(data),
        sum(complete.cases(data)),
        sprintf("%.1f%%", (1 - sum(complete.cases(data))/nrow(data)) * 100),
        sum(quality_report$missing$pct_missing > 5),
        sprintf("%.2f - %.2f", min(quality_report$distributions$mean), 
                max(quality_report$distributions$mean)),
        sprintf("%.2f - %.2f", min(quality_report$distributions$sd), 
                max(quality_report$distributions$sd))
      )
    ),
    caption = "Table 1. Data Quality Summary",
    note = "Note. Complete cases have no missing values across all items."
  )
  
  return(list(
    data = analysis_data,
    quality_report = quality_report,
    quality_table = quality_table
  ))
}

#' Read Data File
#' @param file_path Path to data file
read_data <- function(file_path) {
  ext <- tools::file_ext(file_path)
  
  data <- switch(ext,
    "sav" = haven::read_sav(file_path),
    "csv" = readr::read_csv(file_path),
    "rds" = readRDS(file_path),
    "xlsx" = readxl::read_excel(file_path),
    stop("Unsupported file format")
  )
  
  return(data)
}

#' Check Data Quality
#' @param data Raw dataset
#' @param subscales List of subscale definitions
check_data_quality <- function(data, subscales) {
  # Get all GCLS items
  gcls_items <- unlist(subscales)
  
  # Check missing data
  missing_report <- data %>%
    select(all_of(gcls_items)) %>%
    summarise(across(everything(),
      list(
        n_missing = ~sum(is.na(.)),
        pct_missing = ~mean(is.na(.)) * 100
      )
    )) %>%
    gather(key, value) %>%
    separate(key, into = c("item", "stat"), sep = "_(?=[^_]+$)")
  
  # Check response distributions
  dist_report <- data %>%
    select(all_of(gcls_items)) %>%
    gather(item, value) %>%
    group_by(item) %>%
    summarise(
      mean = mean(value, na.rm = TRUE),
      sd = sd(value, na.rm = TRUE),
      skew = psych::skew(value),
      kurtosis = psych::kurtosi(value),
      min = min(value, na.rm = TRUE),
      max = max(value, na.rm = TRUE)
    )
  
  # Check for outliers
  outlier_report <- data %>%
    select(all_of(gcls_items)) %>%
    gather(item, value) %>%
    group_by(item) %>%
    summarise(
      n_outliers = sum(abs(scale(value)) > 3, na.rm = TRUE),
      pct_outliers = mean(abs(scale(value)) > 3, na.rm = TRUE) * 100
    )
  
  # Create distribution summary table
  dist_table <- create_apa_table(
    data = dist_report,
    caption = "Table 2. Item Distribution Summary",
    note = "Note. Values outside ±2 for skewness or kurtosis indicate potential non-normality."
  )
  
  return(list(
    missing = missing_report,
    distributions = dist_report,
    outliers = outlier_report,
    dist_table = dist_table
  ))
}

#' Handle Missing Data
#' @param data Dataset with missing values
#' @param method Method for handling missing data
handle_missing_data <- function(data, method = "listwise") {
  if (method == "listwise") {
    # Complete case analysis
    data_complete <- na.omit(data)
  } else if (method == "pairwise") {
    # Return as is - pairwise deletion will be handled in analyses
    data_complete <- data
  } else if (method == "imputation") {
    # Multiple imputation
    imp <- mice(data, m = 5, maxit = 50, method = "pmm", seed = 500)
    data_complete <- complete(imp, 1)  # Use first imputed dataset
  }
  
  return(data_complete)
}

#' Recode Items
#' @param data Dataset with original coding
#' @param reverse_items Vector of items to be reverse-coded
recode_items <- function(data, reverse_items) {
  # Recode reverse items (5-point scale)
  if (length(reverse_items) > 0) {
    data <- data %>%
      mutate(across(all_of(reverse_items),
        ~6 - .
      ))
  }
  
  return(data)
}

#' Calculate Subscale Scores
#' @param data Cleaned dataset
#' @param subscales List of subscale definitions
calculate_subscale_scores <- function(data, subscales) {
  # Calculate mean scores for each subscale
  for (scale_name in names(subscales)) {
    items <- subscales[[scale_name]]
    score_name <- paste0(tolower(scale_name), "_score")
    
    data[[score_name]] <- rowMeans(data[items], na.rm = TRUE)
  }
  
  # Calculate total score
  all_items <- unlist(subscales)
  data$total_score <- rowMeans(data[all_items], na.rm = TRUE)
  
  return(data)
}

# Example usage:
# results <- load_and_prepare_data("path/to/data.xlsx", missing_handling = "listwise") 