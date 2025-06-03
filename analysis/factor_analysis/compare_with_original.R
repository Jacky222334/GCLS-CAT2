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

library(psych)
library(lavaan)
library(readxl)
library(tidyverse)
library(ggplot2)
library(corrplot)
library(reshape2)
library(gridExtra)
library(pheatmap)

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

# ESEM Analysen für alle Gruppen
esem_all <- fa(daten_all[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_amab_women <- fa(daten_amab_women[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_afab_men <- fa(daten_afab_men[items], nfactors = 7, rotate = "oblimin", fm = "ml")

# Originale Ladungen in Matrix umwandeln
eng_matrix <- as.matrix(sapply(eng_loadings[,-1], as.numeric))
rownames(eng_matrix) <- paste0("I", eng_loadings$Item.Number)
colnames(eng_matrix) <- paste0("Factor", 1:7)

# Funktion für Heatmap mit Dendrogramm und Annotation
create_clustered_heatmap <- function(loadings, title, annotation_row, show_dend = TRUE) {
  # Konvertiere Ladungen in Matrix
  if(is.matrix(loadings)) {
    loadings_matrix <- loadings
  } else {
    loadings_matrix <- as.matrix(unclass(loadings))
  }
  
  # Erstelle Annotation für Zeilen (Items)
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
    loadings_matrix,
    main = title,
    color = colorRampPalette(c("blue", "white", "red"))(100),
    breaks = seq(-1, 1, length.out = 101),
    annotation_row = annotation_row,
    annotation_colors = annotation_colors,
    show_rownames = TRUE,
    show_colnames = TRUE,
    cluster_rows = show_dend,
    cluster_cols = show_dend,
    fontsize_row = 8,
    filename = paste0("heatmap_", gsub(" ", "_", tolower(title)), ".pdf"),
    width = 12,
    height = 15
  )
}

# Erstelle Annotation Dataframe
annotation_df <- data.frame(
  Factor = item_factors$Factor,
  row.names = item_factors$Item
)

# Erstelle Heatmaps
create_clustered_heatmap(eng_matrix[1:37,], "Original English Version", annotation_df, show_dend = FALSE)
create_clustered_heatmap(esem_all$loadings, "German Total Sample (N=293)", annotation_df)
create_clustered_heatmap(esem_amab_women$loadings, "German AMAB Women (n=154)", annotation_df)
create_clustered_heatmap(esem_afab_men$loadings, "German AFAB Men (n=97)", annotation_df)

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

# Kongruenzkoeffizienten für alle Gruppen
congru_all <- calculate_congruence(eng_matrix[1:37,], esem_all$loadings)
congru_amab <- calculate_congruence(eng_matrix[1:37,], esem_amab_women$loadings)
congru_afab <- calculate_congruence(eng_matrix[1:37,], esem_afab_men$loadings)

# Kongruenzkoeffizienten visualisieren
pdf("congruence_coefficients.pdf", width = 15, height = 5)
par(mfrow = c(1, 3))
corrplot(congru_all, method = "color",
         title = "Congruence: Original vs Total Sample",
         addCoef.col = "black")
corrplot(congru_amab, method = "color",
         title = "Congruence: Original vs AMAB Women",
         addCoef.col = "black")
corrplot(congru_afab, method = "color",
         title = "Congruence: Original vs AFAB Men",
         addCoef.col = "black")
dev.off()

# Zusammenfassung speichern
sink("factor_comparison_summary.txt")
cat("Factor Structure Comparison Summary\n\n")
cat("Congruence Coefficients with Original Version\n")
cat("\nTotal Sample:\n")
print(round(congru_all, 3))
cat("\nAMAB Women:\n")
print(round(congru_amab, 3))
cat("\nAFAB Men:\n")
print(round(congru_afab, 3))

# Höchste Kongruenzen pro Faktor
cat("\nBest matching factors (congruence > 0.85):\n")
for(i in 1:7) {
  cat("\nOriginal Factor", i, "matches best with:\n")
  cat("Total Sample: Factor", which.max(abs(congru_all[i,])), 
      "(", round(max(abs(congru_all[i,])), 3), ")\n")
  cat("AMAB Women: Factor", which.max(abs(congru_amab[i,])),
      "(", round(max(abs(congru_amab[i,])), 3), ")\n")
  cat("AFAB Men: Factor", which.max(abs(congru_afab[i,])),
      "(", round(max(abs(congru_afab[i,])), 3), ")\n")
}
sink() 