# Einfache K-Fold Cross-Validation für EFA
# Mit APA-konformen Visualisierungen

library(psych)
library(readxl)
library(ggplot2)
library(tidyr)
library(dplyr)
library(viridis)  # Für moderne Farbpalette
library(gridExtra)  # Für Subplot-Layout
library(grid)       # Für Textannotationen
library(cowplot)  # Für get_legend Funktion

# Daten einlesen
data <- read_excel("data/raw/dat_EFA_26.xlsx")
data_matrix <- as.matrix(data)
mode(data_matrix) <- "numeric"

# Parameter
k <- 3  # Optimale Anzahl Folds basierend auf Stichprobengröße
n <- nrow(data_matrix)
fold_size <- floor(n/k)

# Überprüfe Mindestgröße pro Fold
min_obs_per_var <- 2.5  # Mindestanzahl Beobachtungen pro Variable
n_vars <- ncol(data_matrix)
min_size_needed <- ceiling(min_obs_per_var * n_vars)

cat(sprintf("\nDurchführe %d-Fold Cross-Validation mit:\n", k))
cat(sprintf("- %d Beobachtungen pro Fold\n", fold_size))
cat(sprintf("- %.1f Beobachtungen pro Variable pro Fold\n", fold_size/n_vars))

# Cross-Validation durchführen
set.seed(42)
indices <- sample(1:n)
results <- matrix(NA, nrow = k, ncol = 3)
colnames(results) <- c("RMSEA", "TLI", "CFI")

for(i in 1:k) {
  # Testdaten auswählen
  start_idx <- (i-1) * fold_size + 1
  end_idx <- min(i * fold_size, n)
  test_indices <- indices[start_idx:end_idx]
  test_data <- data_matrix[test_indices,]
  
  cat(sprintf("\nFold %d: %d Beobachtungen", i, nrow(test_data)))
  
  fa_result <- try(fa(test_data, 
                      nfactors = 7,
                      rotate = "oblimin",
                      fm = "ml"), silent = TRUE)
  
  if(!inherits(fa_result, "try-error")) {
    results[i, "RMSEA"] <- fa_result$RMSEA[1]
    results[i, "TLI"] <- fa_result$TLI
    results[i, "CFI"] <- fa_result$CFI
  } else {
    warning(sprintf("Konvergenzproblem in Fold %d", i))
  }
}

# Prüfe auf erfolgreiche Durchführung
if(all(is.na(results))) {
  stop("Keine erfolgreichen Fits - überprüfen Sie die Foldgröße")
}

# Daten für Plots vorbereiten
results_df <- as.data.frame(results)
results_df$Fold <- 1:k

results_long <- results_df %>%
  pivot_longer(cols = c("RMSEA", "TLI", "CFI"),
               names_to = "Index",
               values_to = "Value")

# Berechne Konfidenzintervalle
means <- colMeans(results, na.rm = TRUE)
sds <- apply(results, 2, sd, na.rm = TRUE)
ci_lower <- means - 1.96 * sds / sqrt(k)
ci_upper <- means + 1.96 * sds / sqrt(k)

ci_df <- data.frame(
  Index = names(means),
  Mean = means,
  Lower = ci_lower,
  Upper = ci_upper
)

# Verzeichnis erstellen
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# APA-konforme Theme-Einstellungen
theme_apa <- function(base_size = 10) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(size = 11, face = "bold"),
      plot.subtitle = element_text(size = 10),
      axis.title = element_text(size = 10),
      axis.text = element_text(size = 9),
      legend.position = "bottom",
      legend.title = element_text(size = 9),
      legend.text = element_text(size = 8),
      plot.caption = element_text(size = 8, hjust = 0),
      panel.grid.major = element_line(color = "grey90"),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA)
    )
}

# Raincloud Plot
p1 <- ggplot(results_long, aes(x = Index, y = Value, fill = Index)) +
  geom_violin(width = 0.5, alpha = 0.4, position = position_nudge(x = 0.1)) +
  geom_point(aes(color = Index), 
             position = position_jitter(width = 0.05), 
             size = 2, 
             alpha = 0.7) +
  geom_boxplot(width = 0.1, alpha = 0.7, 
               position = position_nudge(x = -0.2),
               outlier.shape = NA) +
  scale_fill_viridis(discrete = TRUE, option = "D", alpha = 0.7) +
  scale_color_viridis(discrete = TRUE, option = "D") +
  theme_apa() +
  labs(
    title = "A",
    subtitle = "Distribution of Fit Indices",
    x = "Fit Index",
    y = "Value",
    caption = sprintf("Note. Distribution of fit indices across %d-fold cross-validation.", k)
  )

# Precision Plot
p2 <- ggplot(ci_df, aes(x = Index, y = Mean, color = Index)) +
  geom_linerange(aes(ymin = Lower, ymax = Upper), 
                linewidth = 1, alpha = 0.5) +
  geom_point(size = 2.5, alpha = 0.8) +
  geom_hline(yintercept = c(0.06, 0.90, 0.90), 
             linetype = "dashed", 
             color = "grey50",
             alpha = 0.5) +
  scale_color_viridis(discrete = TRUE, option = "D") +
  theme_apa() +
  labs(
    title = "B",
    subtitle = "Precision of Fit Indices",
    x = "Fit Index",
    y = "Value",
    caption = "Note. Mean values with 95% confidence intervals.\nDashed lines indicate conventional cut-off criteria."
  )

# Kombinierte Grafik mit gemeinsamer Legende
combined_plot <- plot_grid(
  p1 + theme(legend.position = "none"),
  p2 + theme(legend.position = "none"),
  ncol = 2,
  align = 'h',
  rel_widths = c(1, 1)
)

# Legende extrahieren
legend <- get_legend(
  p1 + 
    guides(fill = guide_legend(title = "Fit Index", nrow = 1)) +
    theme(legend.position = "bottom")
)

# Finale Grafik mit Legende
final_plot <- plot_grid(
  combined_plot,
  legend,
  ncol = 1,
  rel_heights = c(1, 0.1)
)

# Speichern als PDF in A4-Format
ggsave("output/figures/combined_fit_indices_apa.pdf", 
       final_plot,
       width = 8.27,      # A4 Breite in Zoll
       height = 5,        # Angepasste Höhe für besseres Verhältnis
       dpi = 300)

# Zusätzlich als PNG für einfache Vorschau
ggsave("output/figures/combined_fit_indices_apa.png", 
       final_plot,
       width = 8.27,
       height = 5,
       dpi = 300)

# Numerische Ergebnisse ausgeben
cat("\nErgebnisse der Cross-Validation:\n")
print(results)
cat("\nMittelwerte:\n")
print(means)
cat("\nStandardabweichungen:\n")
print(sds)
cat("\n95% Konfidenzintervalle:\n")
print(ci_df)

# Erstelle Zusammenfassungstabelle
summary_df <- data.frame(
  Fit_Index = c("RMSEA", "TLI", "CFI"),
  Mittelwert = sprintf("%.3f", means),
  CI_Lower = sprintf("%.3f", ci_lower),
  CI_Upper = sprintf("%.3f", ci_upper),
  SD = sprintf("%.3f", sds),
  CV = sprintf("%.1f%%", 100 * sds / abs(means))
)

# Speichere Zusammenfassungstabelle
write.csv(summary_df, 
          "output/cross_validation/fit_indices_summary.csv", 
          row.names = FALSE)

# Drucke formatierte Tabelle
cat("\nZusammenfassungstabelle:\n")
print(summary_df, row.names = FALSE) 