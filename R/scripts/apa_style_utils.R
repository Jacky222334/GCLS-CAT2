# APA Style Utilities for R Analysis
# Core functions for APA-compliant formatting

# Load required packages
library(tidyverse)
library(kableExtra)
library(papaja)
library(gt)
library(ggplot2)
library(gridExtra)

#' APA Theme for ggplot2
#' @description Creates a consistent APA-style theme for ggplot2 graphics
create_apa_theme <- function() {
  theme_apa <- theme_minimal() +
    theme(
      text = element_text(family = "Times New Roman", size = 12),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      plot.title = element_text(size = 12, hjust = 0.5),
      plot.caption = element_text(size = 10, hjust = 0),
      legend.text = element_text(size = 10),
      legend.title = element_text(size = 10),
      panel.grid.minor = element_blank()
    )
  return(theme_apa)
}

#' Create APA Table
#' @param data Data frame to be displayed
#' @param caption Table caption
#' @param note Optional table note
#' @return A gt table object formatted according to APA style
create_apa_table <- function(data, caption, note = NULL) {
  gt_tbl <- data %>%
    gt() %>%
    tab_header(
      title = caption
    ) %>%
    opt_table_font(font = "Times New Roman") %>%
    tab_options(
      table.border.top.style = "none",
      table.border.bottom.style = "none",
      heading.title.font.size = 12,
      column_labels.font.weight = "bold",
      table.font.size = 10,
      row_group.font.weight = "bold"
    )
  
  if (!is.null(note)) {
    gt_tbl <- gt_tbl %>%
      tab_source_note(note)
  }
  
  return(gt_tbl)
}

#' Create APA Figure
#' @param plot_function Function that creates the plot
#' @param filename Output filename
#' @param caption Figure caption
#' @param width Width in inches
#' @param height Height in inches
create_apa_figure <- function(plot_function, filename, caption, width = 6, height = 6) {
  # Set up APA compatible plotting parameters
  par(family = "Times New Roman",
      mar = c(5, 4, 4, 2) + 0.1,
      cex = 0.8,
      cex.lab = 1,
      cex.axis = 0.8,
      cex.main = 1)
  
  # Create plot with proper dimensions
  png(filename, 
      width = width * 300, 
      height = height * 300, 
      res = 300,
      family = "Times New Roman")
  plot_function()
  dev.off()
  
  # Reset par
  par(par(no.readonly = TRUE))
}

#' Format Statistical Results
#' @param statistic The test statistic
#' @param p_value The p-value
#' @param df Degrees of freedom (optional)
#' @param stat_name Name of the statistic (default: "t")
format_stat_result <- function(statistic, p_value, df = NULL, stat_name = "t") {
  p_formatted <- format_p_value(p_value)
  
  if (!is.null(df)) {
    return(sprintf("%s(%s) = %.2f, %s", stat_name, df, statistic, p_formatted))
  } else {
    return(sprintf("%s = %.2f, %s", stat_name, statistic, p_formatted))
  }
}

#' Format p-values according to APA style
#' @param p The p-value to format
format_p_value <- function(p) {
  if (p < .001) {
    return("p < .001")
  } else if (p >= .001 && p < .01) {
    return(sprintf("p = .%03d", round(p * 1000)))
  } else {
    return(sprintf("p = .%02d", round(p * 100)))
  }
}

#' Format effect sizes according to APA style
#' @param es Effect size value
#' @param type Type of effect size (e.g., "d", "r", "η²")
format_effect_size <- function(es, type = "d") {
  return(sprintf("%s = %.2f", type, es))
}

#' Create APA formatted correlation matrix
#' @param data Data frame with variables to correlate
#' @param filename Output filename
#' @param vars Variables to include (optional)
create_correlation_matrix <- function(data, filename, vars = NULL) {
  if (is.null(vars)) {
    vars <- names(data)
  }
  
  cor_matrix <- cor(data[vars], use = "pairwise.complete.obs")
  
  create_apa_figure(
    plot_function = function() {
      corrplot::corrplot(cor_matrix,
                        method = "color",
                        type = "upper",
                        order = "hclust",
                        addCoef.col = "black",
                        tl.col = "black",
                        tl.srt = 45,
                        title = "Correlation Matrix",
                        mar = c(0,0,1,0))
    },
    filename = filename,
    caption = "Correlation Matrix of Study Variables"
  )
  
  return(cor_matrix)
}

# Example usage:
# source("manuscript/R/apa_style_utils.R")  # Load these utilities in other scripts 