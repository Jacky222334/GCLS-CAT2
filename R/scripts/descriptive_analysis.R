# Descriptive Statistics Analysis
# Deskriptive Statistiken

source("manuscript/R/apa_style_utils.R")
library(tidyverse)
library(psych)

#' Calculate Descriptive Statistics
#' @param data The prepared dataset
#' @return List containing descriptive statistics and APA formatted tables
calculate_descriptives <- function(data) {
  # Basic descriptives
  basic_stats <- describe(data)
  
  # Create APA formatted table
  descriptives_df <- data.frame(
    Variable = rownames(basic_stats),
    Mean = round(basic_stats$mean, 2),
    SD = round(basic_stats$sd, 2),
    Min = round(basic_stats$min, 2),
    Max = round(basic_stats$max, 2),
    Skew = round(basic_stats$skew, 2),
    Kurtosis = round(basic_stats$kurtosis, 2)
  )
  
  # Create APA table
  apa_table <- create_apa_table(
    data = descriptives_df,
    caption = "Table 1. Descriptive Statistics for GCLS Items",
    note = "Note. SD = Standard Deviation. Acceptable ranges for skewness and kurtosis are between -2 and +2."
  )
  
  # Demographics summary (if available)
  # TODO: Add demographics summary
  
  # Return results
  return(list(
    descriptives_table = apa_table,
    raw_stats = basic_stats
  ))
}

# Example usage:
# results <- calculate_descriptives(your_data) 