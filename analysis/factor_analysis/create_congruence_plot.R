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

# Gruppen definieren
daten_amab_women <- daten %>% filter(`Gender identity` == "Woman (AMAB)")
daten_afab_men <- daten %>% filter(`Gender identity` == "Man (AFAB)")
daten_all <- daten

# Items definieren
items <- c(
  paste0("I", c(1:25, 27:38)),
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]

# ESEM Analysen
esem_all <- fa(daten_all[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_amab_women <- fa(daten_amab_women[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_afab_men <- fa(daten_afab_men[items], nfactors = 7, rotate = "oblimin", fm = "ml")

# Originale Ladungen
eng_matrix <- as.matrix(sapply(eng_loadings[,-1], as.numeric))
rownames(eng_matrix) <- paste0("I", eng_loadings$Item.Number)
colnames(eng_matrix) <- paste0("F", 1:7)

# Kongruenzkoeffizienten berechnen
calculate_congruence <- function(matrix1, matrix2) {
  n_factors <- ncol(matrix1)
  congru_matrix <- matrix(0, n_factors, n_factors)
  
  for(i in 1:n_factors) {
    for(j in 1:n_factors) {
      congru_matrix[i,j] <- sum(matrix1[,i] * matrix2[,j]) / 
        sqrt(sum(matrix1[,i]^2) * sum(matrix2[,j]^2))
    }
  }
  return(congru_matrix)
}

# Kongruenzkoeffizienten
congru_all <- calculate_congruence(eng_matrix[1:37,], esem_all$loadings)
congru_amab <- calculate_congruence(eng_matrix[1:37,], esem_amab_women$loadings)
congru_afab <- calculate_congruence(eng_matrix[1:37,], esem_afab_men$loadings)

# Trans Pride Farben
trans_colors <- c("#55CDFC",  # Hellblau
                  "#F7A8B8",  # Rosa
                  "#FFFFFF",  # Weiß
                  "#F7A8B8",  # Rosa
                  "#55CDFC")  # Hellblau

# Erstelle die Kongruenzkoeffizienten-Plots
pdf("congruence_coefficients_trans.pdf", width = 15, height = 5)

par(mfrow = c(1, 3))

# Funktion für einheitliche Plot-Formatierung
plot_congruence <- function(matrix, title) {
  corrplot(matrix,
           method = "color",
           col = colorRampPalette(trans_colors)(200),
           title = title,
           mar = c(0,0,2,0),
           addCoef.col = "black",
           number.cex = 0.7,
           tl.cex = 0.8,
           cl.cex = 0.7,
           tl.col = "black",
           addgrid.col = "white",
           tl.srt = 45,
           type = "upper")
}

# Plotte die drei Matrizen
plot_congruence(congru_all, "A) Total Sample")
plot_congruence(congru_amab, "B) AMAB Women")
plot_congruence(congru_afab, "C) AFAB Men")

dev.off()

# Erstelle eine Version mit Faktorbezeichnungen
factor_names <- c("PsyF", "SocF", "PhyF", "LifeS", "BodyI", "RelS", "GenI")

pdf("congruence_coefficients_trans_labeled.pdf", width = 15, height = 5)

par(mfrow = c(1, 3))

# Funktion für beschriftete Plot-Formatierung
plot_congruence_labeled <- function(matrix, title) {
  corrplot(matrix,
           method = "color",
           col = colorRampPalette(trans_colors)(200),
           title = title,
           mar = c(0,0,2,0),
           addCoef.col = "black",
           number.cex = 0.7,
           tl.cex = 0.8,
           cl.cex = 0.7,
           tl.col = "black",
           addgrid.col = "white",
           tl.srt = 45,
           type = "upper",
           tl.pos = "lt")
}

# Plotte die drei Matrizen mit Faktorbezeichnungen
rownames(congru_all) <- colnames(congru_all) <- factor_names
rownames(congru_amab) <- colnames(congru_amab) <- factor_names
rownames(congru_afab) <- colnames(congru_afab) <- factor_names

plot_congruence_labeled(congru_all, "A) Total Sample")
plot_congruence_labeled(congru_amab, "B) AMAB Women")
plot_congruence_labeled(congru_afab, "C) AFAB Men")

dev.off()

# Speichere die Kongruenzwerte als Tabelle
congru_summary <- data.frame(
  Factor = factor_names,
  Total_Sample = sapply(1:7, function(i) max(abs(congru_all[i,]))),
  AMAB_Women = sapply(1:7, function(i) max(abs(congru_amab[i,]))),
  AFAB_Men = sapply(1:7, function(i) max(abs(congru_afab[i,])))
)

write.csv(congru_summary, "congruence_summary.csv", row.names = FALSE) 