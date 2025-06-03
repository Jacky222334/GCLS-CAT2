# ESEM Analysis of G-GCLS
# Starting with a simpler model

library(lavaan)
library(semTools)
library(readxl)

# Read data
data <- read_excel("../../data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Define initial simpler model with main factors
initial_model <- '
# Factor 1: Psychological Functioning (PF)
F1 =~ NA*I1 + I7 + I12 + I4 + I10_r + I3 + I6 + I9
F1 ~~ 1*F1

# Factor 2: Genitalia (GEN)
F2 =~ NA*I21 + I29 + I14 + I27
F2 ~~ 1*F2

# Factor 3: Social Gender Role Recognition (SGR)
F3 =~ NA*I28 + I15 + I18
F3 ~~ 1*F3

# Allow factors to correlate
F1 ~~ F2 + F3
F2 ~~ F3
'

# Fit initial model
print("Fitting initial 3-factor model...")
fit_initial <- sem(initial_model, 
                  data = data,
                  estimator = "MLR",
                  rotation = "geomin",
                  se = "robust",
                  test = "Satorra.Bentler",
                  control = list(iter.max = 10000,
                               rel.tol = 1e-5))

# Save results
sink("esem_results.txt")

print("ESEM Analysis Results for G-GCLS (Initial 3-Factor Model)")
print("=======================================================")

# Try to get fit indices
fit_indices <- tryCatch({
    fitMeasures(fit_initial, c("rmsea", "rmsea.ci.lower", "rmsea.ci.upper",
                              "cfi", "tli", "srmr"))
}, error = function(e) {
    print("Error calculating fit indices:")
    print(e)
    return(NULL)
})

if (!is.null(fit_indices)) {
    print("\nModel Fit Indices:")
    print("------------------")
    print(sprintf("RMSEA: %.3f [%.3f, %.3f]", 
                 fit_indices["rmsea"], 
                 fit_indices["rmsea.ci.lower"],
                 fit_indices["rmsea.ci.upper"]))
    print(sprintf("CFI: %.3f", fit_indices["cfi"]))
    print(sprintf("TLI: %.3f", fit_indices["tli"]))
    print(sprintf("SRMR: %.3f", fit_indices["srmr"]))
}

# Try to get standardized solution
std_solution <- tryCatch({
    standardizedSolution(fit_initial)
}, error = function(e) {
    print("Error calculating standardized solution:")
    print(e)
    return(NULL)
})

if (!is.null(std_solution)) {
    print("\nStandardized Factor Loadings:")
    print("-----------------------------")
    loadings <- std_solution[std_solution$op == "=~", ]
    loadings <- loadings[order(abs(loadings$est), decreasing = TRUE), ]
    print(loadings[, c("lhs", "rhs", "est", "se", "pvalue")])
    
    # Analyze loadings
    print("\nLoading Analysis:")
    print("-----------------")
    primary_loadings <- sum(abs(loadings$est) > 0.40)
    cross_loadings <- sum(abs(loadings$est) < 0.30 & abs(loadings$est) > 0)
    print(sprintf("Primary loadings (> 0.40): %d", primary_loadings))
    print(sprintf("Cross-loadings (< 0.30): %d", cross_loadings))
}

sink()

# If initial model converges, save results
if (!is.null(fit_indices) && !is.null(std_solution)) {
    library(openxlsx)
    wb <- createWorkbook()
    
    # Fit indices sheet
    addWorksheet(wb, "Fit Indices")
    fit_df <- data.frame(
        Index = names(fit_indices),
        Value = unname(fit_indices)
    )
    writeData(wb, "Fit Indices", fit_df)
    
    # Factor loadings sheet
    addWorksheet(wb, "Factor Loadings")
    writeData(wb, "Factor Loadings", loadings)
    
    # Save workbook
    saveWorkbook(wb, "esem_initial_results.xlsx", overwrite = TRUE)
    
    print("\nResults saved to 'esem_initial_results.xlsx'")
} 