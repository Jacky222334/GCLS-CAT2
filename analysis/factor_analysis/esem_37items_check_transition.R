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
daten_esem <- read_excel("../../data/raw/dat_ESEM_compl_wI26_GI.xlsx")
daten_trans <- read_excel("../../data/raw/rwa_demo_trans_transpez_labeled.xlsx")

# Definition der 37 Items (ohne I26)
items <- c(
  paste0("I", c(1:25, 27:38)),
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]

# Überprüfung der Struktur der Transitionsdaten
print("Struktur der Transitionsdaten:")
print(names(daten_trans))

# Überprüfung auf Inkonsistenzen
print("\nÜberprüfung auf Inkonsistenzen in Transitionsdaten:")

# Identifiziere inkonsistente Fälle basierend auf den Transitionsdaten
# Die genauen Spaltennamen werden nach der ersten Ausführung angepasst

# Zeige Verteilung der Geschlechtsidentität
print("\nVerteilung der Geschlechtsidentität vor Bereinigung:")
print(table(daten_esem$`Gender identity`))

# ESEM Analyse mit Originaldaten (zunächst)
print("\nESEM Analyse:")
esem_fit <- fa(daten_esem[items], 
               nfactors = 7,
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
sink("esem_37items_transition_check_results.txt")
print("ESEM Analyse (37 Items)")
print(Sys.time())
print("\nStruktur der Transitionsdaten:")
print(names(daten_trans))
print("\nVerteilung der Geschlechtsidentität:")
print(table(daten_esem$`Gender identity`))
print("\nFaktorladungen:")
print(round(esem_fit$loadings, 3))
print("\nFaktorkorrelationen:")
print(round(esem_fit$Phi, 3))
print("\nModell-Fit:")
print(esem_fit$STATISTIC)
print(esem_fit$PVAL)
print(esem_fit$fit.stats)
sink() 