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

# Definition der Items (ohne SSC)
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

# Stichprobengröße ausgeben
print("Stichprobengröße nach Geschlechtsidentität:")
print(table(daten_binary$`Gender identity`))

# Deskriptive Statistiken
print("\nDeskriptive Statistiken:")
describe(daten_binary[items])

# Korrelationsmatrix
print("\nKorrelationsmatrix:")
cor_matrix <- cor(daten_binary[items], use = "pairwise.complete.obs")
print(round(cor_matrix, 3))

# ESEM Analyse mit fa() aus psych
print("\nESEM Analyse:")
esem_fit <- fa(daten_binary[items], 
               nfactors = 6,
               rotate = "oblimin",
               fm = "ml",
               scores = TRUE)

# Ausgabe der Ergebnisse
print("\nFaktorladungen:")
print(round(esem_fit$loadings, 3))

print("\nFaktorkorrelationen:")
print(round(esem_fit$Phi, 3))

print("\nModell-Fit:")
print(esem_fit$STATISTIC)
print(esem_fit$PVAL)
print(esem_fit$fit.stats)

# Speichern der Ergebnisse
sink("esem_binary_results.txt")
print("ESEM Analyse (nur binäre Teilnehmende)")
print(Sys.time())
print("\nFaktorladungen:")
print(round(esem_fit$loadings, 3))
print("\nFaktorkorrelationen:")
print(round(esem_fit$Phi, 3))
print("\nModell-Fit:")
print(esem_fit$STATISTIC)
print(esem_fit$PVAL)
print(esem_fit$fit.stats)
sink() 