# Analysis of Questionnaire Scores
library(tidyverse)
library(readxl)
library(effectsize)  # For Cohen's d
library(rstatix)     # For statistical tests

# Function to add significance stars
add_significance_stars <- function(p) {
  if (p < .001) return("***")
  if (p < .01) return("**")
  if (p < .05) return("*")
  if (p < .10) return("†")
  return("")
}

# Function to format p-value in APA style
format_p <- function(p) {
  if (p < .001) return("< .001")
  sprintf("= %0.3f", p)
}

# Function to perform group comparison and format results
compare_groups <- function(data, var, group_var = "@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen") {
  # Remove Intersex group and NA values
  test_data <- data %>%
    filter(!is.na(!!sym(var))) %>%
    filter(!!sym(group_var) %in% c("Männlich (AMAB: Assigned Male At Birth)", 
                                  "Weiblich (AFAB: Assigned Female At Birth)"))
  
  # Calculate descriptive statistics by group
  desc_stats <- test_data %>%
    group_by(!!sym(group_var)) %>%
    summarise(
      n = n(),
      mean = mean(!!sym(var), na.rm = TRUE),
      sd = sd(!!sym(var), na.rm = TRUE),
      min = min(!!sym(var), na.rm = TRUE),
      max = max(!!sym(var), na.rm = TRUE)
    )
  
  # Create a temporary column for the t-test to avoid formula issues with special characters
  test_data$group <- test_data[[group_var]]
  test_data$value <- test_data[[var]]
  
  # Perform Welch's t-test (doesn't assume equal variances)
  t_result <- t.test(value ~ group, data = test_data)
  
  # Calculate Cohen's d
  d <- cohens_d(data = test_data, value ~ group)
  
  # Format results
  list(
    descriptives = desc_stats,
    test_statistic = sprintf("t(%0.1f) = %0.2f", t_result$parameter, t_result$statistic),
    p_value = t_result$p.value,
    cohens_d = d$effsize,
    sig_stars = add_significance_stars(t_result$p.value)
  )
}

# Main analysis function
analyze_questionnaire_scores <- function(data_path = "data/raw/raw_quest_all.xlsx") {
  # Read data
  data <- read_excel(data_path)
  
  # List of questionnaire scores to analyze
  scores <- list(
    "SF-12 PCS" = "pcs12",
    "SF-12 MCS" = "mcs12",
    "ZUF-8" = "zuf_score",
    "WHOQOL Physical" = "phys",
    "WHOQOL Psychological" = "psych",
    "WHOQOL Social" = "social",
    "WHOQOL Environmental" = "envir",
    "WHOQOL Global" = "global"
  )
  
  # Perform analyses for each score
  results <- map(scores, ~compare_groups(data, .x))
  
  # Create results table
  table_data <- map2_dfr(names(scores), results, function(score_name, result) {
    amab_stats <- result$descriptives %>% 
      filter(!!sym("@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen") == "Männlich (AMAB: Assigned Male At Birth)") %>%
      select(n, mean, sd, min, max)
    
    afab_stats <- result$descriptives %>%
      filter(!!sym("@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen") == "Weiblich (AFAB: Assigned Female At Birth)") %>%
      select(n, mean, sd, min, max)
    
    tibble(
      Score = score_name,
      `AMAB (n=176)` = sprintf("%.1f (%.1f)", amab_stats$mean, amab_stats$sd),
      `AMAB Range` = sprintf("%.1f-%.1f", amab_stats$min, amab_stats$max),
      `AFAB (n=115)` = sprintf("%.1f (%.1f)", afab_stats$mean, afab_stats$sd),
      `AFAB Range` = sprintf("%.1f-%.1f", afab_stats$min, afab_stats$max),
      `Test Statistic` = result$test_statistic,
      `p` = format_p(result$p_value),
      `Sig.` = result$sig_stars,
      `Cohen's d` = sprintf("%.2f", result$cohens_d)
    )
  })
  
  # Save results
  write_csv(table_data, "output/questionnaire_comparisons.csv")
  
  # Create markdown table
  md_content <- "# Tabelle 3: Vergleich der Fragebogen-Scores nach zugewiesenem Geschlecht bei Geburt\n\n"
  md_content <- paste0(md_content, "| Score | AMAB (n=176) | AMAB Range | AFAB (n=115) | AFAB Range | Test Statistic | p | Sig. | Cohen's d |\n")
  md_content <- paste0(md_content, "|:------|:-------------|:-----------|:-------------|:-----------|:---------------|:--|:------|:----------|\n")
  
  for(i in 1:nrow(table_data)) {
    md_content <- paste0(md_content,
      "| ", table_data$Score[i],
      " | ", table_data$`AMAB (n=176)`[i],
      " | ", table_data$`AMAB Range`[i],
      " | ", table_data$`AFAB (n=115)`[i],
      " | ", table_data$`AFAB Range`[i],
      " | ", table_data$`Test Statistic`[i],
      " | ", table_data$p[i],
      " | ", table_data$Sig.[i],
      " | ", table_data$`Cohen's d`[i],
      " |\n"
    )
  }
  
  md_content <- paste0(md_content, "\n_Anmerkung._ Werte sind als M (SD) dargestellt. AMAB = Assigned Male at Birth (bei Geburt männlich zugewiesen); AFAB = Assigned Female at Birth (bei Geburt weiblich zugewiesen); SF-12 = Short Form Health Survey-12; PCS = Physical Component Score; MCS = Mental Component Score; ZUF-8 = Client Satisfaction Questionnaire-8; WHOQOL-BREF = World Health Organization Quality of Life Assessment-Brief Version. Cohen's d: 0.20 = kleiner Effekt, 0.50 = mittlerer Effekt, 0.80 = großer Effekt. Signifikanzniveaus: *** p < .001, ** p < .01, * p < .05, † p < .10")
  
  # Save markdown table
  writeLines(md_content, "manuscript/tables/questionnaire_comparisons.md")
  
  return(table_data)
}

# Run the analysis
results <- analyze_questionnaire_scores()
print("Analyse abgeschlossen. Ergebnisse wurden in output/questionnaire_comparisons.csv und manuscript/tables/questionnaire_comparisons.md gespeichert.") 