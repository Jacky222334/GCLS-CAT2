# Load required packages
library(readxl)      # For reading Excel files
library(psych)       # For factor analysis
library(GPArotation) # For factor rotation
library(corrplot)    # For correlation visualization
library(nFactors)    # For determining number of factors
library(tidyverse)   # For data manipulation
library(ggplot2)     # For enhanced plotting
library(papaja)      # For APA style

# Create results directory
dir.create("efa_results", showWarnings = FALSE)

# Read the data
cat("Reading data...\n")
data <- read_excel("../../data/raw/dat_EFA_26.xlsx")

# Print initial data information
cat("\nInitial data structure:\n")
str(data)
cat("\nColumn names:\n")
print(colnames(data))

# Function to prepare data for EFA
prepare_data <- function(data) {
  # Select numeric columns
  numeric_data <- data %>% select_if(is.numeric)
  
  cat("\nNumeric columns selected:", ncol(numeric_data), "\n")
  cat("Numeric column names:\n")
  print(colnames(numeric_data))
  
  # Check for missing values
  missing_summary <- colSums(is.na(numeric_data))
  cat("\nMissing values per column:\n")
  print(missing_summary)
  
  # Remove columns with near-zero variance
  var_threshold <- 0.001
  vars <- apply(numeric_data, 2, var, na.rm = TRUE)
  cat("\nVariance per column:\n")
  print(vars)
  
  numeric_data <- numeric_data[, vars > var_threshold]
  
  # Handle missing values
  complete_data <- na.omit(numeric_data)
  
  cat("\nDimensions after cleaning:\n")
  cat("Original:", nrow(data), "rows,", ncol(data), "columns\n")
  cat("After cleaning:", nrow(complete_data), "rows,", ncol(complete_data), "columns\n")
  
  # Standardize the data
  scaled_data <- scale(complete_data)
  
  # Basic checks on scaled data
  cat("\nScaled data summary:\n")
  print(summary(scaled_data))
  
  return(list(
    data = scaled_data,
    removed_cols = names(vars[vars <= var_threshold]),
    complete_cases = nrow(complete_data)
  ))
}

# Function to check EFA suitability
check_efa_suitability <- function(data) {
  # Correlation matrix
  cor_matrix <- cor(data)
  
  # Save correlation matrix
  pdf("efa_results/correlation_matrix.pdf", width = 12, height = 12)
  corrplot(cor_matrix, method = "color", type = "upper", 
           tl.col = "black", tl.srt = 45, tl.cex = 0.7)
  dev.off()
  
  # KMO test
  kmo <- KMO(cor_matrix)
  
  # Bartlett's test
  bartlett <- cortest.bartlett(cor_matrix, n = nrow(data))
  
  # Save results
  sink("efa_results/suitability_tests.txt")
  cat("EFA Suitability Tests\n")
  cat("=====================\n\n")
  cat("KMO Test Results:\n")
  print(kmo)
  cat("\nBartlett's Test Results:\n")
  print(bartlett)
  sink()
  
  return(list(kmo = kmo$MSA, bartlett = bartlett))
}

# Function to determine number of factors
determine_factors <- function(data) {
  # Eigenvalues
  ev <- eigen(cor(data))
  
  cat("\nEigenvalues:\n")
  print(ev$values)
  
  # Parallel analysis
  pa <- parallel(subject = nrow(data), var = ncol(data),
                rep = 1000, cent = 0.95)
  
  # Scree plot with parallel analysis
  pdf("efa_results/scree_plot.pdf")
  scree(cor(data), factors = FALSE)
  abline(h = 1, col = "red", lty = 2)  # Kaiser criterion
  points(pa$eigen$qevpea, type = "l", col = "blue", lty = 2)  # Parallel analysis
  legend("topright", 
         legend = c("Actual", "Parallel Analysis", "Kaiser Criterion"),
         col = c("black", "blue", "red"),
         lty = c(1, 2, 2))
  dev.off()
  
  # VSS analysis
  vss_result <- VSS(data, rotate = "varimax")
  
  # Save results
  sink("efa_results/factor_determination.txt")
  cat("Factor Number Determination\n")
  cat("=========================\n\n")
  cat("Eigenvalues:\n")
  print(ev$values)
  cat("\nKaiser criterion suggestion:", sum(ev$values > 1), "\n")
  cat("Parallel Analysis Suggestion:", sum(ev$values > pa$eigen$qevpea), "\n")
  cat("\nVSS Analysis Results:\n")
  print(vss_result)
  sink()
  
  # Return 7 factors as requested
  return(7)
}

# Function to create APA-style scree plot
create_scree_plot <- function(data, pa_result) {
  # Calculate eigenvalues
  ev <- eigen(cor(data))
  
  # Create data frame for plotting
  n_factors <- length(ev$values)
  plot_data <- data.frame(
    Factor = 1:n_factors,
    Empirical = ev$values,
    Parallel = c(pa_result$eigen$qevpea, rep(NA, n_factors - length(pa_result$eigen$qevpea)))
  )
  
  # Create ggplot with APA style
  p <- ggplot(plot_data, aes(x = Factor)) +
    geom_line(aes(y = Empirical, linetype = "Empirical Eigenvalues"), 
              linewidth = 0.5) +
    geom_point(aes(y = Empirical), size = 2) +
    geom_line(aes(y = Parallel, linetype = "Parallel Analysis"), 
              linewidth = 0.5) +
    geom_hline(yintercept = 1, linetype = "dotted", linewidth = 0.5) +
    scale_linetype_manual(name = NULL,
                         values = c("Empirical Eigenvalues" = "solid", 
                                  "Parallel Analysis" = "dashed")) +
    theme_apa() +
    theme(
      legend.position = "bottom",
      legend.box.spacing = unit(0.5, "lines"),
      axis.text = element_text(size = 10),
      axis.title = element_text(size = 12)
    ) +
    labs(
      x = "Factor Number",
      y = "Eigenvalue",
      caption = "Note. Dotted line represents Kaiser criterion (eigenvalue = 1)."
    )
  
  # Save plot
  ggsave("efa_results/scree_plot_apa.pdf", p, 
         width = 6.5, height = 5, device = cairo_pdf)
}

# Function to create APA-style correlation heatmap
create_correlation_heatmap <- function(cor_matrix) {
  pdf("efa_results/correlation_matrix_apa.pdf", 
      width = 8.5, height = 8)
  corrplot(cor_matrix,
           method = "color",
           type = "upper",
           tl.col = "black",
           tl.srt = 45,
           tl.cex = 0.7,
           cl.cex = 0.7,
           addCoef.col = "black",
           number.cex = 0.5,
           col = colorRampPalette(c("#000000", "#FFFFFF"))(200),
           diag = FALSE,
           title = "Inter-Item Correlation Matrix",
           mar = c(0,0,1.5,0))
  dev.off()
}

# Function to create APA-style factor loading plot
create_factor_loading_plot <- function(fa_result, rotation_name) {
  # Create loading matrix with only significant loadings (> 0.3)
  loadings <- fa_result$loadings
  loadings[abs(loadings) < 0.3] <- NA
  
  # Convert to data frame
  load_df <- as.data.frame(unclass(loadings))
  load_df$Item <- rownames(loadings)
  
  # Reshape for ggplot
  load_long <- load_df %>%
    gather(Factor, Loading, -Item) %>%
    filter(!is.na(Loading))
  
  # Create plot with APA style
  p <- ggplot(load_long, aes(x = Factor, y = Item)) +
    geom_tile(aes(fill = Loading), color = "white") +
    scale_fill_gradient2(low = "white", mid = "gray80", high = "black",
                        midpoint = 0, limits = c(-1, 1),
                        name = "Factor\nLoading") +
    theme_apa() +
    theme(
      axis.text.x = element_text(angle = 0, size = 10),
      axis.text.y = element_text(size = 8),
      legend.position = "right",
      legend.key.size = unit(0.8, "lines"),
      plot.caption = element_text(size = 8, hjust = 0)
    ) +
    labs(
      title = paste("Factor Loadings -", rotation_name, "Rotation"),
      x = "Factor",
      y = "Item",
      caption = "Note. Only loadings > |0.30| are shown. Darker shading indicates stronger positive loadings."
    )
  
  # Save plot
  ggsave(paste0("efa_results/loadings_", tolower(rotation_name), "_apa.pdf"),
         p, width = 8.5, height = 11, device = cairo_pdf)
  
  # Create additional table format for publication
  loadings_table <- round(unclass(loadings), 3)
  loadings_table[abs(loadings_table) < 0.3] <- NA
  write.csv(loadings_table, 
            paste0("efa_results/loadings_", tolower(rotation_name), "_table.csv"))
}

# Function to create factor correlation table (for oblique rotations)
create_factor_correlation_table <- function(fa_result, rotation_name) {
  if (!rotation_name == "Varimax") {
    factor_cors <- round(fa_result$Phi, 3)
    write.csv(factor_cors,
              paste0("efa_results/factor_correlations_", tolower(rotation_name), ".csv"))
  }
}

# Function to compare different factor solutions
compare_factor_solutions <- function(data, max_factors = 8) {
  results <- data.frame(
    Factors = 3:max_factors,
    RMSEA = NA,
    TLI = NA,
    BIC = NA,
    ChiSq = NA,
    df = NA,
    p_value = NA
  )
  
  for(i in 3:max_factors) {
    fa_result <- fa(data, nfactors = i, rotate = "varimax", fm = "ml")
    results$RMSEA[i-2] <- fa_result$RMSEA[1]
    results$TLI[i-2] <- fa_result$TLI
    results$BIC[i-2] <- fa_result$BIC
    results$ChiSq[i-2] <- fa_result$chi
    results$df[i-2] <- fa_result$dof
    results$p_value[i-2] <- fa_result$PVAL
  }
  
  # Save comparison results
  write.csv(results, "efa_results/factor_comparison.csv")
  
  # Create comparison plot
  p <- results %>%
    gather(Metric, Value, -Factors) %>%
    filter(Metric %in% c("RMSEA", "TLI")) %>%
    ggplot(aes(x = Factors, y = Value, group = Metric)) +
    geom_line() +
    geom_point() +
    facet_wrap(~Metric, scales = "free_y") +
    theme_apa() +
    labs(
      x = "Number of Factors",
      y = "Fit Index Value",
      caption = "Note. RMSEA = Root Mean Square Error of Approximation; TLI = Tucker-Lewis Index."
    )
  
  ggsave("efa_results/factor_comparison_plot.pdf", p, 
         width = 8, height = 4, device = cairo_pdf)
  
  return(results)
}

# Main analysis function
main <- function() {
  # Read and prepare data
  cat("Reading data...\n")
  data <- read_excel("../../data/raw/dat_EFA_26.xlsx")
  
  # Prepare data
  prep_result <- prepare_data(data)
  prepared_data <- prep_result$data
  
  # Compare different factor solutions
  cat("\nComparing different factor solutions...\n")
  comparison_results <- compare_factor_solutions(prepared_data)
  print(comparison_results)
  
  # Create publication-quality plots
  pa_result <- parallel(subject = nrow(prepared_data), 
                       var = ncol(prepared_data),
                       rep = 1000, 
                       cent = 0.95)
  
  create_scree_plot(prepared_data, pa_result)
  create_correlation_heatmap(cor(prepared_data))
  
  # Perform EFA with different rotations
  rotations <- c("Varimax", "Promax", "Oblimin")
  for(rotation in rotations) {
    fa_result <- fa(prepared_data, 
                    nfactors = 7, 
                    rotate = tolower(rotation), 
                    fm = "ml")
    create_factor_loading_plot(fa_result, rotation)
    create_factor_correlation_table(fa_result, rotation)
  }
  
  # Create summary statistics table
  summary_stats <- data.frame(
    Factor = 1:7,
    Eigenvalue = eigen(cor(prepared_data))$values[1:7],
    Variance_Explained = fa_result$Vaccounted[2,],
    Cumulative_Variance = fa_result$Vaccounted[3,]
  )
  write.csv(round(summary_stats, 3),
            "efa_results/factor_summary_statistics.csv")
  
  cat("\nAnalysis complete! Results have been saved to the 'efa_results' directory.\n")
}

# Run the analysis
main() 