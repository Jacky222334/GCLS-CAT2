# Installation und Laden der benötigten Pakete
if (!require("psych")) install.packages("psych")
if (!require("lavaan")) install.packages("lavaan")
if (!require("readxl")) install.packages("readxl")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("corrplot")) install.packages("corrplot")
if (!require("reshape2")) install.packages("reshape2")
if (!require("gridExtra")) install.packages("gridExtra")

library(psych)
library(lavaan)
library(readxl)
library(tidyverse)
library(ggplot2)
library(corrplot)
library(reshape2)
library(gridExtra)

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

# ESEM Analysen für alle Gruppen
esem_all <- fa(daten_all[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_amab_women <- fa(daten_amab_women[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_afab_men <- fa(daten_afab_men[items], nfactors = 7, rotate = "oblimin", fm = "ml")

# Funktion für Heatmap der Faktorladungen
create_loadings_heatmap <- function(loadings, title) {
  loadings_df <- as.data.frame(unclass(loadings))
  loadings_df$Item <- rownames(loadings_df)
  loadings_long <- melt(loadings_df, id.vars = "Item", variable.name = "Factor", value.name = "Loading")
  
  ggplot(loadings_long, aes(x = Factor, y = Item, fill = Loading)) +
    geom_tile() +
    scale_fill_gradient2(low = "blue", mid = "white", high = "red", 
                        midpoint = 0, limits = c(-1, 1)) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title.x = element_blank(),
          axis.title.y = element_blank()) +
    ggtitle(title)
}

# Heatmaps erstellen
p1 <- create_loadings_heatmap(esem_all$loadings, "Total Sample (N=293)")
p2 <- create_loadings_heatmap(esem_amab_women$loadings, "AMAB Women (n=154)")
p3 <- create_loadings_heatmap(esem_afab_men$loadings, "AFAB Men (n=97)")

# Heatmaps kombinieren und speichern
pdf("factor_loadings_comparison.pdf", width = 15, height = 15)
grid.arrange(p1, p2, p3, ncol = 1)
dev.off()

# Funktion für Korrelationsplot
create_correlation_plot <- function(phi, title) {
  corrplot(phi, method = "color", 
           type = "upper", 
           addCoef.col = "black",
           tl.col = "black",
           tl.srt = 45,
           title = title)
}

# Korrelationsplots erstellen
pdf("factor_correlations_comparison.pdf", width = 15, height = 5)
par(mfrow = c(1, 3))
create_correlation_plot(esem_all$Phi, "Total Sample")
create_correlation_plot(esem_amab_women$Phi, "AMAB Women")
create_correlation_plot(esem_afab_men$Phi, "AFAB Men")
dev.off()

# Varianzaufklärung vergleichen
variance_explained <- data.frame(
  Group = c("Total Sample", "AMAB Women", "AFAB Men"),
  Variance = c(sum(esem_all$Vaccounted[2,]),
              sum(esem_amab_women$Vaccounted[2,]),
              sum(esem_afab_men$Vaccounted[2,]))
)

# Varianzaufklärung visualisieren
pdf("variance_explained_comparison.pdf", width = 8, height = 6)
ggplot(variance_explained, aes(x = Group, y = Variance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  labs(title = "Total Variance Explained by Group",
       y = "Proportion of Variance Explained") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

# Modell-Fit Statistiken
fit_stats <- data.frame(
  Group = c("Total Sample", "AMAB Women", "AFAB Men"),
  ChiSquare = c(esem_all$STATISTIC,
                esem_amab_women$STATISTIC,
                esem_afab_men$STATISTIC),
  PValue = c(esem_all$PVAL,
             esem_amab_women$PVAL,
             esem_afab_men$PVAL)
)

# Fit Statistiken speichern
write.csv(fit_stats, "model_fit_comparison.csv", row.names = FALSE)

# Zusammenfassung der Ergebnisse
sink("esem_comparison_summary.txt")
cat("ESEM Analysis Comparison\n\n")
cat("Sample Sizes:\n")
cat("Total Sample: ", nrow(daten_all), "\n")
cat("AMAB Women: ", nrow(daten_amab_women), "\n")
cat("AFAB Men: ", nrow(daten_afab_men), "\n\n")
cat("Variance Explained:\n")
print(variance_explained)
cat("\nModel Fit Statistics:\n")
print(fit_stats)
sink() 