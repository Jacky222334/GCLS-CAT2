# Reliability and Validity Analysis
# Reliabilitäts- und Validitätsanalyse

source("manuscript/R/apa_style_utils.R")
library(tidyverse)
library(psych)

#' Assess Reliability
#' @param data The prepared dataset
#' @return List containing reliability results and APA formatted tables
assess_reliability <- function(data) {
  # Calculate Cronbach's alpha for each subscale
  # TODO: Define subscales based on factor analysis
  subscales <- list(
    GEN = c("gen1", "gen2", "gen3", "gen4", "gen5", "gen6"),
    CH = c("ch1", "ch2", "ch3", "ch4"),
    SSC = c("ssc1", "ssc2", "ssc3"),
    SGR = c("sgr1", "sgr2", "sgr3", "sgr4"),
    PEI = c("pei1", "pei2", "pei3", "pei4"),
    PF = c("pf1", "pf2", "pf3", "pf4", "pf5", "pf6", "pf7", "pf8", "pf9", "pf10"),
    LS = c("ls1", "ls2", "ls3", "ls4", "ls5", "ls6", "ls7")
  )
  
  # Calculate reliability for each subscale
  reliability_results <- lapply(subscales, function(items) {
    alpha_result <- psych::alpha(data[items])
    return(c(
      alpha = alpha_result$total$raw_alpha,
      ci_lower = alpha_result$total$raw_alpha - 1.96 * alpha_result$total$ase,
      ci_upper = alpha_result$total$raw_alpha + 1.96 * alpha_result$total$ase
    ))
  })
  
  # Create reliability table
  reliability_df <- data.frame(
    Subscale = names(subscales),
    Items = sapply(subscales, length),
    Alpha = sapply(reliability_results, function(x) round(x["alpha"], 3)),
    CI_Lower = sapply(reliability_results, function(x) round(x["ci_lower"], 3)),
    CI_Upper = sapply(reliability_results, function(x) round(x["ci_upper"], 3))
  )
  
  # Format table in APA style
  apa_reliability_table <- create_apa_table(
    data = reliability_df,
    caption = "Table 4. Internal Consistency Reliability of GCLS Subscales",
    note = "Note. CI = 95% Confidence Interval."
  )
  
  return(list(
    reliability_table = apa_reliability_table,
    raw_results = reliability_results
  ))
}

#' Assess Validity
#' @param data The prepared dataset
#' @return List containing validity results and APA formatted tables
assess_validity <- function(data) {
  # Calculate correlations between subscales
  # TODO: Update with actual subscale scores
  subscale_scores <- data.frame(
    # Calculate subscale scores here
  )
  
  # Calculate correlation matrix
  cor_matrix <- cor(subscale_scores, use = "pairwise.complete.obs")
  
  # Create correlation table
  cor_df <- as.data.frame(cor_matrix)
  cor_df$Subscale <- rownames(cor_df)
  cor_df <- cor_df[, c("Subscale", colnames(cor_matrix))]
  
  # Format correlation table in APA style
  apa_correlation_table <- create_apa_table(
    data = cor_df,
    caption = "Table 5. Inter-correlations Between GCLS Subscales",
    note = "Note. All correlations significant at p < .001 unless otherwise noted."
  )
  
  # Create correlation plot
  create_correlation_matrix(
    data = subscale_scores,
    filename = "output/figures/subscale_correlations.png"
  )
  
  return(list(
    correlation_table = apa_correlation_table,
    raw_correlations = cor_matrix
  ))
}

# Example usage:
# reliability_results <- assess_reliability(your_data)
# validity_results <- assess_validity(your_data) 