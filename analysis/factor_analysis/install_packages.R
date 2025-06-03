# List of required packages
packages <- c("readxl", "psych", "GPArotation", "corrplot", "nFactors", "tidyverse")

# Function to install missing packages
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) install.packages(new_packages)
}

# Install missing packages
install_if_missing(packages)

# Print success message
cat("All required packages have been installed!\n") 