# Comprehensive Analysis Table
library(readxl)
library(tidyverse)

# Load data
data <- read_excel("data/raw/rwa_demo_trans_transpez.xlsx")

# Clean and prepare data
clean_data <- data %>%
  select(
    # Demographic variables
    birth_sex = `@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen`,
    age = age2,
    living_situation = `@2wieistihremomentanewohnsituation`,
    relationship = `@3wieistihrmomentanerbeziehungsstatus`,
    education = `@4wasistihrhoechsterabgeschlossenerbildungsgrad`,
    employment = `@5wieistihrederzeitigearbeitssituation`,
    
    # Trans-specific variables
    gender_identity = `@7welchegeschlechtsidentitaetordnensiesichselbstzu`,
    inner_co_age = inwelchemalterhattensieihrinnerescomingout,
    outer_co_age = inwelchemalterhattensieihraeusserescomingout,
    
    # Transition-specific variables (medical measures)
    starts_with("med")
  )

# Create comprehensive table by birth sex
comprehensive_table <- clean_data %>%
  group_by(birth_sex) %>%
  summarise(
    n = n(),
    
    # DEMOGRAPHIC CHARACTERISTICS
    # Age
    age_formatted = sprintf("%.1f ± %.1f", mean(age, na.rm = TRUE), sd(age, na.rm = TRUE)),
    
    # Living situation
    living_alone = sprintf("%.1f", sum(living_situation == "Alleine", na.rm = TRUE) / n() * 100),
    living_partner = sprintf("%.1f", sum(living_situation == "Mit Partner*in/Partner*innen", na.rm = TRUE) / n() * 100),
    living_family = sprintf("%.1f", sum(living_situation == "Mit Familie", na.rm = TRUE) / n() * 100),
    
    # Education
    education_university = sprintf("%.1f", sum(education == "Universität/Hochschule", na.rm = TRUE) / n() * 100),
    education_vocational = sprintf("%.1f", sum(education == "Berufslehre", na.rm = TRUE) / n() * 100),
    
    # Employment
    employment_employed = sprintf("%.1f", sum(employment == "Angestellt", na.rm = TRUE) / n() * 100),
    employment_unemployed = sprintf("%.1f", sum(employment == "Ohne Arbeit/Arbeitssuchend", na.rm = TRUE) / n() * 100),
    
    # TRANS-SPECIFIC CHARACTERISTICS
    # Coming out ages
    inner_co_age_mean = sprintf("%.1f ± %.1f", mean(inner_co_age, na.rm = TRUE), sd(inner_co_age, na.rm = TRUE)),
    outer_co_age_mean = sprintf("%.1f ± %.1f", mean(outer_co_age, na.rm = TRUE), sd(outer_co_age, na.rm = TRUE)),
    
    # Gender identity distribution
    identity_female = sprintf("%.1f", sum(gender_identity == "weiblich", na.rm = TRUE) / n() * 100),
    identity_male = sprintf("%.1f", sum(gender_identity == "männlich", na.rm = TRUE) / n() * 100),
    identity_nonbinary = sprintf("%.1f", sum(gender_identity == "non binär/abinär", na.rm = TRUE) / n() * 100),
    
    # TRANSITION-SPECIFIC CHARACTERISTICS
    # Hormones
    hormone_e = sprintf("%.1f", sum(med2 == 1, na.rm = TRUE) / n() * 100),
    hormone_t = sprintf("%.1f", sum(med4 == 1, na.rm = TRUE) / n() * 100),
    blockers = sprintf("%.1f", sum(med3 == 1, na.rm = TRUE) / n() * 100),
    
    # Surgery
    mastectomy = sprintf("%.1f", sum(med8 == 1, na.rm = TRUE) / n() * 100),
    breast_aug = sprintf("%.1f", sum(med9 == 1, na.rm = TRUE) / n() * 100),
    hysterectomy = sprintf("%.1f", sum(med10 == 1, na.rm = TRUE) / n() * 100),
    neovagina = sprintf("%.1f", sum(med11 == 1, na.rm = TRUE) / n() * 100),
    phalloplasty = sprintf("%.1f", sum(med12 == 1, na.rm = TRUE) / n() * 100),
    
    # Other measures
    facial_fem = sprintf("%.1f", sum(med7 == 1, na.rm = TRUE) / n() * 100),
    voice_surgery = sprintf("%.1f", sum(med13 == 1, na.rm = TRUE) / n() * 100),
    adams_apple = sprintf("%.1f", sum(med14 == 1, na.rm = TRUE) / n() * 100),
    speech_therapy = sprintf("%.1f", sum(med5 == 1, na.rm = TRUE) / n() * 100),
    laser = sprintf("%.1f", sum(med6 == 1, na.rm = TRUE) / n() * 100)
  )

# Format table
format_comprehensive_table <- comprehensive_table %>%
  mutate(
    birth_sex = case_when(
      birth_sex == "Männlich (AMAB: Assigned Male At Birth)" ~ "AMAB",
      birth_sex == "Weiblich (AFAB: Assigned Female At Birth)" ~ "AFAB",
      birth_sex == "Intergeschlechtlich" ~ "Intersex"
    )
  )

# Create markdown table content
md_content <- "# Table 1: Comprehensive Analysis by Sex Assigned at Birth\n\n"

# Add section headers and create transposed tables
md_content <- paste0(md_content, "## Demographic Characteristics\n\n")
md_content <- paste0(md_content, "| Characteristic | AMAB (n=176) | AFAB (n=115) | Intersex (n=2) |\n")
md_content <- paste0(md_content, "|:--------------|:-------------|:-------------|:--------------|\n")

# Add demographic data
demographic_rows <- c(
  "Age (M ± SD)" = "age_formatted",
  "Living Alone (%)" = "living_alone",
  "Living with Partner (%)" = "living_partner",
  "Living with Family (%)" = "living_family",
  "University Degree (%)" = "education_university",
  "Vocational Training (%)" = "education_vocational",
  "Employed (%)" = "employment_employed",
  "Unemployed (%)" = "employment_unemployed"
)

for(i in seq_along(demographic_rows)) {
  row_name <- names(demographic_rows)[i]
  col_name <- demographic_rows[i]
  md_content <- paste0(md_content,
    "| ", row_name,
    " | ", format_comprehensive_table[[col_name]][format_comprehensive_table$birth_sex == "AMAB"],
    " | ", format_comprehensive_table[[col_name]][format_comprehensive_table$birth_sex == "AFAB"],
    " | ", format_comprehensive_table[[col_name]][format_comprehensive_table$birth_sex == "Intersex"],
    " |\n"
  )
}

md_content <- paste0(md_content, "\n## Trans-specific Characteristics\n\n")
md_content <- paste0(md_content, "| Characteristic | AMAB (n=176) | AFAB (n=115) | Intersex (n=2) |\n")
md_content <- paste0(md_content, "|:--------------|:-------------|:-------------|:--------------|\n")

# Add trans-specific data
trans_specific_rows <- c(
  "Age at Inner Coming Out (M ± SD)" = "inner_co_age_mean",
  "Age at Outer Coming Out (M ± SD)" = "outer_co_age_mean",
  "Identity: Female (%)" = "identity_female",
  "Identity: Male (%)" = "identity_male",
  "Identity: Non-binary (%)" = "identity_nonbinary"
)

for(i in seq_along(trans_specific_rows)) {
  row_name <- names(trans_specific_rows)[i]
  col_name <- trans_specific_rows[i]
  md_content <- paste0(md_content,
    "| ", row_name,
    " | ", format_comprehensive_table[[col_name]][format_comprehensive_table$birth_sex == "AMAB"],
    " | ", format_comprehensive_table[[col_name]][format_comprehensive_table$birth_sex == "AFAB"],
    " | ", format_comprehensive_table[[col_name]][format_comprehensive_table$birth_sex == "Intersex"],
    " |\n"
  )
}

md_content <- paste0(md_content, "\n## Transition-specific Characteristics\n\n")
md_content <- paste0(md_content, "| Characteristic | AMAB (n=176) | AFAB (n=115) | Intersex (n=2) |\n")
md_content <- paste0(md_content, "|:--------------|:-------------|:-------------|:--------------|\n")

# Add transition-specific data
transition_rows <- c(
  "Hormone Therapy - Estrogen (%)" = "hormone_e",
  "Hormone Therapy - Testosterone (%)" = "hormone_t",
  "Hormone Blockers (%)" = "blockers",
  "Mastectomy (%)" = "mastectomy",
  "Breast Augmentation (%)" = "breast_aug",
  "Hysterectomy (%)" = "hysterectomy",
  "Neovaginoplasty (%)" = "neovagina",
  "Phalloplasty (%)" = "phalloplasty",
  "Facial Feminization (%)" = "facial_fem",
  "Voice Surgery (%)" = "voice_surgery",
  "Adam's Apple Reduction (%)" = "adams_apple",
  "Speech Therapy (%)" = "speech_therapy",
  "Laser Epilation (%)" = "laser"
)

for(i in seq_along(transition_rows)) {
  row_name <- names(transition_rows)[i]
  col_name <- transition_rows[i]
  md_content <- paste0(md_content,
    "| ", row_name,
    " | ", format_comprehensive_table[[col_name]][format_comprehensive_table$birth_sex == "AMAB"],
    " | ", format_comprehensive_table[[col_name]][format_comprehensive_table$birth_sex == "AFAB"],
    " | ", format_comprehensive_table[[col_name]][format_comprehensive_table$birth_sex == "Intersex"],
    " |\n"
  )
}

# Add note
md_content <- paste0(md_content, "\n_Note._ All percentages are calculated within each group. M = Mean; SD = Standard Deviation.")

# Save markdown table
writeLines(md_content, "manuscript/tables/comprehensive_analysis.md")

# Also save as CSV for further analysis
write.csv(format_comprehensive_table, "data/processed/comprehensive_analysis.csv", row.names = FALSE) 