# Factor Analysis
# Faktorenanalyse

source("manuscript/R/apa_style_utils.R")
library(tidyverse)
library(psych)
library(lavaan)
library(semPlot)

#' Perform Factor Analysis
#' @param data The prepared dataset
#' @return List containing factor analysis results and APA formatted tables/figures
perform_factor_analysis <- function(data) {
  # Perform EFA
  efa_result <- fa(data, 
                   nfactors = 7,  # Based on original GCLS
                   rotate = "varimax",
                   fm = "ml")
  
  # Create factor loadings table
  loadings_df <- data.frame(
    Item = rownames(efa_result$loadings),
    round(as.data.frame(efa_result$loadings), 3)
  )
  
  # Format loadings table in APA style
  apa_loadings_table <- create_apa_table(
    data = loadings_df,
    caption = "Table 3. Factor Loadings for Exploratory Factor Analysis",
    note = "Note. Factor loadings < .30 are suppressed. Extraction method: Maximum Likelihood. Rotation: Varimax."
  )
  
  # Create scree plot
  create_apa_figure(
    plot_function = function() {
      scree(efa_result$values, 
            main = "Scree Plot",
            xlab = "Factor Number",
            ylab = "Eigenvalue")
    },
    filename = "output/figures/scree_plot.png",
    caption = "Figure 2. Scree Plot of Eigenvalues"
  )
  
  # Perform CFA (if model is specified)
  # TODO: Add CFA code
  
  # Create path diagram
  # TODO: Add path diagram code
  
  # Return results
  return(list(
    loadings_table = apa_loadings_table,
    efa_results = efa_result
    # Add CFA results when implemented
  ))
}

#' Create Path Diagram
#' @param model Fitted CFA model
create_path_diagram <- function(model) {
  create_apa_figure(
    plot_function = function() {
      semPaths(model,
              what = "est",
              fade = FALSE,
              residuals = FALSE,
              intercepts = FALSE,
              edge.label.cex = 0.6,
              edge.color = "black")
    },
    filename = "output/figures/path_diagram.png",
    caption = "Figure 3. Confirmatory Factor Analysis Path Diagram"
  )
}

# Example usage:
# results <- perform_factor_analysis(your_data) 