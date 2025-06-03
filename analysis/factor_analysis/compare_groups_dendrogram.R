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

# Gruppen definieren
daten_amab_women <- daten %>% filter(`Gender identity` == "Woman (AMAB)")
daten_afab_men <- daten %>% filter(`Gender identity` == "Man (AFAB)")
daten_all <- daten

# Items definieren
items <- c(
  paste0("I", c(1:25, 27:38)),
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]

# Original Faktorzuordnung (basierend auf McNeish et al., 2020)
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

# Funktion für Heatmap mit Dendrogramm
create_clustered_heatmap <- function(loadings, title, annotation_row) {
  # Konvertiere Ladungen in Matrix
  loadings_matrix <- as.matrix(unclass(loadings))
  
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
  
  # Erstelle Heatmap mit Dendrogramm
  pheatmap(
    loadings_matrix,
    main = title,
    color = colorRampPalette(c("blue", "white", "red"))(100),
    breaks = seq(-1, 1, length.out = 101),
    annotation_row = annotation_row,
    annotation_colors = annotation_colors,
    show_rownames = TRUE,
    show_colnames = TRUE,
    cluster_rows = TRUE,
    cluster_cols = TRUE,
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

# Erstelle Heatmaps mit Dendrogramm für jede Gruppe
create_clustered_heatmap(esem_all$loadings, "Total Sample (N=293)", annotation_df)
create_clustered_heatmap(esem_amab_women$loadings, "AMAB Women (n=154)", annotation_df)
create_clustered_heatmap(esem_afab_men$loadings, "AFAB Men (n=97)", annotation_df)

# Zusätzlich: Korrelationsmatrix der Items mit Clustering
pdf("item_correlations_clustered.pdf", width = 15, height = 15)
corrplot(cor(daten_all[items]), 
         method = "color",
         type = "upper",
         order = "hclust",
         addrect = 7,  # Zeige 7 Hauptcluster
         addCoef.col = "black",
         number.cex = 0.5,
         tl.col = "black",
         tl.srt = 45,
         title = "Item Correlations with Hierarchical Clustering")
dev.off()

# Speichere Zusammenfassung der Cluster-Analyse
sink("cluster_analysis_summary.txt")
cat("Cluster Analysis Summary\n\n")
cat("Original Factor Structure:\n")
print(table(item_factors$Factor))
cat("\nItems per Original Factor:\n")
for(factor in unique(item_factors$Factor)) {
  cat("\n", factor, ":\n")
  print(items[item_factors$Factor == factor])
}
sink() 