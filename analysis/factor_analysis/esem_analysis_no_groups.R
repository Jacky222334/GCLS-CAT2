# Installation und Laden der benötigten Pakete
if (!require("psych")) install.packages("psych")
if (!require("lavaan")) install.packages("lavaan")
if (!require("readxl")) install.packages("readxl")
if (!require("tidyverse")) install.packages("tidyverse")

library(psych)
library(lavaan)
library(readxl)
library(tidyverse)

# Daten einlesen
daten <- read_excel("../../data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# I33 umpolen
daten$I33_r <- 6 - daten$I33

# Definition der Faktoren und Items
items <- c(
  # PF: Physical Function
  "I1", "I7", "I12", "I4", "I10_r", "I3", "I6", "I9",
  # GEN: Gender Expression and Navigation
  "I21", "I29", "I14", "I27",
  # SGR: Social Gender Role
  "I28", "I15", "I18",
  # PEI: Psychological Effect on Identity
  "I20_r", "I16_r", "I22_r",
  # CH: Chest Hair
  "I24", "I17",
  # SSC: Sexual Self Confidence
  "I33_r", "I31_r",
  # LS: Life Satisfaction
  "I13", "I2", "I5", "I8", "I11", "I19"
)

# ESEM Modell-Spezifikation
esem_model <- '
  # Measurement Model
  PF =~ I1 + I7 + I12 + I4 + I10_r + I3 + I6 + I9
  GEN =~ I21 + I29 + I14 + I27
  SGR =~ I28 + I15 + I18
  PEI =~ I20_r + I16_r + I22_r
  CH =~ I24 + I17
  SSC =~ I33_r + I31_r
  LS =~ I13 + I2 + I5 + I8 + I11 + I19
'

# Deskriptive Statistiken
print("Deskriptive Statistiken:")
describe(daten[items])

# Korrelationsmatrix
print("Korrelationsmatrix:")
cor_matrix <- cor(daten[items], use = "pairwise.complete.obs")
print(round(cor_matrix, 3))

# ESEM Analyse durchführen
try({
  esem_fit <- sem(esem_model, 
                  data = daten,
                  estimator = "MLR",  # Robuster Maximum-Likelihood-Schätzer
                  rotation = "geomin",  # Geomin Rotation
                  se = "robust",
                  missing = "fiml")  # Full Information Maximum Likelihood für fehlende Werte
  
  # Modell-Fit ausgeben
  print("Modell-Fit Indizes:")
  summary(esem_fit, fit.measures = TRUE, standardized = TRUE)
  
  # Modifikationsindizes
  print("Modifikationsindizes:")
  modificationindices(esem_fit, sort = TRUE, minimum.value = 10)
  
  # Parameter Schätzungen
  print("Standardisierte Parameterschätzungen:")
  standardizedSolution(esem_fit)
  
}, silent = FALSE)

# Speichern der Ergebnisse
sink("esem_results_no_groups.txt")
print("ESEM Analyse ohne Gruppenvariable")
print(Sys.time())
try({
  summary(esem_fit, fit.measures = TRUE, standardized = TRUE)
})
sink() 