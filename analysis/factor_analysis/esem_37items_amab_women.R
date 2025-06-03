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

# Nur AMAB Frauen auswählen
daten_amab_women <- daten %>%
  filter(`Gender identity` == "Woman (AMAB)")

# Definition der 37 Items (ohne I26)
items <- c(
  paste0("I", c(1:25, 27:38)),
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]

# Stichprobengröße ausgeben
print("Stichprobengröße der AMAB Frauen:")
print(nrow(daten_amab_women))

# Deskriptive Statistiken
print("\nDeskriptive Statistiken:")
describe(daten_amab_women[items])

# Korrelationsmatrix
print("\nKorrelationsmatrix:")
cor_matrix <- cor(daten_amab_women[items], use = "pairwise.complete.obs")
print(round(cor_matrix, 3))

# ESEM Analyse
print("\nESEM Analyse:")
esem_fit <- fa(daten_amab_women[items], 
               nfactors = 7,  # 7 Faktoren beibehalten
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
sink("esem_37items_amab_women_results.txt")
print("ESEM Analyse (37 Items) - Nur AMAB Frauen")
print(Sys.time())
print("\nStichprobengröße:")
print(nrow(daten_amab_women))
print("\nFaktorladungen:")
print(round(esem_fit$loadings, 3))
print("\nFaktorkorrelationen:")
print(round(esem_fit$Phi, 3))
print("\nModell-Fit:")
print(esem_fit$STATISTIC)
print(esem_fit$PVAL)
print(esem_fit$fit.stats)
sink() 