# APA Style Utilities for G-GCLS Analysis
# This file contains functions for consistent APA-style formatting of tables and figures

library(ggplot2)
library(knitr)
library(kableExtra)
library(papaja)

# Global APA style settings
apa_style <- list(
  font_family = "Times New Roman",
  base_size = 12,
  title_size = 14,
  caption_size = 10
)

#' Format p-values according to APA style
#' @param p Numeric p-value
#' @return Formatted string
format_p_value <- function(p) {
  if (is.na(p)) return("NA")
  if (p < .001) return("< .001")
  if (p >= .001) return(sprintf("= %.3f", p))
}

#' Format statistical values according to APA style
#' @param stat Statistic value
#' @param digits Number of decimal places
#' @return Formatted string
format_statistic <- function(stat, digits = 2) {
  if (is.na(stat)) return("NA")
  sprintf(paste0("%.", digits, "f"), stat)
}

#' Create APA-styled ggplot theme
#' @return ggplot theme object
theme_apa <- function() {
  theme_minimal() +
    theme(
      text = element_text(family = apa_style$font_family),
      plot.title = element_text(size = apa_style$title_size, hjust = 0.5),
      plot.caption = element_text(size = apa_style$caption_size),
      axis.title = element_text(size = apa_style$base_size),
      axis.text = element_text(size = apa_style$base_size)
    )
}

#' Format table in APA style
#' @param df Data frame to format
#' @param caption Table caption
#' @param note Table note (optional)
#' @return Formatted kable object
format_apa_table <- function(df, caption, note = NULL) {
  formatted_table <- kable(df, 
                          caption = caption,
                          format = "latex",
                          booktabs = TRUE) %>%
    kable_styling(font_size = apa_style$base_size,
                 latex_options = c("hold_position"))
  
  if (!is.null(note)) {
    formatted_table <- formatted_table %>%
      footnote(general = note,
              general_title = "Note.",
              footnote_as_chunk = TRUE)
  }
  
  return(formatted_table)
}

#' Format figure caption in APA style
#' @param caption Main caption text
#' @param note Additional note (optional)
#' @return Formatted caption string
format_figure_caption <- function(caption, note = NULL) {
  if (is.null(note)) {
    return(caption)
  } else {
    return(paste0(caption, ". Note. ", note))
  }
} 