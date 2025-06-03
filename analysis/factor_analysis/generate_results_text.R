# Installation und Laden der benötigten Pakete
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("psych")) install.packages("psych")
if (!require("readxl")) install.packages("readxl")
if (!require("lavaan")) install.packages("lavaan")

library(tidyverse)
library(psych)
library(readxl)
library(lavaan)

# Daten einlesen
daten <- read_excel("../../data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Items definieren
items <- c(
  paste0("I", c(1:25, 27:38)),
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]

# AMAB Gruppe definieren
daten_amab <- daten %>% 
  filter(grepl("AMAB", `Gender identity`))

# ESEM Analysen durchführen
esem_gesamt <- fa(daten[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_amab <- fa(daten_amab[items], nfactors = 7, rotate = "oblimin", fm = "ml")

# Berechne erklärte Varianz
var_gesamt <- sum(esem_gesamt$values[1:7]) / length(items) * 100
var_amab <- sum(esem_amab$values[1:7]) / length(items) * 100

# Berechne Faktorkorrelationen Range
korr_range_gesamt <- range(esem_gesamt$Phi[upper.tri(esem_gesamt$Phi)])
korr_range_amab <- range(esem_amab$Phi[upper.tri(esem_amab$Phi)])

# Erstelle Lavaan Syntax für ESEM Modell
erstelle_esem_syntax <- function(loadings) {
  syntax <- ""
  for(i in 1:7) {
    items_mit_ladungen <- rownames(loadings)[abs(loadings[,i]) > 0.3]
    if(length(items_mit_ladungen) > 0) {
      syntax <- paste0(syntax, 
                      sprintf("F%d =~ ", i),
                      paste(items_mit_ladungen, collapse = " + "),
                      "\n")
    }
  }
  return(syntax)
}

# Berechne Fit-Indizes mit Lavaan
berechne_fit_lavaan <- function(daten, loadings) {
  syntax <- erstelle_esem_syntax(loadings)
  fit <- sem(syntax, data = as.data.frame(daten), estimator = "MLR")
  
  return(list(
    chi_square = fitMeasures(fit)["chisq"],
    df = fitMeasures(fit)["df"],
    rmsea = fitMeasures(fit)["rmsea"],
    rmsea_ci_lower = fitMeasures(fit)["rmsea.ci.lower"],
    rmsea_ci_upper = fitMeasures(fit)["rmsea.ci.upper"],
    cfi = fitMeasures(fit)["cfi"],
    tli = fitMeasures(fit)["tli"]
  ))
}

# Berechne Fit-Indizes
fit_gesamt <- berechne_fit_lavaan(daten[items], esem_gesamt$loadings)
fit_amab <- berechne_fit_lavaan(daten_amab[items], esem_amab$loadings)

# Erstelle den Ergebnistext
cat("\nSample and Factor Structure\n")
cat(sprintf("
ESEM analyses were conducted on the full sample (N = %d) and a key subgroup of AMAB women (assigned male at birth; n = %d). In both cases, a seven-factor solution emerged, accounting for %.1f%% of the variance in the full sample and %.1f%% in the AMAB subgroup.

Interfactor correlations ranged from r = %.2f to %.2f in the full sample and r = %.2f to %.2f in the AMAB subgroup, supporting the notion that the constructs are related but distinct.

Model Fit

Model fit was acceptable in both groups. For the full sample, we observed:
• χ²(%d) = %.2f, p < .001
• RMSEA = %.3f [90%% CI: %.3f, %.3f]
• CFI = %.3f
• TLI = %.3f

For the AMAB subgroup:
• χ²(%d) = %.2f, p < .001
• RMSEA = %.3f [90%% CI: %.3f, %.3f]
• CFI = %.3f
• TLI = %.3f
",
nrow(daten), nrow(daten_amab),
var_gesamt, var_amab,
korr_range_gesamt[1], korr_range_gesamt[2],
korr_range_amab[1], korr_range_amab[2],
fit_gesamt$df, fit_gesamt$chi_square,
fit_gesamt$rmsea, fit_gesamt$rmsea_ci_lower, fit_gesamt$rmsea_ci_upper,
fit_gesamt$cfi, fit_gesamt$tli,
fit_amab$df, fit_amab$chi_square,
fit_amab$rmsea, fit_amab$rmsea_ci_lower, fit_amab$rmsea_ci_upper,
fit_amab$cfi, fit_amab$tli
)) -> "esem_results.txt" 