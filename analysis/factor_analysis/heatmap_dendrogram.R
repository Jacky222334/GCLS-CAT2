# Load required packages
library(readxl)
library(psych)
library(pheatmap)

# Read data
daten <- read_excel("../../data/raw/dat_EFA_26.xlsx")

# Use only numeric columns
numeric_cols <- sapply(daten, is.numeric)
daten_numeric <- daten[, numeric_cols]

# Perform EFA
efa_result <- fa(daten_numeric, 
                nfactors = 7, 
                rotate = "oblimin",
                fm = "ml",
                use = "pairwise.complete.obs")

# Extract loading matrix
loadings_matrix <- as.matrix(unclass(efa_result$loadings))

# Create matrix with all formatted numbers for display
display_matrix <- matrix(
  sprintf("%.2f", loadings_matrix),
  nrow = nrow(loadings_matrix)
)
rownames(display_matrix) <- rownames(loadings_matrix)
colnames(display_matrix) <- paste("Factor", 1:ncol(loadings_matrix))

# Define original scale groups with abbreviations
groups <- c(
  "PF (Psychological Function)",
  "SF (Social Function)",
  "PhF (Physical Function)",
  "LS (Life Satisfaction)",
  "BI (Body Image)",
  "RS (Relationship Satisfaction)",
  "GI (Gender Identity)"
)

# Define items for each group based on original scale
pf_items <- c("I1", "I2", "I3", "I4", "I5")
sf_items <- c("I6", "I7", "I8", "I9", "I10_r")
phf_items <- c("I11", "I12", "I13", "I14", "I15")
ls_items <- c("I16_r", "I17", "I18", "I19", "I20_r")
bi_items <- c("I21", "I22_r", "I23", "I24", "I25")
rs_items <- c("I27", "I28", "I29", "I30_r", "I31_r", "I32")
gi_items <- c("I33", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r")

# Create group mapping
item_to_group <- c(
  setNames(rep("PF (Psychological Function)", length(pf_items)), pf_items),
  setNames(rep("SF (Social Function)", length(sf_items)), sf_items),
  setNames(rep("PhF (Physical Function)", length(phf_items)), phf_items),
  setNames(rep("LS (Life Satisfaction)", length(ls_items)), ls_items),
  setNames(rep("BI (Body Image)", length(bi_items)), bi_items),
  setNames(rep("RS (Relationship Satisfaction)", length(rs_items)), rs_items),
  setNames(rep("GI (Gender Identity)", length(gi_items)), gi_items)
)

# Create annotation dataframe
item_groups <- data.frame(
  row.names = rownames(loadings_matrix),
  Group = item_to_group[rownames(loadings_matrix)]
)

# Colors for groups
annotation_colors <- list(
  Group = c(
    "PF (Psychological Function)" = "#E41A1C",
    "SF (Social Function)" = "#377EB8",
    "PhF (Physical Function)" = "#4DAF4A",
    "LS (Life Satisfaction)" = "#984EA3",
    "BI (Body Image)" = "#FF7F00",
    "RS (Relationship Satisfaction)" = "#FFFF33",
    "GI (Gender Identity)" = "#A65628"
  )
)

# Create heatmap with original grouping
pdf("efa_results/factor_loadings_original_groups.pdf", width = 15, height = 15)
pheatmap(loadings_matrix,
         color = colorRampPalette(c("#2166AC", "white", "#B2182B"))(100),
         breaks = seq(-1, 1, length.out = 101),
         display_numbers = display_matrix,
         number_color = "black",
         fontsize_number = 11,
         fontsize = 12,
         fontsize_row = 10,
         fontsize_col = 12,
         cluster_rows = FALSE,  # No clustering to maintain original order
         cluster_cols = FALSE,
         annotation_row = item_groups,
         annotation_colors = annotation_colors,
         main = "Factor Loadings by Original Scales",
         annotation_names_row = TRUE,
         annotation_legend = TRUE,
         labels_col = paste("Factor", 1:ncol(loadings_matrix)))
dev.off()

# Print summary of factor loadings by group
print("Factor Loading Patterns by Original Scale:")
for(group in unique(item_groups$Group)) {
  group_items <- rownames(loadings_matrix)[item_groups$Group == group]
  group_loadings <- loadings_matrix[group_items, ]
  cat("\nGroup:", group, "\n")
  print(round(group_loadings, 2))
} 