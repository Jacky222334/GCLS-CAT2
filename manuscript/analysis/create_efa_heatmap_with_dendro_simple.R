# EFA Factor Loadings Heatmap with Dendrogram (Simple Version)
# Create heatmap with hierarchical clustering using base R

# Load required libraries (only base packages)
library(ggplot2)
library(reshape2)
library(dplyr)
library(grid)
library(gridExtra)

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

# Create a simple dendrogram plot using base R
pdf("manuscript/figures/efa_dendro_only.pdf", width = 12, height = 8)
plot(item_clust, 
     main = "Hierarchical Clustering of GCLS Items\n(Based on Factor Loading Patterns)",
     xlab = "Items", 
     ylab = "Distance",
     cex.main = 1.2,
     cex.lab = 1.1,
     las = 2,  # Rotate labels
     cex = 0.8)
dev.off()

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

# Create heatmap with clustered item order
heatmap_plot <- ggplot(loadings_long, aes(x = Factor_Combined, y = Item, fill = Loading)) +
  geom_tile(color = "white", linewidth = 0.2) +
  scale_fill_gradient2(
    low = "#d73027", 
    mid = "white", 
    high = "#1a9850",
    midpoint = 0,
    limit = c(-1, 1),
    name = "Factor\nLoading"
  ) +
  # Add text for significant loadings
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "black",
    size = 2.5,
    fontface = "bold"
  ) +
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.30 & abs(Loading) < 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray40",
    size = 2.2
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 9, lineheight = 0.8),
    axis.text.y = element_text(size = 8),
    axis.title = element_text(size = 11),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
    panel.grid = element_blank(),
    plot.title = element_text(size = 13, hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    plot.margin = margin(15, 15, 15, 15)
  ) +
  labs(
    title = "EFA Factor Loading Heatmap with Hierarchical Item Ordering",
    subtitle = "Items ordered by hierarchical clustering (Ward's method) • Primary loadings ≥ 0.40 in bold",
    x = "Factors (ML1-ML7)",
    y = "GCLS Items (Clustered Order)"
  )

# Save the heatmap
ggsave("manuscript/figures/efa_heatmap_clustered_order.pdf", heatmap_plot, 
       width = 12, height = 14, units = "in", dpi = 300)
ggsave("manuscript/figures/efa_heatmap_clustered_order.png", heatmap_plot, 
       width = 12, height = 14, units = "in", dpi = 300)

# Create a side-by-side visualization
# Convert dendrogram to ggplot-compatible format manually
get_dendro_data <- function(hc) {
  # Simple approach: extract dendrogram structure
  dend <- as.dendrogram(hc)
  
  # Get coordinates for plotting
  coords <- list()
  
  # For now, create a simple representation
  # This is a simplified version without ggdendro
  n_items <- length(hc$order)
  y_positions <- seq(1, n_items)
  
  return(data.frame(
    item = hc$labels[hc$order],
    y = y_positions,
    height = hc$height[hc$order] 
  ))
}

# Create a simplified combined plot showing clustering results
cluster_analysis <- cutree(item_clust, k = 7)  # Cut into 7 clusters
loadings_long$Cluster <- cluster_analysis[loadings_long$Item]

# Enhanced heatmap with cluster information
heatmap_with_clusters <- ggplot(loadings_long, aes(x = Factor_Combined, y = Item, fill = Loading)) +
  geom_tile(color = "white", linewidth = 0.2) +
  scale_fill_gradient2(
    low = "#d73027", 
    mid = "white", 
    high = "#1a9850",
    midpoint = 0,
    limit = c(-1, 1),
    name = "Factor\nLoading"
  ) +
  # Add cluster boundaries
  geom_hline(yintercept = cumsum(table(cluster_analysis)) + 0.5, 
             color = "blue", linewidth = 1, alpha = 0.7) +
  # Add text for significant loadings
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "black",
    size = 2.5,
    fontface = "bold"
  ) +
  geom_text(
    data = subset(loadings_long, abs(Loading) >= 0.30 & abs(Loading) < 0.40),
    aes(label = sprintf("%.2f", Loading)),
    color = "gray40",
    size = 2.2
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5, size = 9, lineheight = 0.8),
    axis.text.y = element_text(size = 8),
    axis.title = element_text(size = 11),
    legend.title = element_text(size = 10),
    panel.grid = element_blank(),
    plot.title = element_text(size = 13, hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(size = 10, hjust = 0.5),
    plot.margin = margin(15, 15, 15, 15)
  ) +
  labs(
    title = "EFA Factor Loading Heatmap with Item Clusters",
    subtitle = "Items grouped by hierarchical clustering • Blue lines = cluster boundaries • Loadings ≥ 0.40 in bold",
    x = "Factors (ML1-ML7)",
    y = "GCLS Items (Clustered Order)"
  )

# Save the enhanced version
ggsave("manuscript/figures/efa_heatmap_with_clusters.pdf", heatmap_with_clusters, 
       width = 12, height = 14, units = "in", dpi = 300)
ggsave("manuscript/figures/efa_heatmap_with_clusters.png", heatmap_with_clusters, 
       width = 12, height = 14, units = "in", dpi = 300)

# Print summary
cat("EFA Heatmap with Hierarchical Clustering created successfully!\n")
cat("\nFiles saved:\n")
cat("- efa_dendro_only.pdf (dendrogram only)\n")
cat("- efa_heatmap_clustered_order.pdf/png (heatmap with clustered item order)\n")
cat("- efa_heatmap_with_clusters.pdf/png (heatmap with cluster boundaries)\n")

cat("\nFeatures:\n")
cat("- Items ordered by hierarchical clustering (Ward's method, Euclidean distance)\n")
cat("- Blue lines show cluster boundaries\n")
cat("- Bold text for loadings ≥ 0.40, gray for 0.30-0.39\n")
cat("- Color scale: red (negative) to green (positive)\n")

# Print cluster summary
cat("\nCluster Analysis (7 clusters):\n")
for(i in 1:7) {
  cluster_items <- names(cluster_analysis)[cluster_analysis == i]
  cat(sprintf("Cluster %d (%d items): %s\n", i, length(cluster_items), 
              paste(cluster_items, collapse = ", ")))
}

# Create cluster summary table
cluster_summary <- data.frame(
  Cluster = 1:7,
  N_Items = as.numeric(table(cluster_analysis)),
  Items = sapply(1:7, function(i) paste(names(cluster_analysis)[cluster_analysis == i], collapse = ", "))
)

write.csv(cluster_summary, "manuscript/analysis/item_clusters_summary.csv", row.names = FALSE)
cat("\nCluster summary saved to: manuscript/analysis/item_clusters_summary.csv\n") 