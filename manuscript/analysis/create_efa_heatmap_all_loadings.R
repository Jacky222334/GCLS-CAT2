# EFA Factor Loadings Heatmap - ALL LOADINGS VISIBLE
# Show every single loading value in the heatmap

# Load required libraries
library(ggplot2)
library(reshape2)
library(dplyr)

# Read the factor loadings data
loadings_df <- read.csv("../../analysis/factor_analysis/factor_loadings_38items.csv", stringsAsFactors = FALSE)

# Clean up the data
items <- loadings_df$Item
loadings_matrix <- as.matrix(loadings_df[, -1])  # Remove first column (Item names)
rownames(loadings_matrix) <- items

# Create factor labels
factor_labels <- c(
  "ML1" = "Genitalia",
  "ML2" = "Social Gender Role",  
  "ML3" = "Chest", 
  "ML4" = "Life Satisfaction",
  "ML5" = "Intimacy",
  "ML6" = "Other Secondary Sex",
  "ML7" = "Psychological"
)

# Perform hierarchical clustering on items
item_dist <- dist(loadings_matrix, method = "euclidean")
item_clust <- hclust(item_dist, method = "ward.D2")

# Reorder the loadings matrix based on clustering
item_order <- item_clust$order
loadings_ordered <- loadings_matrix[item_order, ]

# Convert to long format for ggplot
loadings_long <- melt(loadings_ordered, varnames = c("Item", "Factor"), value.name = "Loading")
loadings_long$Item <- factor(loadings_long$Item, levels = rownames(loadings_ordered))

# Add factor labels to column names
loadings_long$Factor_Label <- factor_labels[loadings_long$Factor]
loadings_long$Factor_Combined <- paste0(loadings_long$Factor, "\n", loadings_long$Factor_Label)
loadings_long$Factor_Combined <- factor(loadings_long$Factor_Combined, 
                                       levels = paste0(names(factor_labels), "\n", factor_labels))

# Create heatmap with ALL loadings shown
heatmap_all_loadings <- ggplot(loadings_long, aes(x = Factor_Combined, y = Item, fill = Loading)) +
  geom_tile(color = "white", linewidth = 0.1) +
  scale_fill_gradient2(
    low = "#d73027", 
    mid = "white", 
    high = "#1a9850",
    midpoint = 0,
    limit = c(-1, 1),
    name = "Factor\nLoading"
  ) +
  # Show ALL loadings - different formatting for different thresholds
  # Primary loadings ≥ 0.40 in bold black
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "black",
    size = 2.8,
    fontface = "bold"
  ) +
  # Moderate loadings 0.30-0.39 in bold gray
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.30 & abs(Loading) < 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray20",
    size = 2.4,
    fontface = "bold"
  ) +
  # Small loadings 0.20-0.29 in normal gray
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.20 & abs(Loading) < 0.30),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray40",
    size = 2.0,
    fontface = "plain"
  ) +
  # Very small loadings < 0.20 in light gray
  geom_text(
    data = subset(loadings_long, abs(Loading) < 0.20),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray60",
    size = 1.8,
    fontface = "plain"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 9, lineheight = 0.8),
    axis.text.y = element_text(size = 7),
    axis.title = element_text(size = 11),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
    panel.grid = element_blank(),
    plot.title = element_text(size = 13, hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(size = 10, hjust = 0.5),
    plot.margin = margin(15, 15, 15, 15)
  ) +
  labs(
    title = "EFA Factor Loading Heatmap - All Loadings Displayed",
    subtitle = "Items in clustered order • ≥0.40: bold black • 0.30-0.39: bold gray • 0.20-0.29: gray • <0.20: light gray",
    x = "Factors (ML1-ML7)",
    y = "GCLS Items (Hierarchically Clustered Order)"
  )

# Save the comprehensive heatmap
ggsave("../figures/efa_heatmap_all_loadings.pdf", heatmap_all_loadings, 
       width = 12, height = 16, units = "in", dpi = 300)
ggsave("../figures/efa_heatmap_all_loadings.png", heatmap_all_loadings, 
       width = 12, height = 16, units = "in", dpi = 300)

# Create an alternative version with even smaller text for better readability
heatmap_compact <- ggplot(loadings_long, aes(x = Factor_Combined, y = Item, fill = Loading)) +
  geom_tile(color = "white", linewidth = 0.02) +
  scale_fill_gradient2(
    low = "#d73027", 
    mid = "white", 
    high = "#1a9850",
    midpoint = 0,
    limit = c(-1, 1),
    name = "Loading"
  ) +
  # ALL loadings with optimized text size for compactness
  geom_text(
    aes(label = sprintf("%.2f", Loading),
        color = ifelse(abs(Loading) >= 0.40, "black",
                      ifelse(abs(Loading) >= 0.30, "gray20",
                            ifelse(abs(Loading) >= 0.20, "gray40", "gray60"))),
        fontface = ifelse(abs(Loading) >= 0.30, "bold", "plain")),
    size = 1.4  # Reduced from 1.8 for compactness
  ) +
  scale_color_identity() +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 7, lineheight = 0.7),  # Reduced size
    axis.text.y = element_text(size = 5),  # Reduced from 6
    axis.title = element_text(size = 9),   # Reduced from 10
    legend.title = element_text(size = 8), # Reduced from 9
    legend.text = element_text(size = 7),  # Reduced from 8
    legend.key.size = unit(0.4, "cm"),     # Smaller legend
    panel.grid = element_blank(),
    plot.title = element_text(size = 11, hjust = 0.5, face = "bold"),  # Reduced from 12
    plot.subtitle = element_text(size = 8, hjust = 0.5),  # Reduced from 9
    plot.margin = margin(8, 8, 8, 8),     # Reduced margins
    panel.spacing = unit(0.1, "cm")       # Tighter spacing
  ) +
  labs(
    title = "Complete EFA Factor Loading Matrix (N = 293)",
    subtitle = "All 266 loadings • Items clustered • Bold: ≥0.30 • Compact layout for readability",
    x = "Factors (ML1-ML7) with Post-Hoc Interpretations",
    y = "GCLS Items (Ward's Clustering Order)"
  )

# Save the compact version with optimized dimensions
ggsave("../figures/efa_heatmap_all_loadings_compact.pdf", heatmap_compact, 
       width = 12, height = 15, units = "in", dpi = 300)  # Reduced dimensions for compactness
ggsave("../figures/efa_heatmap_all_loadings_compact.png", heatmap_compact, 
       width = 12, height = 15, units = "in", dpi = 300)

# Print summary statistics
cat("Complete EFA Heatmap with ALL loadings created!\n\n")

cat("Files saved:\n")
cat("- efa_heatmap_all_loadings.pdf/png (detailed version)\n")
cat("- efa_heatmap_all_loadings_compact.pdf/png (compact version)\n\n")

# Loading distribution analysis
loading_stats <- data.frame(
  Category = c("Primary (≥0.40)", "Moderate (0.30-0.39)", "Small (0.20-0.29)", "Very Small (<0.20)"),
  Count = c(
    sum(abs(loadings_matrix) >= 0.40),
    sum(abs(loadings_matrix) >= 0.30 & abs(loadings_matrix) < 0.40),
    sum(abs(loadings_matrix) >= 0.20 & abs(loadings_matrix) < 0.30),
    sum(abs(loadings_matrix) < 0.20)
  ),
  Percentage = c(
    round(100 * sum(abs(loadings_matrix) >= 0.40) / length(loadings_matrix), 1),
    round(100 * sum(abs(loadings_matrix) >= 0.30 & abs(loadings_matrix) < 0.40) / length(loadings_matrix), 1),
    round(100 * sum(abs(loadings_matrix) >= 0.20 & abs(loadings_matrix) < 0.30) / length(loadings_matrix), 1),
    round(100 * sum(abs(loadings_matrix) < 0.20) / length(loadings_matrix), 1)
  )
)

cat("Loading Distribution:\n")
print(loading_stats)

cat(sprintf("\nTotal loadings displayed: %d (38 items × 7 factors)\n", length(loadings_matrix)))
cat(sprintf("Mean absolute loading: %.3f\n", mean(abs(loadings_matrix))))
cat(sprintf("Range: %.3f to %.3f\n", min(loadings_matrix), max(loadings_matrix)))

# Identify cross-loadings (items with multiple loadings ≥ 0.30)
cross_loadings <- apply(abs(loadings_matrix) >= 0.30, 1, sum)
cross_loading_items <- names(cross_loadings)[cross_loadings > 1]

cat(sprintf("\nItems with cross-loadings (≥0.30 on multiple factors): %d\n", length(cross_loading_items)))
if(length(cross_loading_items) > 0) {
  for(item in cross_loading_items) {
    loadings_item <- loadings_matrix[item, ]
    high_loadings <- loadings_item[abs(loadings_item) >= 0.30]
    cat(sprintf("  %s: %s\n", item, paste(names(high_loadings), sprintf("(%.2f)", high_loadings), collapse = ", ")))
  }
}

cat("\n=== VISUAL ENCODING LEGEND ===\n")
cat("Text Size & Weight:\n")
cat("  • Bold Black (large): Primary loadings ≥ 0.40\n")
cat("  • Bold Gray (medium): Moderate loadings 0.30-0.39\n") 
cat("  • Normal Gray (small): Small loadings 0.20-0.29\n")
cat("  • Light Gray (tiny): Very small loadings < 0.20\n")
cat("\nColor Scale:\n")
cat("  • Red: Negative loadings\n")
cat("  • White: Near-zero loadings\n") 
cat("  • Green: Positive loadings\n") 