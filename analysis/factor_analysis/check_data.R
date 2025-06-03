library(readxl)

# Read data
data <- read_excel("../../data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Print column names
print("Column names in dataset:")
print(names(data))

# Print summary of data
print("\nData summary:")
print(summary(data))

# Print first few rows
print("\nFirst few rows:")
print(head(data)) 