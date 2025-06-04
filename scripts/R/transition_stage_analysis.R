# Transition Stage Analysis - Replicating Jones et al. (2019) Table 6
# Compare GCLS scores across different transition stages

library(tidyverse)
library(readxl)
library(knitr)

# Read data
raw_data <- read_excel("data/raw/deutsch_data_numeric_unreversed.xlsx")
other_data <- read_excel("data/raw/raw_quest_all.xlsx")
intervention_data <- read_excel("data/raw/raw_transspezifische_eng.xlsx")

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

# Calculate GCLS subscale scores
gcls_scores <- data.frame(row.names = 1:nrow(raw_data))

for (name in names(subscales)) {
  items <- subscales[[name]]
  gcls_scores[[name]] <- rowMeans(raw_data[items], na.rm = TRUE)
}

# Add total score
all_items <- unlist(subscales)
all_items <- all_items[all_items != "I26"]
gcls_scores$"Total Score" <- rowMeans(raw_data[all_items], na.rm = TRUE)

# Add cluster scores (matching original study)
# Cluster 1: Gender Congruence (body-related subscales)
cluster1_subscales <- c("Genitalia", "Chest", "Other Secondary Sex Characteristics")
gcls_scores$"Cluster 1: Gender Congruence" <- rowMeans(gcls_scores[cluster1_subscales], na.rm = TRUE)

# Cluster 2: Mental Well-being and Life Satisfaction  
cluster2_subscales <- c("Psychological Functioning", "Social Gender Role Recognition", 
                       "Physical and Emotional Intimacy", "Life Satisfaction")
gcls_scores$"Cluster 2: Mental Well-being and Life Satisfaction" <- rowMeans(gcls_scores[cluster2_subscales], na.rm = TRUE)

# Merge with intervention data
combined_data <- cbind(gcls_scores, intervention_data)

# Create transition stage groups based on medical interventions
# Similar to original study: No GAMI vs CHT + Surgery

# Focus on AFAB participants (like original study's "transgender males")
afab_data <- combined_data %>% 
  filter(`Sex assigned at birth` == "Weiblich (AFAB: Assigned Female At Birth)")

print(paste("Total AFAB participants:", nrow(afab_data)))

# Define transition stages for AFAB participants
afab_data$transition_stage <- case_when(
  # No/minimal interventions
  afab_data$THT == 0 & afab_data$CMS == 0 & afab_data$HE == 0 & afab_data$PH == 0 ~ "No GAMI",
  
  # Hormone therapy + chest surgery (matching original study)
  afab_data$THT == 1 & afab_data$CMS == 1 ~ "THT + Chest Surgery",
  
  # Hormone therapy only
  afab_data$THT == 1 & afab_data$CMS == 0 ~ "Hormone Therapy Only",
  
  # Other combinations
  TRUE ~ "Other"
)

# Check group sizes
transition_table <- table(afab_data$transition_stage)
print("AFAB Transition Stage Groups:")
print(transition_table)

# Filter for main comparison groups (like original study)
comparison_data <- afab_data %>%
  filter(transition_stage %in% c("No GAMI", "THT + Chest Surgery")) %>%
  mutate(transition_stage = factor(transition_stage, levels = c("No GAMI", "THT + Chest Surgery")))

print(paste("Participants for comparison - No GAMI:", sum(comparison_data$transition_stage == "No GAMI")))
print(paste("Participants for comparison - THT + Chest Surgery:", sum(comparison_data$transition_stage == "THT + Chest Surgery")))

# Perform Mann-Whitney U tests for each subscale (matching original study)
subscale_names <- c(names(subscales), "Total Score", 
                   "Cluster 1: Gender Congruence", "Cluster 2: Mental Well-being and Life Satisfaction")

results <- data.frame(
  Subscale = subscale_names,
  No_GAMI_n = numeric(length(subscale_names)),
  No_GAMI_M = numeric(length(subscale_names)),
  No_GAMI_SD = numeric(length(subscale_names)),
  THT_Chest_n = numeric(length(subscale_names)),
  THT_Chest_M = numeric(length(subscale_names)),
  THT_Chest_SD = numeric(length(subscale_names)),
  U = numeric(length(subscale_names)),
  Z = numeric(length(subscale_names)),
  p_value = numeric(length(subscale_names)),
  effect_size = numeric(length(subscale_names))
)

for (i in 1:length(subscale_names)) {
  subscale <- subscale_names[i]
  
  # Get data for each group
  no_gami_scores <- comparison_data[comparison_data$transition_stage == "No GAMI", subscale]
  tht_chest_scores <- comparison_data[comparison_data$transition_stage == "THT + Chest Surgery", subscale]
  
  # Remove missing values
  no_gami_scores <- no_gami_scores[!is.na(no_gami_scores)]
  tht_chest_scores <- tht_chest_scores[!is.na(tht_chest_scores)]
  
  # Calculate descriptive statistics
  results[i, "No_GAMI_n"] <- length(no_gami_scores)
  results[i, "No_GAMI_M"] <- mean(no_gami_scores)
  results[i, "No_GAMI_SD"] <- sd(no_gami_scores)
  results[i, "THT_Chest_n"] <- length(tht_chest_scores)
  results[i, "THT_Chest_M"] <- mean(tht_chest_scores)
  results[i, "THT_Chest_SD"] <- sd(tht_chest_scores)
  
  # Perform Mann-Whitney U test
  if(length(no_gami_scores) > 0 & length(tht_chest_scores) > 0) {
    test_result <- wilcox.test(no_gami_scores, tht_chest_scores, alternative = "two.sided")
    
    # Calculate effect size (r = Z / sqrt(N))
    n_total <- length(no_gami_scores) + length(tht_chest_scores)
    z_score <- qnorm(test_result$p.value/2)
    effect_size <- abs(z_score) / sqrt(n_total)
    
    # Store results
    results[i, "U"] <- test_result$statistic
    results[i, "Z"] <- z_score
    results[i, "p_value"] <- test_result$p.value
    results[i, "effect_size"] <- effect_size
  }
}

# Create formatted table matching original study format
formatted_table <- data.frame(
  Subscale = results$Subscale,
  "No GAMI" = sprintf("%.2f (%.2f)", results$No_GAMI_M, results$No_GAMI_SD),
  "THT + Chest Surgery" = sprintf("%.2f (%.2f)", results$THT_Chest_M, results$THT_Chest_SD),
  "Mann-Whitney U" = sprintf("%.2f", results$U),
  "Z" = sprintf("%.2f", results$Z),
  "Effect Size (r)" = sprintf("%.2f", results$effect_size),
  "p" = ifelse(results$p_value < .001, "<.001", 
               ifelse(results$p_value < .01, sprintf("%.3f", results$p_value),
                     sprintf("%.3f", results$p_value)))
)

# Print results
cat("\nTable 6 (Replication)\n")
cat("Mann-Whitney U Test Scores for AFAB Participants: No GAMI vs THT + Chest Surgery\n\n")

print(kable(formatted_table, format = "simple", align = c("l", "r", "r", "r", "r", "r", "r")))

cat(sprintf("\nNote. GAMI = Gender Affirming Medical Intervention; THT = Testosterone Hormone Therapy.\n"))
cat(sprintf("No GAMI group: n = %d; THT + Chest Surgery group: n = %d.\n", 
           results$No_GAMI_n[1], results$THT_Chest_n[1]))
cat("Values are M (SD). Effect sizes calculated as r = |Z|/√N.\n")
cat("Lower scores indicate better gender congruence and life satisfaction.\n")

# Save results
write.csv(formatted_table, "data/processed/transition_stage_comparison.csv", row.names = FALSE)
cat("\nResults saved to: data/processed/transition_stage_comparison.csv\n")

# Additional analysis: All transition stages
cat("\n\nAdditional Analysis: All Transition Stages (AFAB participants)\n")
cat("================================================================\n")

stage_summary <- afab_data %>%
  group_by(transition_stage) %>%
  summarise(
    n = n(),
    GCLS_Total_M = mean(`Total Score`, na.rm = TRUE),
    GCLS_Total_SD = sd(`Total Score`, na.rm = TRUE),
    .groups = "drop"
  )

print(stage_summary)

# Plot comparison if groups are large enough
if(sum(comparison_data$transition_stage == "No GAMI") >= 10 & 
   sum(comparison_data$transition_stage == "THT + Chest Surgery") >= 10) {
  
  cat("\nGenerating comparison plot...\n")
  
  # Create comparison plot
  library(ggplot2)
  
  plot_data <- comparison_data %>%
    select(transition_stage, all_of(subscale_names[1:7])) %>%
    pivot_longer(cols = -transition_stage, names_to = "Subscale", values_to = "Score")
  
  p <- ggplot(plot_data, aes(x = Subscale, y = Score, fill = transition_stage)) +
    geom_boxplot() +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = "GCLS Subscale Scores by Transition Stage (AFAB Participants)",
         y = "GCLS Score",
         fill = "Transition Stage") +
    scale_fill_manual(values = c("lightblue", "lightcoral"))
  
  ggsave("figures/transition_stage_comparison.pdf", p, width = 12, height = 8)
  cat("Plot saved to: figures/transition_stage_comparison.pdf\n")
} 