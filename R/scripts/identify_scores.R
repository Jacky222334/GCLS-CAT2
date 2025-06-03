# Script to identify questionnaire scores
library(readxl)
library(tidyverse)

# Read the data
data <- read_excel("data/raw/raw_quest_all.xlsx")

# Print all column names to inspect
cat("\nAll column names:\n")
print(names(data))

# Identify variables for each questionnaire
identify_scores <- function(data) {
  # Print all column names containing specific patterns
  patterns <- c(
    "srf|SRF",
    "phq|PHQ|depr|Depr",
    "zuf|ZUF",
    "gckes|GCKES",
    "score|sum|total|gesamt"
  )
  
  for(pattern in patterns) {
    cat(sprintf("\nVariables matching pattern '%s':\n", pattern))
    matches <- grep(pattern, names(data), value = TRUE, ignore.case = TRUE)
    if(length(matches) > 0) {
      print(matches)
      
      # Print summary statistics if these look like score variables
      score_vars <- grep("score|sum|total|gesamt", matches, value = TRUE, ignore.case = TRUE)
      if(length(score_vars) > 0) {
        cat("\nSummary statistics:\n")
        print(summary(data[score_vars]))
      }
    } else {
      cat("No matches found\n")
    }
  }
}

# Run the analysis
identify_scores(data) 