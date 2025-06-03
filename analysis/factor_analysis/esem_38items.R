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

# Definition aller 38 Items
items <- c(
  # Alle Items I1 bis I38
  paste0("I", 1:38),
  # Ersetze die Items mit _r Suffix
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:38]  # Nehme nur die ersten 38 Einträge

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
sink("esem_38items_results.txt")
print("ESEM Analyse (38 Items, nur binäre Teilnehmende)")
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