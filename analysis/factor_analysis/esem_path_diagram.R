# Load required packages
library(lavaan)
library(semPlot)
library(tidyverse)
library(readxl)

# Read the data
gcls_data <- read_excel("data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Prepare item data - columns are named I1 to I38
item_data <- gcls_data %>%
  select(starts_with("I")) %>%
  rename_with(~paste0("item", gsub("I", "", .)))

# Define the ESEM model
esem_model <- '
# Define factors
Soc =~ NA*item8 + item9 + item10 + item11 + item12 + item13
Gen =~ NA*item14 + item21 + item25 + item27 + item29
Psych =~ NA*item1 + item2 + item3 + item4 + item5 + item6 + item7
Chest =~ NA*item15 + item18 + item28 + item30
Life =~ NA*item19 + item20 + item22
Intim =~ NA*item31 + item32 + item33 + item34
Sec =~ NA*item16 + item17 + item23 + item24 + item35 + item36 + item37 + item38

# Allow factors to correlate
Soc ~~ Gen + Psych + Chest + Life + Intim + Sec
Gen ~~ Psych + Chest + Life + Intim + Sec
Psych ~~ Chest + Life + Intim + Sec
Chest ~~ Life + Intim + Sec
Life ~~ Intim + Sec
Intim ~~ Sec

# Set factor variances to 1
Soc ~~ 1*Soc
Gen ~~ 1*Gen
Psych ~~ 1*Psych
Chest ~~ 1*Chest
Life ~~ 1*Life
Intim ~~ 1*Intim
Sec ~~ 1*Sec
'

# Fit the ESEM model
esem_fit <- cfa(esem_model, 
                data = item_data,
                estimator = "ML",
                rotation = "geomin",
                rotation.args = list(orthogonal = FALSE))

# Create a simple path diagram as a dendrogram
semPaths(esem_fit,
         whatLabels = "std",
         layout = "tree",
         color = list(lat = "white", man = "white"),
         edge.color = "black",
         edge.label.cex = 0.5,
         equalizeManifests = FALSE,
         intercepts = FALSE,
         residuals = FALSE,
         levels = c(1,4,8,12),
         nCharNodes = 0,
         sizeLat = 14,
         sizeMan = 5,
         node.width = 2)

# Save the plot with high resolution
pdf("analysis/factor_analysis/esem_path_diagram.pdf", width = 18, height = 18)
semPaths(esem_fit,
         whatLabels = "std",
         layout = "tree",
         color = list(lat = "white", man = "white"),
         edge.color = "black",
         edge.label.cex = 0.5,
         equalizeManifests = FALSE,
         intercepts = FALSE,
         residuals = FALSE,
         levels = c(1,4,8,12),
         nCharNodes = 0,
         sizeLat = 14,
         sizeMan = 5,
         node.width = 2)
dev.off()

# Print model fit indices
summary(esem_fit, fit.measures = TRUE) 