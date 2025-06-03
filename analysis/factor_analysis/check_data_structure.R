# Pakete laden
library(readxl)
library(tidyverse)

# Daten einlesen
daten <- read_excel("../../data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Struktur der Daten anzeigen
print("Spaltennamen:")
print(names(daten))

# Erste Zeilen anzeigen
print("\nErste Zeilen:")
print(head(daten)) 