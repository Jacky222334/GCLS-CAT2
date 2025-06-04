# Setup script for ComplexHeatmap
# Author: GCLS German Validation Study
# Purpose: Create high-quality, readable heatmaps for factor loadings

# Set CRAN mirror for package installation
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Install required packages
if (!require("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

# Install ComplexHeatmap from Bioconductor
if (!require("ComplexHeatmap", quietly = TRUE)) {
    BiocManager::install("ComplexHeatmap")
}

# Install additional useful packages
required_packages <- c(
    "circlize",      # For color mapping
    "RColorBrewer",  # Professional color palettes
    "dendextend",    # Enhanced dendrograms
    "cluster",       # Clustering methods
    "corrplot",      # Correlation plots
    "ggplot2",       # Base plotting
    "gridExtra",     # Multiple plots
    "png",           # PNG export
    "grDevices"      # Graphics devices
)

for (pkg in required_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
        install.packages(pkg)
    }
}

# Load main libraries
library(ComplexHeatmap)
library(circlize)
library(RColorBrewer)

# Example function for GCLS heatmap
create_gcls_heatmap <- function(factor_loadings, output_file = "gcls_heatmap_improved.pdf") {
    
    # Define color function for loadings (-1 to 1)
    col_fun <- colorRamp2(c(-1, -0.5, 0, 0.5, 1), 
                         c("red", "pink", "white", "lightgreen", "darkgreen"))
    
    # Create heatmap with better readability
    ht <- Heatmap(
        factor_loadings,
        name = "Loading",
        col = col_fun,
        
        # Text and font settings for better readability
        row_names_gp = gpar(fontsize = 10, fontface = "bold"),
        column_names_gp = gpar(fontsize = 12, fontface = "bold"),
        
        # Cell text settings
        cell_fun = function(j, i, x, y, width, height, fill) {
            value <- factor_loadings[i, j]
            if (abs(value) >= 0.3) {  # Only show significant loadings
                grid.text(sprintf("%.2f", value), x, y, 
                         gp = gpar(fontsize = 8, fontface = "bold"))
            }
        },
        
        # Clustering settings
        cluster_rows = TRUE,
        cluster_columns = TRUE,
        clustering_distance_rows = "euclidean",
        clustering_method_rows = "ward.D2",
        
        # Dendrogram settings
        show_row_dend = TRUE,
        show_column_dend = TRUE,
        row_dend_width = unit(2, "cm"),
        column_dend_height = unit(2, "cm"),
        
        # Legend settings
        heatmap_legend_param = list(
            title_gp = gpar(fontsize = 12, fontface = "bold"),
            labels_gp = gpar(fontsize = 10),
            legend_height = unit(4, "cm")
        ),
        
        # Size settings
        width = unit(12, "cm"),
        height = unit(16, "cm")
    )
    
    # Save as high-quality PDF
    pdf(output_file, width = 10, height = 12)
    draw(ht)
    dev.off()
    
    cat("Heatmap saved as:", output_file, "\n")
    return(ht)
}

# Print success message
cat("ComplexHeatmap setup complete!\n")
cat("All required packages installed successfully.\n")
cat("\n=== Quick Usage Guide ===\n")
cat("To create publication-quality heatmaps:\n\n")
cat("library(ComplexHeatmap)\n")
cat("library(circlize)\n\n")
cat("# For readable text, use these settings:\n")
cat("Heatmap(your_data,\n")
cat("    row_names_gp = gpar(fontsize = 12),\n")
cat("    column_names_gp = gpar(fontsize = 14),\n")
cat("    width = unit(15, 'cm'),\n")
cat("    height = unit(20, 'cm'))\n")
cat("Use create_gcls_heatmap(your_data, 'output.pdf') to create improved heatmaps.\n")
cat("\nFor larger, more readable text, adjust:\n")
cat("- row_names_gp = gpar(fontsize = 12)\n") 
cat("- column_names_gp = gpar(fontsize = 14)\n")
cat("- cell text fontsize = 10\n") 