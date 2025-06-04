# Test ComplexHeatmap Installation
cat("Testing ComplexHeatmap...\n")

# Check if packages are available
packages_needed <- c("ComplexHeatmap", "circlize", "RColorBrewer")
missing_packages <- c()

for (pkg in packages_needed) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
        missing_packages <- c(missing_packages, pkg)
    }
}

if (length(missing_packages) > 0) {
    cat("Missing packages:", paste(missing_packages, collapse = ", "), "\n")
    cat("Attempting installation...\n")
    
    # Set compiler flags
    Sys.setenv("PKG_CFLAGS" = "-std=gnu17")
    
    if (!require("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
    }
    
    for (pkg in missing_packages) {
        if (pkg == "ComplexHeatmap") {
            BiocManager::install(pkg)
        } else {
            install.packages(pkg)
        }
    }
}

# Test if everything works
if (require("ComplexHeatmap", quietly = TRUE)) {
    cat("✅ ComplexHeatmap is available!\n")
    cat("Version:", as.character(packageVersion("ComplexHeatmap")), "\n")
    
    # Create a simple test heatmap
    test_matrix <- matrix(rnorm(50), 10, 5)
    rownames(test_matrix) <- paste0("Item", 1:10)
    colnames(test_matrix) <- paste0("Factor", 1:5)
    
    cat("Creating test heatmap...\n")
    
    # Create heatmap with large, readable text
    ht <- Heatmap(
        test_matrix,
        name = "Loading",
        
        # Large text for better readability
        row_names_gp = gpar(fontsize = 14, fontface = "bold"),
        column_names_gp = gpar(fontsize = 16, fontface = "bold"),
        
        # Show values in cells
        cell_fun = function(j, i, x, y, width, height, fill) {
            grid.text(sprintf("%.2f", test_matrix[i, j]), x, y, 
                     gp = gpar(fontsize = 10, fontface = "bold"))
        },
        
        # Size settings for better visibility
        width = unit(15, "cm"),
        height = unit(20, "cm"),
        
        # Legend with larger text
        heatmap_legend_param = list(
            title_gp = gpar(fontsize = 14, fontface = "bold"),
            labels_gp = gpar(fontsize = 12)
        )
    )
    
    # Save test heatmap
    pdf("test_heatmap_large_text.pdf", width = 12, height = 8)
    draw(ht)
    dev.off()
    
    cat("✅ Test heatmap saved as 'test_heatmap_large_text.pdf'\n")
    cat("✅ ComplexHeatmap is ready for GCLS graphics!\n")
    
} else {
    cat("❌ ComplexHeatmap installation failed\n")
} 