# Installation und Laden der benötigten Pakete
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("pheatmap")) install.packages("pheatmap")
if (!require("gridExtra")) install.packages("gridExtra")
if (!require("grid")) install.packages("grid")
if (!require("readxl")) install.packages("readxl")
if (!require("psych")) install.packages("psych")

library(tidyverse)
library(pheatmap)
library(gridExtra)
library(grid)
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
create_publication_heatmap <- function(loadings, title, show_legend = FALSE) {
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
    fontsize_row = 11,  # APA-konforme Schriftgröße
    fontsize_col = 11,  # APA-konforme Schriftgröße
    fontsize = 11,      # APA-konforme Schriftgröße
    display_numbers = TRUE,
    number_format = "%.2f",
    fontsize_number = 8,
    na_col = "white",
    annotation_legend = show_legend,
    legend = show_legend,
    silent = TRUE
  )
}

# Erstelle die vier Heatmaps
pdf("combined_heatmaps.pdf", width = 20, height = 20)  # Größeres Format für bessere Lesbarkeit

# Layout definieren (2x2 Grid)
grid.newpage()
pushViewport(viewport(layout = grid.layout(2, 2)))

# Platziere die Heatmaps
# Oben links: Original
print(create_publication_heatmap(eng_matrix[1:37,], "A) Original English Version"), 
      vp = viewport(layout.pos.row = 1, layout.pos.col = 1))

# Oben rechts: Gesamtstichprobe
print(create_publication_heatmap(esem_all$loadings, "B) German Total Sample (N=293)"), 
      vp = viewport(layout.pos.row = 1, layout.pos.col = 2))

# Unten links: AMAB Frauen
print(create_publication_heatmap(esem_amab_women$loadings, "C) AMAB Women (n=154)"), 
      vp = viewport(layout.pos.row = 2, layout.pos.col = 1))

# Unten rechts: AFAB Männer mit Legende
print(create_publication_heatmap(esem_afab_men$loadings, "D) AFAB Men (n=97)", show_legend = TRUE), 
      vp = viewport(layout.pos.row = 2, layout.pos.col = 2))

dev.off()

# Erstelle eine separate Legende für die Publikation
pdf("heatmap_legend.pdf", width = 8, height = 4)
plot.new()
legend("center", 
       legend = c("Psychological Function", "Social Function", "Physical Function", 
                 "Life Satisfaction", "Body Image", "Relationship Satisfaction", 
                 "Gender Identity"),
       fill = c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", 
                "#FFFF33", "#A65628"),
       title = "GCLS Subscales",
       cex = 1.2)
dev.off() 