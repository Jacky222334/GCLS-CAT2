# Create Complete GCLS-G EFA Heatmap with All 38 Items
# Author: GCLS-G German Validation Study
# Purpose: Generate publication-quality heatmap with all 38 items including Item 26

suppressPackageStartupMessages({
    library(ComplexHeatmap)
    library(circlize)
    library(RColorBrewer)
    library(dendextend)
    library(grDevices)
})

cat("Creating complete GCLS-G EFA heatmap with all 38 items...\n")

# Load complete 38-item factor loading data
loadings_data <- read.csv("analysis/factor_analysis/factor_loadings_38items.csv", row.names = 1)

cat("Loaded", nrow(loadings_data), "items x", ncol(loadings_data), "factors\n")

# Create loading matrix
loading_matrix <- as.matrix(loadings_data)
rownames(loading_matrix) <- paste0("Item", 1:38)

# Assign factor names based on original GCLS structure
factor_names <- c("Soc", "Gen", "Psych", "Chest", "Life", "Intim", "Sec")
colnames(loading_matrix) <- factor_names

# Estimate variance explained (approximation based on factor loadings)
ss_loadings <- colSums(loading_matrix^2)
total_ss <- sum(ss_loadings)
variance_explained <- round((ss_loadings / total_ss) * 100, 1)

cat("Estimated variance explained:", paste0(variance_explained, "%", collapse = ", "), "\n")

# Define distinct colors for each factor/subscale  
factor_colors <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2")
names(factor_colors) <- factor_names

# Create lighter versions of colors for bars (30% weaker)
factor_colors_light <- adjustcolor(factor_colors, alpha.f = 0.7)  # 30% transparency
names(factor_colors_light) <- factor_names

# Clean column names without variance percentages
colnames(loading_matrix) <- factor_names

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

# Create colored dendrogram for columns (factors)
col_dist <- dist(t(loading_matrix), method = "euclidean")
col_hclust <- hclust(col_dist, method = "ward.D2")
col_dend <- as.dendrogram(col_hclust)

# Color the column dendrogram branches
col_dend_colored <- color_branches(col_dend, k = 7, col = factor_colors)

cat("Colored dendrograms created for", length(unique(primary_factors)), "factor groups\n")

# Define RAINBOW color scheme for factor loadings
col_fun <- colorRamp2(c(-0.8, -0.4, -0.2, 0, 0.2, 0.4, 0.8), 
                     c("#2166AC", "#4393C3", "#92C5DE", "#F7F7F7", "#FDBF6F", "#FF7F00", "#D73027"))

# Create complete heatmap with all 38 items
ht <- Heatmap(
    loading_matrix,
    name = "Factor\nLoading",
    col = col_fun,
    
    # Color-coded row names based on primary factor
    row_names_gp = gpar(fontsize = 11, fontface = "bold", 
                       col = item_colors),
    
    # Color-coded column names to match factors
    column_names_gp = gpar(fontsize = 12, fontface = "bold", 
                          col = rep(factor_colors, length.out = ncol(loading_matrix))),
    
    # Show ALL loading values with hierarchical emphasis
    cell_fun = function(j, i, x, y, width, height, fill) {
        value <- loading_matrix[i, j]
        
        if (abs(value) >= 0.40) {
            # Strong loadings: large, bold, black text
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 18, fontface = "bold", col = "black"))
        } else if (abs(value) >= 0.30) {
            # Moderate loadings: medium, bold, dark gray
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 16, fontface = "bold", col = "gray20"))
        } else if (abs(value) >= 0.20) {
            # Small loadings: smaller, normal, gray
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 14, fontface = "plain", col = "gray40"))
        } else {
            # Very small loadings: smallest, light gray
            grid.text(sprintf("%.2f", value), x, y, 
                     gp = gpar(fontsize = 12, fontface = "plain", col = "gray60"))
        }
    },
    
    # Use the colored dendrograms for both rows and columns
    cluster_rows = row_dend_colored,
    cluster_columns = col_dend_colored,
    
    # Show colored dendrograms
    show_row_dend = TRUE,
    show_column_dend = TRUE,
    row_dend_width = unit(3, "cm"),
    column_dend_height = unit(2, "cm"),
    
    # Size settings for all 38 items
    width = unit(16, "cm"),
    height = unit(22, "cm"),  # Taller for 38 items
    
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
    column_title = "GCLS-G Factors (All 38 Items)",
    column_title_gp = gpar(fontsize = 16, fontface = "bold"),
    row_title = "GCLS-G Items",
    row_title_gp = gpar(fontsize = 16, fontface = "bold"),
    
    # Top annotation with variance percentages as VERTICAL BARS
    top_annotation = HeatmapAnnotation(
        "Variance\nExplained" = anno_barplot(
            variance_explained,
            gp = gpar(fill = factor_colors_light, col = "black", lwd = 1),
            bar_width = 0.8,
            height = unit(3, "cm"),
            axis = TRUE,
            axis_param = list(
                side = "left",
                gp = gpar(fontsize = 10)
            )
        ),
        annotation_height = unit(4, "cm"),
        annotation_name_gp = gpar(fontsize = 12, fontface = "bold")
    )
)

# Save the complete 38-item heatmap
output_file <- "manuscript/figures/efa_heatmap_gcls_38items.pdf"
cat("Saving complete GCLS-G heatmap with all 38 items to:", output_file, "\n")

pdf(output_file, width = 15, height = 12)  # Larger for 38 items
draw(ht, heatmap_legend_side = "right")
dev.off()

cat("✅ Complete GCLS-G EFA heatmap with all 38 items saved successfully!\n")
cat("✅ Features:\n")
cat("   - ALL 38 ITEMS INCLUDING ITEM 26\n")
cat("   - RAINBOW COLORS (spectral palette)\n")
cat("   - ALL NUMBERS SHOWN (hierarchical emphasis)\n")
cat("   - VARIANCE % FOR EACH FACTOR\n")
cat("   - COLOR-CODED FACTOR LABELS\n")
cat("   - COLOR-CODED ITEM LABELS (by primary factor)\n")
cat("   - COLORED DENDROGRAMS (factor-based grouping)\n")
cat("   - Publication-ready quality\n")

# Print color scheme for reference
cat("\n🎨 Factor Color Scheme:\n")
for(i in 1:length(factor_names)) {
    cat("   ", factor_names[i], ":", factor_colors[i], "\n")
}

cat("\n📊 Item 26 included with loadings:\n")
item26_loadings <- loading_matrix[26, ]
for(j in 1:length(item26_loadings)) {
    cat("   ", names(item26_loadings)[j], ":", sprintf("%.3f", item26_loadings[j]), "\n")
} 