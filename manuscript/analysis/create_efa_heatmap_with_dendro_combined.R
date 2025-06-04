# EFA Heatmap with Left-Side Dendrogram - ALL LOADINGS
# Combine dendrogram and complete loading matrix in one plot

# Load required libraries
library(ggplot2)
library(reshape2)
library(dplyr)
library(grid)
library(gridExtra)
library(ggdendro)

# Read the factor loadings data
loadings_df <- read.csv("analysis/factor_analysis/factor_loadings_38items.csv", stringsAsFactors = FALSE)

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

# Create dendrogram data
dendro_data <- dendro_data(item_clust, type = "rectangle")

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

# Create the dendrogram plot (rotated to match heatmap item order)
dendro_plot <- ggplot(segment(dendro_data)) +
  geom_segment(aes(x = x, y = y, xend = xend, yend = yend), 
               linewidth = 0.6, color = "black") +
  coord_flip() +  # Rotate to match heatmap orientation
  scale_x_continuous(expand = c(0.01, 0.01)) +
  scale_y_reverse(expand = c(0.01, 0.01)) +  # Reverse y-axis to flip 180 degrees
  theme_void() +
  theme(
    plot.margin = margin(5, 2, 5, 5),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA)
  )

# Create the heatmap with ALL loadings
heatmap_plot <- ggplot(loadings_long, aes(x = Factor_Combined, y = Item, fill = Loading)) +
  geom_tile(color = "white", linewidth = 0.05) +
  scale_fill_gradient2(
    low = "#d73027", 
    mid = "white", 
    high = "#1a9850",
    midpoint = 0,
    limit = c(-1, 1),
    name = "Factor\nLoading"
  ) +
  # ALL loadings with different formatting
  # Primary loadings ≥ 0.40 in bold black
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "black",
    size = 2.2,
    fontface = "bold"
  ) +
  # Moderate loadings 0.30-0.39 in bold gray
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.30 & abs(Loading) < 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray20",
    size = 2.0,
    fontface = "bold"
  ) +
  # Small loadings 0.20-0.29 in gray
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.20 & abs(Loading) < 0.30),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray40",
    size = 1.8,
    fontface = "plain"
  ) +
  # Very small loadings < 0.20 in light gray
  geom_text(
    data = subset(loadings_long, abs(Loading) < 0.20),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray60",
    size = 1.6,
    fontface = "plain"
  ) +
  scale_y_discrete(position = "left") +  # Move item labels to the left
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 7, lineheight = 0.6),  # Smaller, tighter spacing
    axis.text.y = element_text(size = 7),  # Slightly larger item labels
    axis.title = element_text(size = 10),
    axis.title.y = element_blank(),  # Remove y-axis title
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    legend.key.size = unit(0.8, "cm"),
    panel.grid = element_blank(),
    plot.margin = margin(5, 5, 5, 2),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA)
  ) +
  labs(
    x = "Factors (ML1-ML7) with Post-Hoc Interpretations",
    y = ""
  )

# Combine the plots with appropriate widths
combined_plot <- grid.arrange(
  dendro_plot, heatmap_plot,
  ncol = 2,
  widths = c(0.25, 0.75),  # Dendrogram takes 25%, heatmap takes 75%
  top = textGrob("EFA Factor Loading Heatmap with Hierarchical Clustering\nGerman GCLS (N = 293) • All 266 loadings displayed • Items clustered by similarity", 
                 gp = gpar(fontsize = 12, fontface = "bold"),
                 just = "center")
)

# Save the combined plot
ggsave("manuscript/figures/efa_heatmap_dendro_combined.pdf", combined_plot, 
       width = 16, height = 12, units = "in", dpi = 300)
ggsave("manuscript/figures/efa_heatmap_dendro_combined.png", combined_plot, 
       width = 16, height = 12, units = "in", dpi = 300)

# Create a more compact version
dendro_compact <- ggplot(segment(dendro_data)) +
  geom_segment(aes(x = x, y = y, xend = xend, yend = yend), 
               linewidth = 0.5, color = "darkblue") +
  coord_flip() +
  scale_x_continuous(expand = c(0.01, 0.01)) +
  scale_y_reverse(expand = c(0.01, 0.01)) +  # Also reverse for compact version
  theme_void() +
  theme(
    plot.margin = margin(2, 1, 2, 2),
    panel.background = element_rect(fill = "white", color = NA)
  )

heatmap_compact <- ggplot(loadings_long, aes(x = Factor_Combined, y = Item, fill = Loading)) +
  geom_tile(color = "white", linewidth = 0.03) +
  scale_fill_gradient2(
    low = "#d73027", 
    mid = "white", 
    high = "#1a9850",
    midpoint = 0,
    limit = c(-1, 1),
    name = "Loading"
  ) +
  # Simplified text display - only show significant loadings
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.30),
    aes(label = sprintf("%.2f", Loading)),
    color = "black",
    size = 1.8,
    fontface = "bold"
  ) +
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.20 & abs(Loading) < 0.30),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray30",
    size = 1.6
  ) +
  scale_y_discrete(position = "left") +  # Also move to left in compact version
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 6, lineheight = 0.5),  # Even more compact
    axis.text.y = element_text(size = 6),  # Larger item labels
    axis.title = element_text(size = 9),
    axis.title.y = element_blank(),
    legend.title = element_text(size = 8),
    legend.text = element_text(size = 7),
    legend.key.size = unit(0.6, "cm"),
    panel.grid = element_blank(),
    plot.margin = margin(2, 2, 2, 1)
  ) +
  labs(x = "ML Factors with Interpretations")

# Compact combined version
combined_compact <- grid.arrange(
  dendro_compact, heatmap_compact,
  ncol = 2,
  widths = c(0.2, 0.8),
  top = textGrob("Complete EFA Loading Matrix with Dendrogram • All items clustered • Bold: ≥0.30", 
                 gp = gpar(fontsize = 11, fontface = "bold"))
)

# Save compact version
ggsave("manuscript/figures/efa_heatmap_dendro_compact.pdf", combined_compact, 
       width = 14, height = 10, units = "in", dpi = 300)
ggsave("manuscript/figures/efa_heatmap_dendro_compact.png", combined_compact, 
       width = 14, height = 10, units = "in", dpi = 300)

# Print summary
cat("Combined Dendrogram + Heatmap visualizations created!\n\n")

cat("Files saved:\n")
cat("- efa_heatmap_dendro_combined.pdf/png (detailed version with all loadings)\n")
cat("- efa_heatmap_dendro_compact.pdf/png (compact version, loadings ≥0.20)\n\n")

cat("Layout:\n")
cat("- Left: Hierarchical dendrogram (Ward's method, Euclidean distance)\n")
cat("- Right: Complete factor loading matrix with all 266 values\n")
cat("- Items ordered identically in both plots\n")
cat("- Color coding: Red (negative) → White (zero) → Green (positive)\n")
cat("- Text size reflects loading magnitude\n\n")

# Check clustering quality
cat("Clustering Quality:\n")
cat(sprintf("- Cophenetic correlation: %.3f\n", cor(cophenetic(item_clust), item_dist)))
cat(sprintf("- Total within-cluster sum of squares: %.2f\n", sum(item_clust$height)))

# Identify main clusters at different cut levels
for(k in c(5, 7, 10)) {
  clusters_k <- cutree(item_clust, k = k)
  cat(sprintf("- %d clusters: sizes = %s\n", k, paste(table(clusters_k), collapse = ", ")))
} 