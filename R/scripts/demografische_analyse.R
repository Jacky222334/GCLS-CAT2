# Demographic Analysis of GCLS Data
library(readxl)
library(tidyverse)
library(psych)
library(networkD3)  # For Sankey diagram

# Load data
load_data <- function(file_path = "data/raw/rwa_demo_trans_transpez.xlsx") {
  data <- read_excel(file_path)
  return(data)
}

# Prepare demographic variables
prepare_demographics <- function(data) {
  demo_data <- data %>%
    select(
      id = antwortid,
      birth_year = geb,
      living_situation = `@2wieistihremomentanewohnsituation`,
      relationship_status = `@3wieistihrmomentanerbeziehungsstatus`,
      education = `@4wasistihrhoechsterabgeschlossenerbildungsgrad`,
      employment = `@5wieistihrederzeitigearbeitssituation`,
      birth_sex = `@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen`,
      gender_identity = `@7welchegeschlechtsidentitaetordnensiesichselbstzu`,
      age = age2
    )
  
  return(demo_data)
}

# Calculate descriptive statistics
calculate_descriptives <- function(demo_data) {
  # Age statistics
  age_stats <- demo_data %>%
    summarise(
      n = n(),
      mean = mean(age, na.rm = TRUE),
      sd = sd(age, na.rm = TRUE),
      min = min(age, na.rm = TRUE),
      max = max(age, na.rm = TRUE)
    )
  
  # Frequency tables
  sex_table <- table(demo_data$birth_sex)
  identity_table <- table(demo_data$gender_identity)
  living_table <- table(demo_data$living_situation)
  relationship_table <- table(demo_data$relationship_status)
  education_table <- table(demo_data$education)
  employment_table <- table(demo_data$employment)
  
  return(list(
    age = age_stats,
    sex = sex_table,
    identity = identity_table,
    living = living_table,
    relationship = relationship_table,
    education = education_table,
    employment = employment_table
  ))
}

# Save results
save_results <- function(stats, output_path = "output/demografische_statistiken.txt") {
  sink(output_path)
  
  cat("Demografische Analyse der GCLS-Stichprobe\n")
  cat("========================================\n\n")
  
  cat("1. Altersverteilung\n")
  cat("-----------------\n")
  print(stats$age)
  cat("\n")
  
  cat("2. Verteilung Geburtsgeschlecht\n")
  cat("----------------------------\n")
  print(stats$sex)
  cat("\nProzentuale Verteilung:\n")
  print(prop.table(stats$sex) * 100)
  cat("\n")
  
  cat("3. Verteilung Geschlechtsidentität\n")
  cat("-------------------------------\n")
  print(stats$identity)
  cat("\nProzentuale Verteilung:\n")
  print(prop.table(stats$identity) * 100)
  cat("\n")
  
  cat("4. Wohnsituation\n")
  cat("---------------\n")
  print(stats$living)
  cat("\nProzentuale Verteilung:\n")
  print(prop.table(stats$living) * 100)
  cat("\n")
  
  cat("5. Beziehungsstatus\n")
  cat("-----------------\n")
  print(stats$relationship)
  cat("\nProzentuale Verteilung:\n")
  print(prop.table(stats$relationship) * 100)
  cat("\n")
  
  cat("6. Bildungsstand\n")
  cat("--------------\n")
  print(stats$education)
  cat("\nProzentuale Verteilung:\n")
  print(prop.table(stats$education) * 100)
  cat("\n")
  
  cat("7. Arbeitssituation\n")
  cat("-----------------\n")
  print(stats$employment)
  cat("\nProzentuale Verteilung:\n")
  print(prop.table(stats$employment) * 100)
  
  sink()
}

# Create visualizations
create_visualizations <- function(demo_data) {
  # Age distribution
  age_plot <- ggplot(demo_data, aes(x = age)) +
    geom_histogram(binwidth = 5, fill = "lightblue", color = "black") +
    labs(title = "Age Distribution",
         subtitle = paste("n =", nrow(demo_data), "participants"),
         x = "Age (years)",
         y = "Frequency",
         caption = paste("Mean age:", round(mean(demo_data$age, na.rm = TRUE), 1),
                        "years (SD =", round(sd(demo_data$age, na.rm = TRUE), 1), ")")) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 12),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    )
  
  # Birth sex distribution with percentages
  sex_data <- demo_data %>%
    count(birth_sex) %>%
    mutate(
      percentage = n / sum(n) * 100,
      label = sprintf("%d\n(%.1f%%)", n, percentage),
      birth_sex = case_when(
        birth_sex == "Intergeschlechtlich" ~ "Intersex",
        birth_sex == "Männlich (AMAB: Assigned Male At Birth)" ~ "AMAB",
        birth_sex == "Weiblich (AFAB: Assigned Female At Birth)" ~ "AFAB"
      )
    )
  
  sex_plot <- ggplot(sex_data, aes(x = reorder(birth_sex, n), y = n, fill = birth_sex)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 4) +
    coord_flip() +
    labs(title = "Distribution of Sex Assigned at Birth",
         subtitle = paste("n =", sum(sex_data$n), "participants"),
         x = "Sex Assigned at Birth",
         y = "Number of Participants",
         fill = "Sex Assigned at Birth") +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 12),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      legend.position = "bottom"
    )
  
  # Gender identity distribution with percentages
  identity_data <- demo_data %>%
    count(gender_identity) %>%
    mutate(
      percentage = n / sum(n) * 100,
      label = sprintf("%d\n(%.1f%%)", n, percentage),
      gender_identity = case_when(
        gender_identity == "weiblich" ~ "Female",
        gender_identity == "männlich" ~ "Male",
        gender_identity == "non binär/abinär" ~ "Non-binary",
        gender_identity == "genderfluid" ~ "Genderfluid",
        gender_identity == "anderes" ~ "Other"
      )
    )
  
  identity_plot <- ggplot(identity_data, aes(x = reorder(gender_identity, n), y = n, fill = gender_identity)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 4) +
    coord_flip() +
    labs(title = "Distribution of Gender Identity",
         subtitle = paste("n =", sum(identity_data$n), "participants"),
         x = "Gender Identity",
         y = "Number of Participants",
         fill = "Gender Identity") +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 12),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      legend.position = "bottom"
    )
  
  # Save plots
  ggsave("output/age_distribution.pdf", age_plot, width = 10, height = 6)
  ggsave("output/sex_distribution.pdf", sex_plot, width = 10, height = 6)
  ggsave("output/gender_identity_distribution.pdf", identity_plot, width = 10, height = 6)
}

# Create Sankey diagram
create_sankey <- function(demo_data) {
  # Prepare data for Sankey diagram
  links <- demo_data %>%
    mutate(
      birth_sex = case_when(
        birth_sex == "Intergeschlechtlich" ~ "Intersex",
        birth_sex == "Männlich (AMAB: Assigned Male At Birth)" ~ "AMAB",
        birth_sex == "Weiblich (AFAB: Assigned Female At Birth)" ~ "AFAB"
      ),
      gender_identity = case_when(
        gender_identity == "weiblich" ~ "Female",
        gender_identity == "männlich" ~ "Male",
        gender_identity == "non binär/abinär" ~ "Non-binary",
        gender_identity == "genderfluid" ~ "Genderfluid",
        gender_identity == "anderes" ~ "Other"
      )
    ) %>%
    count(birth_sex, gender_identity) %>%
    rename(source = birth_sex, target = gender_identity, value = n)
  
  # Create unique nodes list
  nodes <- data.frame(
    name = unique(c(links$source, links$target))
  )
  
  # Calculate percentages for labels
  total_n <- sum(links$value)
  links <- links %>%
    mutate(label = sprintf("%d (%.1f%%)", value, value/total_n * 100))
  
  # Convert source and target to 0-based index
  links$source <- match(links$source, nodes$name) - 1
  links$target <- match(links$target, nodes$name) - 1
  
  # Create color palette
  node_colors <- 'd3.scaleOrdinal().range(["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2", "#7f7f7f"])'
  
  # Create Sankey diagram
  sankey <- sankeyNetwork(
    Links = links,
    Nodes = nodes,
    Source = "source",
    Target = "target",
    Value = "value",
    NodeID = "name",
    units = "participants",
    fontSize = 14,
    nodeWidth = 30,
    height = 600,
    width = 1000,
    colourScale = node_colors,
    LinkGroup = "source"
  )
  
  # Save as HTML
  saveNetwork(sankey, "output/sex_to_gender_identity_sankey.html")
  
  # Create a static version for PDF
  # Note: This requires the webshot package
  webshot::webshot("output/sex_to_gender_identity_sankey.html", 
                   "output/sex_to_gender_identity_sankey.pdf",
                   vwidth = 1000, 
                   vheight = 600)
}

# Main function
run_demographic_analysis <- function() {
  # Load data
  data <- load_data()
  
  # Prepare demographic data
  demo_data <- prepare_demographics(data)
  
  # Calculate statistics
  stats <- calculate_descriptives(demo_data)
  
  # Save results
  save_results(stats)
  
  # Create visualizations
  create_visualizations(demo_data)
  
  # Create Sankey diagram
  create_sankey(demo_data)
  
  return(list(
    data = demo_data,
    statistics = stats
  ))
}

# Run analysis
results <- run_demographic_analysis() 