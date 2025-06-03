# Installation und Laden der benötigten Pakete
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("corrplot")) install.packages("corrplot")
if (!require("RColorBrewer")) install.packages("RColorBrewer")
if (!require("readxl")) install.packages("readxl")
if (!require("psych")) install.packages("psych")

library(tidyverse)
library(corrplot)
library(RColorBrewer)
library(readxl)
library(psych)

# Daten einlesen
daten <- read_excel("../../data/raw/dat_ESEM_compl_wI26_GI.xlsx")
eng_loadings <- read.csv2("../../data/raw/eng_version_loading.csv")

# AMAB Gruppe definieren (alle AMAB Personen)
daten_amab <- daten %>% 
  filter(grepl("AMAB", `Gender identity`))

# Items definieren
items <- c(
  paste0("I", c(1:25, 27:38)),
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]

# ESEM Analyse für AMAB
esem_amab <- fa(daten_amab[items], nfactors = 7, rotate = "oblimin", fm = "ml")

# Originale Ladungen
eng_matrix <- as.matrix(sapply(eng_loadings[,-1], as.numeric))
rownames(eng_matrix) <- paste0("I", eng_loadings$Item.Number)
colnames(eng_matrix) <- paste0("F", 1:7)

# Kongruenzkoeffizienten berechnen
berechne_kongruenz <- function(matrix1, matrix2) {
  n_faktoren <- ncol(matrix1)
  kongru_matrix <- matrix(0, n_faktoren, n_faktoren)
  
  for(i in 1:n_faktoren) {
    for(j in 1:n_faktoren) {
      kongru_matrix[i,j] <- sum(matrix1[,i] * matrix2[,j]) / 
        sqrt(sum(matrix1[,i]^2) * sum(matrix2[,j]^2))
    }
  }
  return(kongru_matrix)
}

# Kongruenzkoeffizienten für AMAB
kongru_amab <- berechne_kongruenz(eng_matrix[1:37,], esem_amab$loadings)

# Regenbogenfarben für die 7 Faktoren
regenbogen_farben <- c(
  "#FF0000",  # Rot
  "#FF7F00",  # Orange
  "#FFFF00",  # Gelb
  "#00FF00",  # Grün
  "#0000FF",  # Blau
  "#4B0082",  # Indigo
  "#9400D3"   # Violett
)

# Faktorbezeichnungen
faktor_namen <- c(
  "Psychologische\nFunktion",
  "Soziale\nFunktion", 
  "Körperliche\nFunktion",
  "Lebens-\nzufriedenheit",
  "Körper-\nbild",
  "Beziehungs-\nzufriedenheit",
  "Geschlechts-\nidentität"
)

# Erstelle den Plot
pdf("kongruenzkoeffizienten_amab.pdf", width = 8, height = 8)

# Funktion für Plot-Formatierung
plotte_kongruenz <- function(matrix, titel) {
  # Setze die Faktorbezeichnungen
  rownames(matrix) <- colnames(matrix) <- faktor_namen
  
  # Plot mit Kongruenzkoeffizienten
  corrplot(matrix,
           method = "color",
           col = colorRampPalette(c("white", "darkred"))(100),
           title = titel,
           mar = c(4,4,4,4),
           addCoef.col = "black",
           number.cex = 0.9,
           tl.cex = 0.8,
           cl.cex = 0.7,
           tl.col = regenbogen_farben,  # Färbe die Labels in Regenbogenfarben
           addgrid.col = "white",
           tl.srt = 45,
           type = "upper",
           diag = TRUE,
           order = "original")
}

# Plotte die Matrix
plotte_kongruenz(abs(kongru_amab), "Kongruenzkoeffizienten AMAB")

dev.off()

# Erstelle eine separate Legende
pdf("faktoren_legende_amab.pdf", width = 8, height = 4)
plot.new()
legend("center", 
       legend = faktor_namen,
       fill = regenbogen_farben,
       title = "GCLS Faktoren",
       cex = 1.2)
dev.off()

# Speichere die Kongruenzwerte als Tabelle
kongru_zusammenfassung <- data.frame(
  Faktor = faktor_namen,
  AMAB = sapply(1:7, function(i) max(abs(kongru_amab[i,])))
)

write.csv(kongru_zusammenfassung, "kongruenz_amab.csv", row.names = FALSE)

# Speichere die Faktorladungen
loadings_amab <- data.frame(
  Item = rownames(esem_amab$loadings),
  esem_amab$loadings
)

write.csv(loadings_amab, "loadings_amab.csv", row.names = FALSE) 