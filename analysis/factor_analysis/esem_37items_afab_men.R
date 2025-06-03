# Installation und Laden der benötigten Pakete
if (!require("psych")) install.packages("psych")
if (!require("lavaan")) install.packages("lavaan")
if (!require("readxl")) install.packages("readxl")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("corrplot")) install.packages("corrplot")

library(psych)
library(lavaan)
library(readxl)
library(tidyverse)
library(ggplot2)
library(corrplot)

# Daten einlesen
daten <- read_excel("../../data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Nur AFAB Männer auswählen
daten_afab_men <- daten %>%
  filter(`Gender identity` == "Man (AFAB)")

# Definition der 37 Items (ohne I26)
items <- c(
  paste0("I", c(1:25, 27:38)),
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]

# Stichprobengröße ausgeben
print("Stichprobengröße der AFAB Männer:")
print(nrow(daten_afab_men))

# Deskriptive Statistiken
print("\nDeskriptive Statistiken:")
describe(daten_afab_men[items])

# Korrelationsmatrix
print("\nKorrelationsmatrix:")
cor_matrix <- cor(daten_afab_men[items], use = "pairwise.complete.obs")
print(round(cor_matrix, 3))

# ESEM Analyse
print("\nESEM Analyse:")
esem_fit <- fa(daten_afab_men[items], 
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
sink("esem_37items_afab_men_results.txt")
print("ESEM Analyse (37 Items) - Nur AFAB Männer")
print(Sys.time())
print("\nStichprobengröße:")
print(nrow(daten_afab_men))
print("\nFaktorladungen:")
print(round(esem_fit$loadings, 3))
print("\nFaktorkorrelationen:")
print(round(esem_fit$Phi, 3))
print("\nModell-Fit:")
print(esem_fit$STATISTIC)
print(esem_fit$PVAL)
print(esem_fit$fit.stats)
sink() 