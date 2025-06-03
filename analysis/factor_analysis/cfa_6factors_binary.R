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

# Filtern nur binäre Teilnehmende (AMAB women und AFAB men)
daten_binary <- daten %>%
  filter(`Gender identity` %in% c("Woman (AMAB)", "Man (AFAB)"))

# Definition der Faktoren und Items (ohne SSC)
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
  # LS: Life Satisfaction
  "I13", "I2", "I5", "I8", "I11", "I19"
)

# CFA Modell-Spezifikation
cfa_model <- '
  # Measurement Model
  PF =~ I1 + I7 + I12 + I4 + I10_r + I3 + I6 + I9
  GEN =~ I21 + I29 + I14 + I27
  SGR =~ I28 + I15 + I18
  PEI =~ I20_r + I16_r + I22_r
  CH =~ I24 + I17
  LS =~ I13 + I2 + I5 + I8 + I11 + I19
'

# Stichprobengröße ausgeben
print("Stichprobengröße nach Geschlechtsidentität:")
print(table(daten_binary$`Gender identity`))

# Deskriptive Statistiken
print("Deskriptive Statistiken:")
describe(daten_binary[items])

# Korrelationsmatrix
print("Korrelationsmatrix:")
cor_matrix <- cor(daten_binary[items], use = "pairwise.complete.obs")
print(round(cor_matrix, 3))

# CFA Analyse durchführen
try({
  cfa_fit <- cfa(cfa_model, 
                 data = daten_binary,
                 estimator = "MLR",  # Robuster Maximum-Likelihood-Schätzer
                 se = "robust",
                 missing = "fiml")  # Full Information Maximum Likelihood für fehlende Werte
  
  # Modell-Fit ausgeben
  print("Modell-Fit Indizes:")
  summary(cfa_fit, fit.measures = TRUE, standardized = TRUE)
  
  # Modifikationsindizes
  print("Modifikationsindizes:")
  modificationindices(cfa_fit, sort = TRUE, minimum.value = 10)
  
  # Parameter Schätzungen
  print("Standardisierte Parameterschätzungen:")
  standardizedSolution(cfa_fit)
  
}, silent = FALSE)

# Reliabilitätsanalyse
print("Reliabilitätsanalyse (Cronbachs Alpha):")
for(factor in c("PF", "GEN", "SGR", "PEI", "CH", "LS")) {
  items_factor <- switch(factor,
    "PF" = c("I1", "I7", "I12", "I4", "I10_r", "I3", "I6", "I9"),
    "GEN" = c("I21", "I29", "I14", "I27"),
    "SGR" = c("I28", "I15", "I18"),
    "PEI" = c("I20_r", "I16_r", "I22_r"),
    "CH" = c("I24", "I17"),
    "LS" = c("I13", "I2", "I5", "I8", "I11", "I19")
  )
  print(paste("Faktor:", factor))
  print(alpha(daten_binary[items_factor]))
}

# Speichern der Ergebnisse
sink("cfa_6factors_binary_results.txt")
print("CFA 6-Faktoren Analyse (nur binäre Teilnehmende)")
print(Sys.time())
try({
  summary(cfa_fit, fit.measures = TRUE, standardized = TRUE)
})
sink() 