# Create Demographic and Transition-Specific Tables
library(readxl)
library(tidyverse)
library(kableExtra)

# Load data
data <- read_excel("data/raw/rwa_demo_trans_transpez.xlsx")

# Clean and prepare data
clean_data <- data %>%
  select(
    birth_sex = `@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen`,
    age = age2,
    living_situation = `@2wieistihremomentanewohnsituation`,
    relationship = `@3wieistihrmomentanerbeziehungsstatus`,
    education = `@4wasistihrhoechsterabgeschlossenerbildungsgrad`,
    employment = `@5wieistihrederzeitigearbeitssituation`,
    gender_identity = `@7welchegeschlechtsidentitaetordnensiesichselbstzu`,
    starts_with("med")
  )

# Create demographic table by birth sex
demographic_table <- clean_data %>%
  group_by(birth_sex) %>%
  summarise(
    n = n(),
    # Age
    age_formatted = sprintf("%.1f ± %.1f", 
                          mean(age, na.rm = TRUE), 
                          sd(age, na.rm = TRUE)),
    # Living situation
    living_alone = sprintf("%.1f", 
                         sum(living_situation == "Alleine", na.rm = TRUE) / n() * 100),
    living_partner = sprintf("%.1f",
                           sum(living_situation == "Mit Partner*in/Partner*innen", na.rm = TRUE) / n() * 100),
    living_family = sprintf("%.1f",
                          sum(living_situation == "Mit Familie", na.rm = TRUE) / n() * 100),
    # Relationship status
    relationship_single = sprintf("%.1f",
                                sum(relationship == "Single", na.rm = TRUE) / n() * 100),
    relationship_partnered = sprintf("%.1f",
                                   sum(relationship == "In einer Beziehung (ohne rechtliche Grundlage)", na.rm = TRUE) / n() * 100),
    relationship_married = sprintf("%.1f",
                                 sum(relationship == "In einer Beziehung mit rechtlicher Grundlage (Ehe, eingetragene Partnerschaft)", na.rm = TRUE) / n() * 100),
    # Education
    education_university = sprintf("%.1f",
                                 sum(education == "Universität/Hochschule", na.rm = TRUE) / n() * 100),
    education_vocational = sprintf("%.1f",
                                 sum(education == "Berufslehre", na.rm = TRUE) / n() * 100),
    education_matura = sprintf("%.1f",
                             sum(education == "Matura", na.rm = TRUE) / n() * 100),
    # Employment
    employment_employed = sprintf("%.1f",
                                sum(employment == "Angestellt", na.rm = TRUE) / n() * 100),
    employment_selfemployed = sprintf("%.1f",
                                    sum(employment == "Selbstständig", na.rm = TRUE) / n() * 100),
    employment_unemployed = sprintf("%.1f",
                                  sum(employment == "Ohne Arbeit/Arbeitssuchend", na.rm = TRUE) / n() * 100)
  )

# Format demographic table
format_demographic_table <- demographic_table %>%
  mutate(
    birth_sex = case_when(
      birth_sex == "Männlich (AMAB: Assigned Male At Birth)" ~ "AMAB",
      birth_sex == "Weiblich (AFAB: Assigned Female At Birth)" ~ "AFAB",
      birth_sex == "Intergeschlechtlich" ~ "Intersex"
    )
  ) %>%
  select(
    `Sex Assigned at Birth` = birth_sex,
    `n` = n,
    `Age (M ± SD)` = age_formatted,
    `Living Alone (%)` = living_alone,
    `Living with Partner (%)` = living_partner,
    `Living with Family (%)` = living_family,
    `Single (%)` = relationship_single,
    `In Relationship (%)` = relationship_partnered,
    `Married/Registered (%)` = relationship_married,
    `University Degree (%)` = education_university,
    `Vocational Training (%)` = education_vocational,
    `High School (%)` = education_matura,
    `Employed (%)` = employment_employed,
    `Self-employed (%)` = employment_selfemployed,
    `Unemployed (%)` = employment_unemployed
  )

# Create transition measures table by birth sex
transition_table <- clean_data %>%
  group_by(birth_sex) %>%
  summarise(
    n = n(),
    hormone_therapy_e = sprintf("%.1f", sum(med2 == 1, na.rm = TRUE) / n() * 100),
    hormone_therapy_t = sprintf("%.1f", sum(med4 == 1, na.rm = TRUE) / n() * 100),
    blockers = sprintf("%.1f", sum(med3 == 1, na.rm = TRUE) / n() * 100),
    mastectomy = sprintf("%.1f", sum(med8 == 1, na.rm = TRUE) / n() * 100),
    breast_augmentation = sprintf("%.1f", sum(med9 == 1, na.rm = TRUE) / n() * 100),
    facial_fem = sprintf("%.1f", sum(med7 == 1, na.rm = TRUE) / n() * 100),
    hysterectomy = sprintf("%.1f", sum(med10 == 1, na.rm = TRUE) / n() * 100),
    neovagina = sprintf("%.1f", sum(med11 == 1, na.rm = TRUE) / n() * 100),
    phalloplasty = sprintf("%.1f", sum(med12 == 1, na.rm = TRUE) / n() * 100),
    voice_surgery = sprintf("%.1f", sum(med13 == 1, na.rm = TRUE) / n() * 100),
    adams_apple = sprintf("%.1f", sum(med14 == 1, na.rm = TRUE) / n() * 100),
    speech_therapy = sprintf("%.1f", sum(med5 == 1, na.rm = TRUE) / n() * 100),
    laser = sprintf("%.1f", sum(med6 == 1, na.rm = TRUE) / n() * 100)
  )

# Format transition table
format_transition_table <- transition_table %>%
  mutate(
    birth_sex = case_when(
      birth_sex == "Männlich (AMAB: Assigned Male At Birth)" ~ "AMAB",
      birth_sex == "Weiblich (AFAB: Assigned Female At Birth)" ~ "AFAB",
      birth_sex == "Intergeschlechtlich" ~ "Intersex"
    )
  ) %>%
  select(
    `Sex Assigned at Birth` = birth_sex,
    `n` = n,
    `Hormone Therapy - Estrogen (%)` = hormone_therapy_e,
    `Hormone Therapy - Testosterone (%)` = hormone_therapy_t,
    `Hormone Blockers (%)` = blockers,
    `Mastectomy (%)` = mastectomy,
    `Breast Augmentation (%)` = breast_augmentation,
    `Facial Feminization (%)` = facial_fem,
    `Hysterectomy (%)` = hysterectomy,
    `Neovaginoplasty (%)` = neovagina,
    `Phalloplasty (%)` = phalloplasty,
    `Voice Surgery (%)` = voice_surgery,
    `Adam's Apple Reduction (%)` = adams_apple,
    `Speech Therapy (%)` = speech_therapy,
    `Laser Epilation (%)` = laser
  )

# Save tables
write.csv(format_demographic_table, "output/tables/demographic_by_birthsex.csv", row.names = FALSE)
write.csv(format_transition_table, "output/tables/transition_by_birthsex.csv", row.names = FALSE)

# Create HTML tables with kableExtra
demographic_html <- kable(format_demographic_table, format = "html", 
                        caption = "Demographic Characteristics by Sex Assigned at Birth") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), 
                full_width = TRUE)

transition_html <- kable(format_transition_table, format = "html", 
                        caption = "Transition-Specific Measures by Sex Assigned at Birth") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), 
                full_width = TRUE)

# Save HTML tables
writeLines(demographic_html, "output/tables/demographic_by_birthsex.html")
writeLines(transition_html, "output/tables/transition_by_birthsex.html") 