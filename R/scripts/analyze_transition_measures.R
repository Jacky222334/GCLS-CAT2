# Analysis of Transition Measures
library(readxl)
library(tidyverse)

# Read data
data <- read_excel("data/raw/rwa_demo_trans_transpez.xlsx")

# Clean column names (robust for all whitespace types)
names(data) <- gsub("\\s+", "", names(data))

# Remove intersex cases (rows 226 and 233)
data_filtered <- data %>%
  filter(`@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen` != "Intergeschlechtlich")

# Analyze individuals who identify as female
female_identified <- data_filtered %>%
  filter(`@7welchegeschlechtsidentitaetordnensiesichselbstzu` == "weiblich")

# Count exact numbers for each measure
female_measures_exact <- female_identified %>%
  summarise(
    n_total = n(),
    across(starts_with("med"), ~sum(. == 1, na.rm = TRUE))
  ) %>%
  pivot_longer(
    -n_total,
    names_to = "Measure",
    values_to = "Count"
  ) %>%
  mutate(
    Measure = case_when(
      Measure == "med1" ~ "General biomedical measures",
      Measure == "med2" ~ "Hormone therapy with estrogen",
      Measure == "med3" ~ "Testosterone blockers",
      Measure == "med4" ~ "Hormone therapy with testosterone",
      Measure == "med5" ~ "Speech therapy",
      Measure == "med6" ~ "Laser epilation",
      Measure == "med7" ~ "Facial feminization",
      Measure == "med8" ~ "Mastectomy",
      Measure == "med9" ~ "Breast augmentation",
      Measure == "med10" ~ "Hysterectomy",
      Measure == "med11" ~ "Neovaginoplastik",
      Measure == "med12" ~ "Phalloplasty",
      Measure == "med13" ~ "Vocal cord surgery",
      Measure == "med14" ~ "Adam's apple reduction",
      Measure == "med15" ~ "Other"
    ),
    Percentage = round(Count / first(n_total) * 100, 1)
  ) %>%
  arrange(desc(Count))

# Print results for female-identified individuals
cat("\nIndividuals who identify as female:\n")
cat("================================\n")
cat("Total number:", nrow(female_identified), "\n")
cat("\nBreakdown by birth sex:\n")
print(table(female_identified$birth_sex))

cat("\nExact counts and percentages of medical measures (female-identified only):\n")
cat("=================================================================\n")
print(female_measures_exact, n = nrow(female_measures_exact))

# Show details of cases with unexpected measures
cat("\nDetails of female-identified individuals with unexpected measures:\n")
cat("=============================================================\n")
unexpected_measures <- female_identified %>%
  filter(med4 == 1 | med8 == 1 | med10 == 1 | med12 == 1) %>%
  select(
    birth_sex = `@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen`,
    med1, med2, med3, med4, med5, med6, med7, med8, med9, med10, med11, med12, med13, med14, med15
  )
print(unexpected_measures, n = nrow(unexpected_measures))

# Analyze AFAB cases not taking testosterone
afab_no_testosterone <- data_filtered %>%
  filter(`@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen` == "Weiblich (AFAB: Assigned Female At Birth)" & med4 == 0) %>%
  mutate(row_number = row_number()) %>%
  select(
    row_number,
    birth_sex = `@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen`,
    med1, med2, med3, med4, med5, med6, med7, med8, med9, med10, med11, med12, med13, med14, med15
  )

# Print AFAB cases not taking testosterone
cat("\nAFAB cases not taking testosterone (showing all medical measures):\n")
cat("=========================================================\n")
print(afab_no_testosterone, n = nrow(afab_no_testosterone))

# Define measures with correct column names
measures <- c(
  "General biomedical measures" = "med1",
  "Hormone therapy with estrogen" = "med2",
  "Testosterone blockers" = "med3",
  "Hormone therapy with testosterone" = "med4",
  "Speech therapy" = "med5",
  "Laser epilation" = "med6",
  "Facial feminization" = "med7",
  "Mastectomy" = "med8",
  "Breast augmentation" = "med9",
  "Hysterectomy" = "med10",
  "Neovaginoplastik" = "med11",
  "Phalloplasty" = "med12",
  "Vocal cord surgery" = "med13",
  "Adam's apple reduction" = "med14",
  "Other" = "med15"
)

# Define expected patterns
amab_expected <- c(
  "med2" = TRUE,  # Estrogen typically for AMAB
  "med3" = TRUE,  # Blockers typically for AMAB
  "med4" = FALSE, # Testosterone typically not for AMAB
  "med6" = TRUE,  # Laser typically for AMAB
  "med7" = TRUE,  # Facial fem typically for AMAB
  "med8" = FALSE, # Mastectomy typically not for AMAB
  "med9" = TRUE,  # Breast aug typically for AMAB
  "med10" = FALSE, # Hysterectomy not for AMAB
  "med11" = TRUE,  # Neovaginoplasty typically for AMAB
  "med12" = FALSE, # Phalloplasty not for AMAB
  "med14" = TRUE   # Adam's apple reduction typically for AMAB
)

afab_expected <- c(
  "med2" = FALSE, # Estrogen typically not for AFAB
  "med3" = FALSE, # Blockers typically not for AFAB
  "med4" = TRUE,  # Testosterone typically for AFAB
  "med6" = FALSE, # Laser typically not for AFAB
  "med7" = FALSE, # Facial fem typically not for AFAB
  "med8" = TRUE,  # Mastectomy typically for AFAB
  "med9" = FALSE, # Breast aug typically not for AFAB
  "med10" = TRUE, # Hysterectomy typically for AFAB
  "med11" = FALSE, # Neovaginoplasty not for AFAB
  "med12" = TRUE,  # Phalloplasty typically for AFAB
  "med14" = FALSE  # Adam's apple reduction typically not for AFAB
)

# Comprehensive plausibility check
plausibility_analysis <- data_filtered %>%
  mutate(
    case_number = row_number(),
    birth_sex = `@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen`
  ) %>%
  select(case_number, birth_sex, starts_with("med")) %>%
  gather(measure, value, -case_number, -birth_sex) %>%
  filter(value == 1) %>%  # Only look at measures that were taken
  mutate(
    expected = case_when(
      birth_sex == "Männlich (AMAB: Assigned Male At Birth)" & 
        measure %in% names(amab_expected)[amab_expected == TRUE] ~ "Expected",
      birth_sex == "Weiblich (AFAB: Assigned Female At Birth)" & 
        measure %in% names(afab_expected)[afab_expected == TRUE] ~ "Expected",
      TRUE ~ "Unexpected"
    )
  )

# Summarize unexpected combinations
unexpected_summary <- plausibility_analysis %>%
  filter(expected == "Unexpected") %>%
  arrange(case_number, measure)

# Print comprehensive plausibility results
cat("\nComprehensive Plausibility Analysis:\n")
cat("===================================\n")
cat("\nUnexpected combinations found:\n")
print(unexpected_summary, n = nrow(unexpected_summary))

# Count unexpected cases by birth sex
unexpected_by_sex <- unexpected_summary %>%
  group_by(birth_sex) %>%
  summarise(
    n_unexpected = n_distinct(case_number),
    unexpected_measures = n()
  )

cat("\nSummary of unexpected cases by birth sex:\n")
cat("=====================================\n")
print(unexpected_by_sex, n = nrow(unexpected_by_sex))

# Frequency analysis
frequencies <- data_filtered %>%
  summarise(
    across(
      all_of(unname(measures)),
      ~sum(. == 1, na.rm = TRUE)
    )
  ) %>%
  pivot_longer(
    everything(),
    names_to = "Variable",
    values_to = "Count"
  ) %>%
  mutate(
    Measure = names(measures)[match(Variable, measures)],
    Percentage = round(Count / nrow(data_filtered) * 100, 1)
  ) %>%
  select(Measure, Count, Percentage) %>%
  arrange(desc(Count))

# Categorization of measures
categories <- list(
  "Hormonal Measures" = measures[2:4],
  "Surgical Measures" = measures[7:14],
  "Other Measures" = measures[c(5,6,15)]
)

# Analysis by category
category_analysis <- data_filtered %>%
  summarise(
    across(
      unlist(categories),
      ~sum(. == 1, na.rm = TRUE)
    )
  ) %>%
  pivot_longer(
    everything(),
    names_to = "Variable",
    values_to = "Count"
  ) %>%
  mutate(
    Category = case_when(
      Variable %in% unname(categories[["Hormonal Measures"]]) ~ "Hormonal Measures",
      Variable %in% unname(categories[["Surgical Measures"]]) ~ "Surgical Measures",
      TRUE ~ "Other Measures"
    )
  ) %>%
  group_by(Category) %>%
  summarise(
    Total = sum(Count),
    Average = mean(Count),
    Percentage = round(mean(Count) / nrow(data_filtered) * 100, 1)
  )

# Print results
cat("\nSample size after removing intersex cases:\n")
cat("======================================\n")
cat("Total cases:", nrow(data_filtered), "\n")

cat("\nFrequency of individual measures:\n")
cat("================================\n")
print(frequencies, n = nrow(frequencies))

cat("\nSummary by category:\n")
cat("============================\n")
print(category_analysis, n = nrow(category_analysis))

# Save results
write_csv(frequencies, "data/processed/transition_measures_frequency.csv")
write_csv(category_analysis, "data/processed/transition_measures_categories.csv")
write_csv(plausibility_analysis, "data/processed/hormone_therapy_plausibility.csv")
if(nrow(unexpected_summary) > 0) {
  write_csv(unexpected_summary, "data/processed/unexpected_combinations.csv")
} 