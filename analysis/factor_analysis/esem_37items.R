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

# Definition der 37 Items (ohne I26)
items <- c(
  # Alle Items I1 bis I38 außer I26
  paste0("I", c(1:25, 27:38)),
  # Ersetze die Items mit _r Suffix
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]  # Nehme nur die ersten 37 Einträge

# Stichprobengröße ausgeben
print("Stichprobengröße nach Geschlechtsidentität:")
print(table(daten$`Gender identity`))

# Deskriptive Statistiken
print("\nDeskriptive Statistiken:")
describe(daten[items])

# Korrelationsmatrix
print("\nKorrelationsmatrix:")
cor_matrix <- cor(daten[items], use = "pairwise.complete.obs")
print(round(cor_matrix, 3))

# ESEM Analyse mit fa() aus psych
print("\nESEM Analyse:")
esem_fit <- fa(daten[items], 
               nfactors = 7,  # 7 Faktoren für die vollständige Analyse
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
sink("esem_37items_results.txt")
print("ESEM Analyse (37 Items, ohne I26)")
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