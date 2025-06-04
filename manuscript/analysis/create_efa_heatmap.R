# EFA Factor Loadings Heatmap
# Create heatmap visualization of the 7-factor EFA results

# Load required libraries
library(ggplot2)
library(reshape2)
library(dplyr)
library(RColorBrewer)
library(scales)

# Read the factor loadings data
loadings_df <- read.csv("analysis/factor_analysis/factor_loadings_38items.csv", stringsAsFactors = FALSE)

# Clean up the data
# Remove the Item column and convert to numeric matrix
items <- loadings_df$Item
loadings_matrix <- as.matrix(loadings_df[, -1])  # Remove first column (Item names)
rownames(loadings_matrix) <- items

# Convert to long format for ggplot
loadings_long <- melt(loadings_matrix, varnames = c("Item", "Factor"), value.name = "Loading")

# Create factor groups based on primary loadings (> 0.40)
factor_groups <- c()
for(i in 1:nrow(loadings_df)) {
  max_loading <- max(abs(loadings_df[i, -1]))
  primary_factor <- names(loadings_df[, -1])[which.max(abs(loadings_df[i, -1]))]
  factor_groups <- c(factor_groups, primary_factor)
}

# Add factor group information
item_factor_map <- data.frame(
  Item = items,
  Primary_Factor = factor_groups,
  stringsAsFactors = FALSE
)

# Merge with loadings data
loadings_long <- merge(loadings_long, item_factor_map, by = "Item")

# Order items by primary factor for better visualization
factor_order <- c("ML1", "ML2", "ML3", "ML4", "ML5", "ML6", "ML7")
item_order <- c()
for(f in factor_order) {
  items_in_factor <- item_factor_map$Item[item_factor_map$Primary_Factor == f]
  item_order <- c(item_order, items_in_factor)
}

loadings_long$Item <- factor(loadings_long$Item, levels = rev(item_order))
loadings_long$Factor <- factor(loadings_long$Factor, levels = factor_order)

# Create the heatmap
p <- ggplot(loadings_long, aes(x = Factor, y = Item, fill = Loading)) +
  geom_tile(color = "white", size = 0.1) +
  scale_fill_gradient2(
    low = "#d73027", 
    mid = "white", 
    high = "#1a9850",
    midpoint = 0,
    limit = c(-1, 1),
    space = "Lab",
    name = "Factor\nLoading"
  ) +
  # Add text for significant loadings (> 0.40)
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "black",
    size = 2.5,
    fontface = "bold"
  ) +
  # Add text for moderate loadings (0.30-0.39)
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.30 & abs(Loading) < 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray30",
    size = 2
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 10),
    axis.text.y = element_text(size = 8),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
    panel.grid = element_blank(),
    plot.title = element_text(size = 14, hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    plot.margin = margin(20, 20, 20, 20)
  ) +
  labs(
    title = "EFA Factor Loading Heatmap - German GCLS (N = 293)",
    subtitle = "Seven-factor solution with primary loadings ≥ 0.40 in bold",
    x = "Factors (ML1-ML7)",
    y = "GCLS Items"
  ) +
  coord_equal()

# Add factor labels as annotations
factor_labels <- c(
  "ML1" = "Genitalia",
  "ML2" = "Social Gender Role",  
  "ML3" = "Chest",
  "ML4" = "Life Satisfaction",
  "ML5" = "Intimacy",
  "ML6" = "Other Secondary Sex",
  "ML7" = "Psychological"
)

# Create a second version with factor labels
p_labeled <- p + 
  scale_x_discrete(
    labels = paste0(names(factor_labels), "\n", factor_labels)
  ) +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 9, lineheight = 0.8)
  )

# Save both versions
ggsave("manuscript/figures/efa_heatmap_simple.pdf", p, width = 10, height = 14, units = "in", dpi = 300)
ggsave("manuscript/figures/efa_heatmap_labeled.pdf", p_labeled, width = 12, height = 14, units = "in", dpi = 300)

# Also save as PNG for easier viewing
ggsave("manuscript/figures/efa_heatmap_simple.png", p, width = 10, height = 14, units = "in", dpi = 300)
ggsave("manuscript/figures/efa_heatmap_labeled.png", p_labeled, width = 12, height = 14, units = "in", dpi = 300)

# Print summary
cat("EFA Heatmap created successfully!\n")
cat("Files saved:\n")
cat("- efa_heatmap_simple.pdf/png (ML factors only)\n")
cat("- efa_heatmap_labeled.pdf/png (with factor interpretations)\n")
cat("\nHeatmap shows:\n")
cat("- Items ordered by primary factor loading\n")
cat("- Bold text for loadings ≥ 0.40\n")
cat("- Gray text for loadings 0.30-0.39\n")
cat("- Color scale: red (negative) to green (positive)\n")

# Display loading statistics
cat("\nLoading Statistics:\n")
high_loadings <- sum(abs(loadings_matrix) >= 0.40)
moderate_loadings <- sum(abs(loadings_matrix) >= 0.30 & abs(loadings_matrix) < 0.40)
total_loadings <- length(loadings_matrix)

cat(sprintf("High loadings (≥0.40): %d (%.1f%%)\n", 
            high_loadings, 100 * high_loadings / total_loadings))
cat(sprintf("Moderate loadings (0.30-0.39): %d (%.1f%%)\n", 
            moderate_loadings, 100 * moderate_loadings / total_loadings))
cat(sprintf("Total cells: %d\n", total_loadings)) 