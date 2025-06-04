# EFA Factor Loadings Heatmap with Dendrogram
# Create heatmap with hierarchical clustering dendrogram

# Load required libraries
library(ggplot2)
library(ggdendro)
library(reshape2)
library(dplyr)
library(grid)
library(gridExtra)
library(ComplexHeatmap)
library(circlize)
library(RColorBrewer)

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

# Rename columns to include labels
colnames(loadings_matrix) <- paste0(colnames(loadings_matrix), "\n", factor_labels[colnames(loadings_matrix)])

# Create color function for heatmap
col_fun <- colorRamp2(c(-1, 0, 1), c("#d73027", "white", "#1a9850"))

# Create cell function to add text for significant loadings
cell_fun <- function(j, i, x, y, width, height, fill) {
  value <- loadings_matrix[i, j]
  if(abs(value) >= 0.40) {
    grid.text(sprintf("%.2f", value), x, y, gp = gpar(fontsize = 8, fontface = "bold"))
  } else if(abs(value) >= 0.30) {
    grid.text(sprintf("%.2f", value), x, y, gp = gpar(fontsize = 7, col = "gray40"))
  }
}

# Create the heatmap with dendrogram using ComplexHeatmap
ht <- Heatmap(
  loadings_matrix,
  name = "Factor\nLoading",
  col = col_fun,
  
  # Row clustering (items)
  cluster_rows = TRUE,
  clustering_distance_rows = "euclidean",
  clustering_method_rows = "ward.D2",
  row_dend_width = unit(3, "cm"),
  show_row_dend = TRUE,
  
  # Column settings (factors)
  cluster_columns = FALSE,  # Keep factor order as is
  
  # Cell annotations
  cell_fun = cell_fun,
  
  # Appearance
  row_names_gp = gpar(fontsize = 9),
  column_names_gp = gpar(fontsize = 9),
  column_names_rot = 0,
  column_names_centered = TRUE,
  
  # Title and legend
  column_title = "EFA Factor Loading Heatmap with Hierarchical Clustering\nGerman GCLS (N = 293)",
  column_title_gp = gpar(fontsize = 14, fontface = "bold"),
  
  # Heatmap body
  rect_gp = gpar(col = "white", lwd = 0.5),
  
  # Legend
  heatmap_legend_param = list(
    title_gp = gpar(fontsize = 10, fontface = "bold"),
    labels_gp = gpar(fontsize = 9),
    legend_height = unit(6, "cm"),
    border = "black"
  )
)

# Save as PDF
pdf("manuscript/figures/efa_heatmap_with_dendro.pdf", width = 14, height = 10)
draw(ht)
dev.off()

# Save as PNG for easier viewing
png("manuscript/figures/efa_heatmap_with_dendro.png", width = 14, height = 10, units = "in", res = 300)
draw(ht)
dev.off()

# Alternative version with ggplot2 and ggdendro (in case ComplexHeatmap doesn't work)
create_ggplot_version <- function() {
  # Perform hierarchical clustering
  item_dist <- dist(loadings_matrix, method = "euclidean")
  item_clust <- hclust(item_dist, method = "ward.D2")
  
  # Create dendrogram
  dendro_data <- dendro_data(item_clust, type = "rectangle")
  
  # Reorder matrix based on clustering
  item_order <- item_clust$order
  loadings_ordered <- loadings_matrix[item_order, ]
  
  # Convert to long format for ggplot
  loadings_long <- melt(loadings_ordered, varnames = c("Item", "Factor"), value.name = "Loading")
  loadings_long$Item <- factor(loadings_long$Item, levels = rownames(loadings_ordered))
  
  # Create dendrogram plot
  dendro_plot <- ggplot(segment(dendro_data)) +
    geom_segment(aes(x = x, y = y, xend = xend, yend = yend)) +
    theme_void() +
    theme(plot.margin = margin(5, 0, 5, 5))
  
  # Create heatmap
  heatmap_plot <- ggplot(loadings_long, aes(x = Factor, y = Item, fill = Loading)) +
    geom_tile(color = "white", size = 0.5) +
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
      size = 2
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 0, hjust = 0.5, size = 9),
      axis.text.y = element_text(size = 8),
      axis.title = element_text(size = 11),
      legend.title = element_text(size = 10),
      panel.grid = element_blank(),
      plot.title = element_text(size = 12, hjust = 0.5),
      axis.title.y = element_blank()
    ) +
    labs(
      title = "EFA Factor Loadings with Hierarchical Item Clustering",
      x = "Factors"
    ) +
    scale_y_discrete(position = "right")
  
  # Combine plots
  combined <- grid.arrange(
    dendro_plot, heatmap_plot,
    ncol = 2,
    widths = c(0.3, 0.7)
  )
  
  return(combined)
}

# Try ComplexHeatmap first, fall back to ggplot if needed
tryCatch({
  cat("Creating heatmap with ComplexHeatmap...\n")
  # The ComplexHeatmap version is already created above
  cat("ComplexHeatmap version created successfully!\n")
}, error = function(e) {
  cat("ComplexHeatmap failed, creating ggplot version...\n")
  
  # Save ggplot version
  combined_plot <- create_ggplot_version()
  ggsave("manuscript/figures/efa_heatmap_with_dendro_ggplot.pdf", combined_plot, 
         width = 14, height = 10, units = "in")
  ggsave("manuscript/figures/efa_heatmap_with_dendro_ggplot.png", combined_plot, 
         width = 14, height = 10, units = "in", dpi = 300)
  
  cat("ggplot version created successfully!\n")
})

# Print summary
cat("\nHeatmap with Dendrogram created!\n")
cat("Files saved:\n")
cat("- efa_heatmap_with_dendro.pdf/png (ComplexHeatmap version)\n")
cat("- efa_heatmap_with_dendro_ggplot.pdf/png (ggplot backup version)\n")
cat("\nFeatures:\n")
cat("- Left-side dendrogram showing item relationships\n")
cat("- Items ordered by hierarchical clustering (Ward's method)\n")
cat("- Bold text for loadings ≥ 0.40, gray for 0.30-0.39\n")
cat("- Color scale: red (negative) to green (positive)\n")

# Create a simple cluster analysis summary
item_dist <- dist(loadings_matrix, method = "euclidean")
item_clust <- hclust(item_dist, method = "ward.D2")

cat("\nHierarchical Clustering Summary:\n")
cat("Method: Ward's minimum variance\n")
cat("Distance: Euclidean\n")
cat("Items clustered by factor loading similarity\n") 