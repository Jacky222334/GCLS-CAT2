# Load required packages
library(psych)
library(ggplot2)
library(dendextend)
library(reshape2)
library(viridis)
library(pheatmap)

# Function to create EFA visualization with heatmap and dendrogram
visualize_efa_results <- function(loadings_matrix, 
                                cutoff_primary = 0.4, 
                                cutoff_cross = 0.3) {
  
  # Input validation
  if (!is.matrix(loadings_matrix) && !is.data.frame(loadings_matrix)) {
    stop("loadings_matrix must be a matrix or data frame")
  }
  
  # Convert loadings to matrix if not already
  loadings <- as.matrix(loadings_matrix)
  
  # Verify data
  if (any(is.na(loadings))) {
    warning("Missing values detected in loadings matrix")
  }
  
  if (any(abs(loadings) > 1)) {
    warning("Loadings greater than 1 detected - please check standardization")
  }
  
  # Create annotation for primary loadings
  is_primary <- abs(loadings) >= cutoff_primary
  annotation_row <- data.frame(
    Primary_Loading = factor(apply(is_primary, 1, any)),
    row.names = rownames(loadings)
  )
  
  # Create color palette with better contrast for colorblind accessibility
  colors <- viridis(100, option = "magma", direction = -1)  # Reversed for better contrast
  breaks <- seq(-1, 1, length.out = 100)
  
  # Ensure output directory exists
  dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
  
  # Create heatmap with improved visibility
  pheatmap(
    loadings,
    color = colors,
    breaks = breaks,
    display_numbers = matrix(
      ifelse(abs(loadings) >= cutoff_cross,
             sprintf("%.2f", loadings),
             ""),
      nrow = nrow(loadings)
    ),
    annotation_row = annotation_row,
    cluster_cols = FALSE,
    fontsize = 14,          # Größere Basisschriftgröße
    fontsize_row = 12,      # Größere Zeilenbeschriftung
    fontsize_col = 12,      # Größere Spaltenbeschriftung
    fontsize_number = 10,   # Größere Zahlen
    main = "EFA Results with Hierarchical Clustering",
    filename = "output/figures/efa_heatmap_dendrogram.pdf",
    width = 15,            # Breiteres Format
    height = 20,           # Höheres Format
    border_color = "white",
    cellwidth = 30,        # Breitere Zellen
    cellheight = 15,       # Höhere Zellen
    annotation_colors = list(
      Primary_Loading = c("TRUE" = "#000000", "FALSE" = "#E0E0E0")
    ),
    annotation_names_row = FALSE,
    clustering_distance_rows = "euclidean",
    clustering_method = "ward.D2",
    treeheight_row = 100   # Größerer Dendrogramm
  )
}

# Example usage (replace with your actual data):
# Assuming 'efa_results' contains your EFA results from psych::fa()
# loadings <- efa_results$loadings

# Create visualization
# ht <- visualize_efa_results(loadings)
# draw(ht)

# Save plot
# pdf("efa_heatmap_dendrogram.pdf", width = 12, height = 10)
# draw(ht)
# dev.off()

# Additional function for separate dendrogram visualization
plot_item_dendrogram <- function(loadings_matrix) {
  # Input validation
  if (!is.matrix(loadings_matrix) && !is.data.frame(loadings_matrix)) {
    stop("loadings_matrix must be a matrix or data frame")
  }
  
  # Ensure output directory exists
  dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
  
  # Calculate distance matrix
  item_dist <- dist(as.matrix(loadings_matrix), method = "euclidean")
  item_hclust <- hclust(item_dist, method = "ward.D2")
  
  # Create and customize dendrogram
  dend <- as.dendrogram(item_hclust)
  dend <- color_branches(dend, k = 7)  # 7 factors
  dend <- set(dend, "labels_cex", 1.2)  # Größere Beschriftungen
  
  # Plot dendrogram with improved visibility
  pdf("output/figures/item_clustering_dendrogram.pdf", width = 15, height = 20)  # Größeres Format
  par(mar = c(4, 8, 4, 8))  # Mehr Platz für Beschriftungen
  plot(dend,
       main = "Hierarchical Clustering of GCLS Items",
       horiz = TRUE,
       axes = TRUE,
       cex.main = 1.5,    # Größerer Titel
       cex.axis = 1.2,    # Größere Achsenbeschriftung
       ylab = "Items",    # Y-Achsenbeschriftung
       xlab = "Height")   # X-Achsenbeschriftung
  dev.off()
} 