# Create Improved GCLS-G EFA Heatmap with ComplexHeatmap
# Author: GCLS-G German Validation Study
# Purpose: Generate publication-quality heatmap with large, readable text

suppressPackageStartupMessages({
    library(ComplexHeatmap)
    library(circlize)
    library(RColorBrewer)
    library(jsonlite)
    library(dendextend)
})

cat("Creating improved GCLS-G EFA heatmap...\n")

# Load factor loading data from JSON
efa_data <- fromJSON("efa_factor_loadings.json")

# Extract factor loadings into matrix format
items_df <- efa_data$items
n_items <- nrow(items_df)
factor_names <- c("Soc", "Gen", "Psych", "Chest", "Life", "Intim", "Sec")
n_factors <- length(factor_names)

# Variance explained by each factor (from EFA results)
variance_explained <- c(10.1, 10.0, 9.5, 8.6, 7.7, 6.6, 5.6)

# Define distinct colors for each factor/subscale
factor_colors <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2")
names(factor_colors) <- factor_names

cat("Factor colors assigned:\n")
for(i in 1:length(factor_names)) {
    cat("  ", factor_names[i], ":", factor_colors[i], "\n")
}

# Create loading matrix directly from the loadings data.frame
loading_matrix <- as.matrix(items_df$loadings)
rownames(loading_matrix) <- paste0("Item", items_df$item_number)

# Add variance explained to column names
colnames(loading_matrix) <- paste0(factor_names, "\n(", variance_explained, "%)")

# Determine primary factor for each item (for row coloring)
primary_factors <- apply(abs(loading_matrix), 1, which.max)
item_colors <- factor_colors[primary_factors]
names(item_colors) <- rownames(loading_matrix)

# Create colored dendrogram for rows (items)
row_dist <- dist(loading_matrix, method = "euclidean")
row_hclust <- hclust(row_dist, method = "ward.D2")
row_dend <- as.dendrogram(row_hclust)

# Color the dendrogram branches based on factor groups
row_dend_colored <- color_branches(row_dend, k = 7, col = factor_colors)

cat("Loading matrix created:", dim(loading_matrix)[1], "items x", dim(loading_matrix)[2], "factors\n")
cat("Variance explained:", paste0(variance_explained, "%", collapse = ", "), "\n")
cat("Colored dendrogram created for", length(unique(primary_factors)), "factor groups\n")

# Define RAINBOW color scheme for factor loadings
# Uses a spectral/rainbow palette from blue (negative) through green to red (positive)
col_fun <- colorRamp2(c(-0.8, -0.4, -0.2, 0, 0.2, 0.4, 0.8), 
                     c("#2166AC", "#4393C3", "#92C5DE", "#F7F7F7", "#FDBF6F", "#FF7F00", "#D73027"))

# Create improved heatmap with rainbow colors and all numbers
ht <- Heatmap(
    loading_matrix,
    name = "Factor\nLoading",
    col = col_fun,
    
    # Color-coded row names based on primary factor
    row_names_gp = gpar(fontsize = 12, fontface = "bold", 
                       col = item_colors),
    
    # Color-coded column names to match factors
    column_names_gp = gpar(fontsize = 12, fontface = "bold", 
                          col = rep(factor_colors, length.out = ncol(loading_matrix))),
    
    # Show ALL loading values, but make weak ones lighter
    cell_fun = function(j, i, x, y, width, height, fill) {
        value <- loading_matrix[i, j]
        
        # Always show all values, but style them differently
        if (abs(value) >= 0.40) {
            # Strong loadings: large, bold, black text
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 11, fontface = "bold", col = "black"))
        } else if (abs(value) >= 0.30) {
            # Moderate loadings: medium, bold, dark gray
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 9, fontface = "bold", col = "gray20"))
        } else if (abs(value) >= 0.20) {
            # Small loadings: smaller, normal, gray
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 8, fontface = "plain", col = "gray40"))
        } else {
            # Very small loadings: smallest, light gray
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 7, fontface = "plain", col = "gray60"))
        }
    },
    
    # Use the colored dendrogram for rows
    cluster_rows = row_dend_colored,
    cluster_columns = TRUE,
    clustering_distance_columns = "euclidean", 
    clustering_method_columns = "ward.D2",
    
    # Show colored dendrograms
    show_row_dend = TRUE,
    show_column_dend = TRUE,
    row_dend_width = unit(3, "cm"),
    column_dend_height = unit(2, "cm"),
    
    # Size settings for optimal readability in publications
    width = unit(16, "cm"),
    height = unit(20, "cm"),
    
    # Legend with large, readable text
    heatmap_legend_param = list(
        title_gp = gpar(fontsize = 14, fontface = "bold"),
        labels_gp = gpar(fontsize = 12),
        legend_height = unit(5, "cm"),
        at = c(-0.8, -0.4, -0.2, 0, 0.2, 0.4, 0.8),
        labels = c("-0.8", "-0.4", "-0.2", "0.0", "0.2", "0.4", "0.8")
    ),
    
    # Border settings
    border = TRUE,
    
    # Column and row title settings
    column_title = "GCLS-G Factors",
    column_title_gp = gpar(fontsize = 16, fontface = "bold"),
    row_title = "GCLS-G Items",
    row_title_gp = gpar(fontsize = 16, fontface = "bold"),
    
    # ONLY top annotation with variance percentages (clean layout)
    top_annotation = HeatmapAnnotation(
        "Variance\nExplained" = anno_text(
            paste0(variance_explained, "%"),
            gp = gpar(fontsize = 11, fontface = "bold", 
                     col = rep(factor_colors, length.out = length(variance_explained)))
        ),
        annotation_height = unit(1.5, "cm")
    )
)

# Save as high-quality PDF with optimal dimensions
output_file <- "manuscript/figures/efa_heatmap_complexheatmap_improved.pdf"
cat("Saving improved GCLS-G rainbow heatmap with colored dendrograms to:", output_file, "\n")

pdf(output_file, width = 14, height = 11)
draw(ht, heatmap_legend_side = "right")
dev.off()

cat("✅ Improved GCLS-G EFA heatmap saved successfully!\n")
cat("✅ Features:\n")
cat("   - RAINBOW COLORS (spectral palette)\n")
cat("   - ALL NUMBERS SHOWN (different text weights)\n")
cat("   - VARIANCE % ONLY ON TOP (clean layout)\n")
cat("   - COLOR-CODED FACTOR LABELS (columns)\n")
cat("   - COLOR-CODED ITEM LABELS (rows by primary factor)\n")
cat("   - COLORED LEFT DENDROGRAM (factor-based grouping)\n")
cat("   - NO BOTTOM ANNOTATIONS (clean appearance)\n")
cat("   - Strong loadings (≥0.40): Large, bold, black\n")
cat("   - Moderate loadings (0.30-0.39): Medium, bold, dark gray\n")
cat("   - Small loadings (0.20-0.29): Small, normal, gray\n")
cat("   - Very small (<0.20): Smallest, light gray\n")
cat("   - Hierarchical clustering with colored dendrograms\n")
cat("   - Publication-ready dimensions\n")

# Create a compact version as well
cat("\nCreating compact GCLS-G version with colored dendrograms...\n")

# Create colored dendrogram for compact version
row_dend_compact <- color_branches(row_dend, k = 7, col = factor_colors)

# Create compact loading matrix
loading_matrix_compact <- loading_matrix
colnames(loading_matrix_compact) <- paste0(factor_names, "\n(", variance_explained, "%)")

ht_compact <- Heatmap(
    loading_matrix_compact,
    name = "Loading",
    col = col_fun,
    
    # Color-coded row names in compact version
    row_names_gp = gpar(fontsize = 10, fontface = "bold",
                       col = item_colors),
    
    # Color-coded column names for compact version
    column_names_gp = gpar(fontsize = 10, fontface = "bold",
                          col = rep(factor_colors, length.out = ncol(loading_matrix_compact))),
    
    # Show all values with different prominence
    cell_fun = function(j, i, x, y, width, height, fill) {
        value <- loading_matrix_compact[i, j]
        
        if (abs(value) >= 0.40) {
            # Strong loadings: bold and dark
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 9, fontface = "bold", col = "black"))
        } else if (abs(value) >= 0.20) {
            # Weaker loadings: smaller and lighter
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 7, fontface = "plain", col = "gray50"))
        } else {
            # Very weak loadings: very small and light
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 6, fontface = "plain", col = "gray70"))
        }
    },
    
    # Use colored dendrogram for compact version
    cluster_rows = row_dend_compact,
    cluster_columns = TRUE,
    show_row_dend = TRUE,
    show_column_dend = TRUE,
    row_dend_width = unit(2, "cm"),
    column_dend_height = unit(1.5, "cm"),
    
    # Compact size
    width = unit(12, "cm"),
    height = unit(15, "cm"),
    
    # Compact legend
    heatmap_legend_param = list(
        title_gp = gpar(fontsize = 12, fontface = "bold"),
        labels_gp = gpar(fontsize = 10),
        legend_height = unit(3, "cm")
    ),
    
    # Compact titles
    column_title = "GCLS-G Factors",
    column_title_gp = gpar(fontsize = 14, fontface = "bold"),
    row_title = "Items",
    row_title_gp = gpar(fontsize = 14, fontface = "bold")
)

# Save compact version
output_file_compact <- "manuscript/figures/efa_heatmap_complexheatmap_compact.pdf"
pdf(output_file_compact, width = 11, height = 9)
draw(ht_compact)
dev.off()

cat("✅ Compact GCLS-G version with colored dendrograms saved as:", output_file_compact, "\n")
cat("✅ Both GCLS-G rainbow versions with clean layout ready for manuscript!\n")
cat("✅ Total variance explained by all 7 factors:", sum(variance_explained), "%\n")

# Print color scheme for reference
cat("\n🎨 Factor Color Scheme:\n")
for(i in 1:length(factor_names)) {
    cat("   ", factor_names[i], ":", factor_colors[i], "\n")
} 