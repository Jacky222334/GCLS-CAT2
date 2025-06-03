# Installation und Laden der benötigten Pakete
if (!require("psych")) install.packages("psych")
if (!require("lavaan")) install.packages("lavaan")
if (!require("readxl")) install.packages("readxl")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("corrplot")) install.packages("corrplot")
if (!require("reshape2")) install.packages("reshape2")
if (!require("gridExtra")) install.packages("gridExtra")
if (!require("pheatmap")) install.packages("pheatmap")
if (!require("grid")) install.packages("grid")

library(psych)
library(lavaan)
library(readxl)
library(tidyverse)
library(ggplot2)
library(corrplot)
library(reshape2)
library(gridExtra)
library(pheatmap)
library(grid)

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

# Original Faktorzuordnung
item_factors <- data.frame(
  Item = items[1:37],
  Factor = c(
    rep("Psychological Function", 5),  # I1-I5
    rep("Social Function", 5),         # I6-I10
    rep("Physical Function", 5),       # I11-I15
    rep("Life Satisfaction", 5),       # I16-I20
    rep("Body Image", 5),             # I21-I25
    rep("Relationship Satisfaction", 6), # I27-I32
    rep("Gender Identity", 6)          # I33-I38
  )
)

# ESEM Analysen
esem_all <- fa(daten_all[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_amab_women <- fa(daten_amab_women[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_afab_men <- fa(daten_afab_men[items], nfactors = 7, rotate = "oblimin", fm = "ml")

# Originale Ladungen
eng_matrix <- as.matrix(sapply(eng_loadings[,-1], as.numeric))
rownames(eng_matrix) <- paste0("I", eng_loadings$Item.Number)
colnames(eng_matrix) <- paste0("F", 1:7)

# Funktion für publikationsreife Heatmap
create_publication_heatmap <- function(loadings, title) {
  if(is.matrix(loadings)) {
    loadings_matrix <- loadings
  } else {
    loadings_matrix <- as.matrix(unclass(loadings))
  }
  colnames(loadings_matrix) <- paste0("F", 1:7)
  
  # Nur Ladungen > |0.3| anzeigen
  loadings_matrix_display <- loadings_matrix
  loadings_matrix_display[abs(loadings_matrix_display) < 0.3] <- NA
  
  # Annotation für Items
  annotation_df <- data.frame(
    Factor = item_factors$Factor,
    row.names = item_factors$Item
  )
  
  # Farbschema
  annotation_colors <- list(
    Factor = c(
      "Psychological Function" = "#E41A1C",
      "Social Function" = "#377EB8",
      "Physical Function" = "#4DAF4A",
      "Life Satisfaction" = "#984EA3",
      "Body Image" = "#FF7F00",
      "Relationship Satisfaction" = "#FFFF33",
      "Gender Identity" = "#A65628"
    )
  )
  
  # Erstelle Heatmap
  pheatmap(
    loadings_matrix_display,
    main = title,
    color = colorRampPalette(c("#2166AC", "white", "#B2182B"))(100),
    breaks = seq(-1, 1, length.out = 101),
    annotation_row = annotation_df,
    annotation_colors = annotation_colors,
    show_rownames = TRUE,
    show_colnames = TRUE,
    cluster_rows = FALSE,
    cluster_cols = FALSE,
    fontsize_row = 10,  # Erhöhte Schriftgröße für Zeilenbeschriftungen
    fontsize_col = 10,  # Erhöhte Schriftgröße für Spaltenbeschriftungen
    display_numbers = TRUE,
    number_format = "%.3f",  # 3 Dezimalstellen für mehr Präzision
    fontsize_number = 8,     # Erhöhte Schriftgröße für Zahlen
    na_col = "white",
    number_color = "black",  # Schwarze Farbe für alle Zahlen
    filename = paste0("heatmap_", gsub(" ", "_", tolower(title)), ".pdf"),
    width = 12,  # Erhöhte Breite
    height = 18  # Erhöhte Höhe
  )
}

# Erstelle einzelne Heatmaps
create_publication_heatmap(eng_matrix[1:37,], "A) Original English Version")
create_publication_heatmap(esem_all$loadings, "B) German Total Sample (N=293)")
create_publication_heatmap(esem_amab_women$loadings, "C) AMAB Women (n=154)")
create_publication_heatmap(esem_afab_men$loadings, "D) AFAB Men (n=97)")

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

# Publikationsabbildung 2: Kongruenzkoeffizienten
pdf("publication_figure2_congruence.pdf", width = 15, height = 5)
par(mfrow = c(1, 3))
corrplot(congru_all, method = "color",
         col = colorRampPalette(c("#2166AC", "white", "#B2182B"))(200),
         title = "A) Total Sample",
         mar = c(0,0,1,0),
         addCoef.col = "black",
         number.cex = 0.7,
         tl.cex = 0.8)
corrplot(congru_amab, method = "color",
         col = colorRampPalette(c("#2166AC", "white", "#B2182B"))(200),
         title = "B) AMAB Women",
         mar = c(0,0,1,0),
         addCoef.col = "black",
         number.cex = 0.7,
         tl.cex = 0.8)
corrplot(congru_afab, method = "color",
         col = colorRampPalette(c("#2166AC", "white", "#B2182B"))(200),
         title = "C) AFAB Men",
         mar = c(0,0,1,0),
         addCoef.col = "black",
         number.cex = 0.7,
         tl.cex = 0.8)
dev.off()

# Publikationstabelle 1: Fit-Statistiken
fit_stats <- data.frame(
  Group = c("Total Sample", "AMAB Women", "AFAB Men"),
  N = c(nrow(daten_all), nrow(daten_amab_women), nrow(daten_afab_men)),
  ChiSquare = c(esem_all$STATISTIC, esem_amab_women$STATISTIC, esem_afab_men$STATISTIC),
  df = c(esem_all$dof, esem_amab_women$dof, esem_afab_men$dof),
  PValue = c(esem_all$PVAL, esem_amab_women$PVAL, esem_afab_men$PVAL),
  TLI = c(esem_all$TLI, esem_amab_women$TLI, esem_afab_men$TLI),
  RMSEA = c(esem_all$RMSEA[1], esem_amab_women$RMSEA[1], esem_afab_men$RMSEA[1])
)

# Speichern der Fit-Statistiken
write.csv(fit_stats, "publication_table1_fit_statistics.csv", row.names = FALSE)

# Publikationstabelle 2: Kongruenzkoeffizienten
congru_summary <- data.frame(
  Factor = paste("Factor", 1:7),
  Total_Sample = sapply(1:7, function(i) max(abs(congru_all[i,]))),
  AMAB_Women = sapply(1:7, function(i) max(abs(congru_amab[i,]))),
  AFAB_Men = sapply(1:7, function(i) max(abs(congru_afab[i,])))
)

# Speichern der Kongruenzkoeffizienten
write.csv(congru_summary, "publication_table2_congruence.csv", row.names = FALSE) 