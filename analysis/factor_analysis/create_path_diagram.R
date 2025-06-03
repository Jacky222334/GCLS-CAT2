# Installation und Laden der benötigten Pakete
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("psych")) install.packages("psych")
if (!require("qgraph")) install.packages("qgraph")
if (!require("readxl")) install.packages("readxl")
if (!require("lavaan")) install.packages("lavaan")
if (!require("stats")) install.packages("stats")

library(tidyverse)
library(psych)
library(qgraph)
library(readxl)
library(lavaan)
library(stats)

# Daten einlesen
daten <- read_excel("data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Items definieren
items <- c(
  paste0("I", c(1:25, 27:38)),
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]

# AMAB Gruppe definieren
daten_amab <- daten %>% 
  filter(grepl("AMAB", `Gender identity`))

# ESEM Analysen durchführen
esem_gesamt <- fa(daten[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_amab <- fa(daten_amab[items], nfactors = 7, rotate = "oblimin", fm = "ml")

# Regenbogenfarben für die 7 Faktoren
regenbogen_farben <- c(
  "#FF0000",  # Rot - Psychological Functioning
  "#FF7F00",  # Orange - Social Gender Role Recognition
  "#FFFF00",  # Gelb - Physical and Emotional Intimacy
  "#00FF00",  # Grün - Life Satisfaction
  "#0000FF",  # Blau - Body Image
  "#4B0082",  # Indigo - Genitalia
  "#9400D3"   # Violett - Gender Identity
)

# Originale GCLS Faktorbezeichnungen
faktor_namen <- c(
  "PF",   # Psychological Functioning
  "SGR",  # Social Gender Role Recognition
  "PEI",  # Physical and Emotional Intimacy
  "LS",   # Life Satisfaction
  "BI",   # Body Image
  "GEN",  # Genitalia
  "GI"    # Gender Identity
)

# Funktion zum Berechnen der Fit-Indizes
berechne_fit_indizes <- function(modell, n) {
  # Chi-Quadrat
  chi_square <- modell$STATISTIC
  df <- modell$dof
  p_value <- modell$PVAL
  
  # RMSEA
  rmsea <- sqrt(max(chi_square/(df * n) - 1/n, 0))
  
  # CFI & TLI
  null_model <- principal(modell$r, nfactors = 1, rotate = "none")
  cfi <- 1 - max(chi_square - df, 0) / max(null_model$STATISTIC - null_model$dof, chi_square - df, 0)
  tli <- ((null_model$STATISTIC/null_model$dof) - (chi_square/df)) / ((null_model$STATISTIC/null_model$dof) - 1)
  
  return(list(
    chi_square = chi_square,
    df = df,
    p_value = p_value,
    rmsea = rmsea,
    cfi = cfi,
    tli = tli
  ))
}

# Funktion zum Erstellen des Path-Diagramms
erstelle_path_diagramm <- function(esem_modell, titel, n) {
  # Extrahiere Ladungen und Korrelationen
  loadings <- esem_modell$loadings
  phi <- esem_modell$Phi
  
  # Berechne Fit-Indizes
  fit <- berechne_fit_indizes(esem_modell, n)
  
  # Erstelle Adjazenzmatrix für das Netzwerk
  n_items <- nrow(loadings)
  n_faktoren <- ncol(loadings)
  n_total <- n_items + n_faktoren
  
  # Initialisiere die Adjazenzmatrix und Edge-Colors
  adj_matrix <- matrix(0, n_total, n_total)
  edge_colors <- matrix("grey70", n_total, n_total)
  
  # Füge Faktorladungen hinzu
  for(i in 1:n_items) {
    # Finde die höchste Ladung für jedes Item
    max_loading <- max(abs(loadings[i,]))
    for(j in 1:n_faktoren) {
      if(abs(loadings[i,j]) > 0.3) {
        adj_matrix[i, n_items + j] <- loadings[i,j]
        # Primärladung in Faktorfarbe, Nebenladungen in grau
        if(abs(loadings[i,j]) == max_loading) {
          edge_colors[i, n_items + j] <- regenbogen_farben[j]
        }
      }
    }
  }
  
  # Füge Faktorkorrelationen hinzu
  for(i in 1:n_faktoren) {
    for(j in 1:n_faktoren) {
      if(i != j) {
        adj_matrix[n_items + i, n_items + j] <- phi[i,j]
      }
    }
  }
  
  # Erstelle Knotenlabels
  labels <- c(rownames(loadings), faktor_namen)
  
  # Definiere Knotenfarben
  node_colors <- c(rep("white", n_items), regenbogen_farben)
  
  # Erstelle das Path-Diagramm
  qgraph(adj_matrix,
         layout = "spring",
         labels = labels,
         nodeNames = labels,
         color = node_colors,
         edge.color = edge_colors,
         border.width = 1.5,
         border.color = "black",
         label.scale = FALSE,
         label.cex = 0.8,
         edge.labels = TRUE,
         edge.label.cex = 0.4,
         legend = FALSE,
         title = paste0(
           titel, "\n",
           "GCLS-G v1.1, N = ", n, ", ", format(Sys.Date(), "%d.%m.%Y"), "\n",
           sprintf("χ²(%d) = %.2f, p = %.3f, RMSEA = %.3f, CFI = %.3f, TLI = %.3f",
                  fit$df, fit$chi_square, fit$p_value, 
                  fit$rmsea, fit$cfi, fit$tli)
         ),
         vsize = c(rep(3, n_items), rep(8, n_faktoren)))
}

# Funktion zum Erstellen des Cluster-Diagramms
erstelle_cluster_diagramm <- function(esem_modell, titel, n) {
  # Extrahiere Ladungen
  loadings <- esem_modell$loadings
  
  # Berechne Distanzmatrix
  dist_matrix <- dist(abs(loadings))
  
  # Führe hierarchisches Clustering durch
  hc <- hclust(dist_matrix, method = "ward.D2")
  
  # Erstelle das Cluster-Diagramm
  plot(hc, 
       main = paste0(titel, " - Item Clustering\nN = ", n),
       xlab = "",
       ylab = "Distance",
       sub = "",
       cex = 0.8)
  
  # Füge horizontale Linien für die 7 Cluster hinzu
  abline(h = mean(hc$height) * 0.7, col = "red", lty = 2)
}

# Funktion zum Erstellen des detaillierten Cluster-Diagramms
erstelle_detailliertes_cluster_diagramm <- function(esem_modell, titel, n) {
  # Extrahiere Ladungen
  loadings <- esem_modell$loadings
  
  # Berechne Distanzmatrix
  dist_matrix <- dist(abs(loadings))
  
  # Führe hierarchisches Clustering durch
  hc <- hclust(dist_matrix, method = "ward.D2")
  
  # Erstelle das Cluster-Diagramm
  plot(hc, 
       main = paste0(titel, " - Item Clustering\nN = ", n),
       xlab = "",
       ylab = "Distance",
       sub = "",
       cex = 0.8)
  
  # Füge horizontale Linien für die 7 Cluster hinzu
  abline(h = mean(hc$height) * 0.7, col = "red", lty = 2)
  
  # Füge Skaleneinzeichnung hinzu
  axis(2, at = seq(0, max(hc$height), length.out = 5), 
       labels = round(seq(0, max(hc$height), length.out = 5), 2),
       las = 2)
  
  # Füge Legende hinzu
  legend("topright", 
         legend = c("7-Faktor-Lösung", "Item-Cluster"),
         col = c("red", "black"),
         lty = c(2, 1),
         cex = 0.8,
         bty = "n")
}

# Funktion zum Erstellen des detaillierten Cluster-Diagramms mit verbesserter Legende
erstelle_detailliertes_cluster_diagramm_verbessert <- function(esem_modell, titel, n) {
  # Extrahiere Ladungen
  loadings <- esem_modell$loadings
  
  # Berechne Distanzmatrix
  dist_matrix <- dist(abs(loadings))
  
  # Führe hierarchisches Clustering durch
  hc <- hclust(dist_matrix, method = "ward.D2")
  
  # Erstelle das Cluster-Diagramm
  plot(hc, 
       main = paste0(titel, " - Item Clustering\nN = ", n),
       xlab = "",
       ylab = "Distance",
       sub = "",
       cex = 0.8)
  
  # Füge horizontale Linien für die 7 Cluster hinzu
  abline(h = mean(hc$height) * 0.7, col = "red", lty = 2)
  
  # Füge Skaleneinzeichnung hinzu
  axis(2, at = seq(0, max(hc$height), length.out = 5), 
       labels = round(seq(0, max(hc$height), length.out = 5), 2),
       las = 2)
  
  # Füge verbesserte Legende hinzu
  legend("topright", 
         legend = c("7-Faktor-Lösung", "Item-Cluster", "Faktor 1: PF", "Faktor 2: SGR", 
                   "Faktor 3: PEI", "Faktor 4: LS", "Faktor 5: BI", "Faktor 6: GEN", "Faktor 7: GI"),
         col = c("red", "black", regenbogen_farben),
         lty = c(2, 1, rep(1, 7)),
         cex = 0.7,
         bty = "n",
         ncol = 2)
}

# Erstelle alle vier Diagramme in einem 2x2 Layout
pdf("analysis/factor_analysis/vergleich_gesamt.pdf", width = 20, height = 20)
par(mfrow = c(2, 2))
# Path-Diagramme
erstelle_path_diagramm(esem_gesamt, "Gesamtstichprobe", nrow(daten))
erstelle_path_diagramm(esem_amab, "AMAB", nrow(daten_amab))
# Cluster-Diagramme
erstelle_cluster_diagramm(esem_gesamt, "Gesamtstichprobe", nrow(daten))
erstelle_cluster_diagramm(esem_amab, "AMAB", nrow(daten_amab))
dev.off()

# Erstelle separate PDF mit detaillierten Cluster-Diagrammen
pdf("analysis/factor_analysis/cluster_vergleich.pdf", width = 20, height = 10)
par(mfrow = c(1, 2))
erstelle_detailliertes_cluster_diagramm_verbessert(esem_gesamt, "Gesamtstichprobe", nrow(daten))
erstelle_detailliertes_cluster_diagramm_verbessert(esem_amab, "AMAB", nrow(daten_amab))
dev.off() 