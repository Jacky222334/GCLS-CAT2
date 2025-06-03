# K-Fold Cross-Validation für die deutsche GCLS (angepasste Version)
library(readxl)
library(lavaan)
library(tidyverse)
library(caret)

# Daten einlesen und I26 bereinigen
data <- read_excel('/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_ESEM_compl_wI26_GI.xlsx')
data$I26[data$I26 == 0] <- NA

# Diagnostische Informationen
cat("\nStichprobengröße:", nrow(data))
cat("\nGeschlechtsidentitäts-Verteilung:\n")
print(table(data$`Gender identity`))

# K-Fold Cross-Validation Setup
set.seed(123)
k <- 5  # Reduziert auf 5 Folds

# Stratifizierte Folds
folds <- createFolds(data$`Gender identity`, k = k, list = TRUE)

# Größe der Folds prüfen
cat("\nFold-Größen:\n")
fold_sizes <- sapply(folds, length)
print(fold_sizes)

# ESEM Modell spezifizieren (vereinfacht)
model <- '
  # Faktor 1: Psychological functioning
  f1 =~ I1 + I2 + I4 + I6 + I7 + I8 + I9 + I11 + I12 + I13
  
  # Faktor 2: Genitalia
  f2 =~ I14 + I21 + I25 + I26 + I27 + I29
  
  # Faktor 3: Social gender role recognition
  f3 =~ I16 + I19 + I20 + I22
  
  # Faktor 4: Physical and emotional intimacy
  f4 =~ I3 + I5 + I32 + I33
  
  # Faktor 5: Chest
  f5 =~ I15 + I18 + I28 + I30
  
  # Faktor 6: Other secondary sex characteristics
  f6 =~ I17 + I23 + I24
  
  # Faktor 7: Life satisfaction
  f7 =~ I10 + I31 + I34 + I35 + I36 + I37 + I38
'

# Speicher für Fit-Indizes
fit_indices <- matrix(NA, nrow = k, ncol = 3)
colnames(fit_indices) <- c("CFI", "TLI", "RMSEA")

# Cross-Validation durchführen
cat("\nStarte 5-Fold Cross-Validation...\n")
for(i in 1:k) {
  cat(sprintf("\nFold %d von %d:\n", i, k))
  
  # Test-Set extrahieren
  test_indices <- folds[[i]]
  test_data <- data[test_indices, ]
  
  cat("Test-Set Größe:", nrow(test_data), "\n")
  cat("Test-Set Geschlechtsverteilung:\n")
  print(table(test_data$`Gender identity`))
  
  # Modell fitten
  tryCatch({
    fit <- sem(model, 
              data = test_data,
              estimator = "MLR",
              rotation = "geomin",
              orthogonal = FALSE,
              missing = "fiml")
    
    # Fit-Indizes speichern
    fit_indices[i,] <- c(
      CFI = fitMeasures(fit)["cfi.robust"],
      TLI = fitMeasures(fit)["tli.robust"],
      RMSEA = fitMeasures(fit)["rmsea.robust"]
    )
    
    cat(sprintf("CFI = %.3f, TLI = %.3f, RMSEA = %.3f\n", 
                fit_indices[i,1], fit_indices[i,2], fit_indices[i,3]))
    
  }, error = function(e) {
    cat("Fehler in Fold", i, ":", e$message, "\n")
  })
}

# Zusammenfassende Statistiken
fit_summary <- data.frame(
  Index = c("CFI", "TLI", "RMSEA"),
  Mean = colMeans(fit_indices, na.rm = TRUE),
  SD = apply(fit_indices, 2, sd, na.rm = TRUE),
  Min = apply(fit_indices, 2, min, na.rm = TRUE),
  Max = apply(fit_indices, 2, max, na.rm = TRUE),
  Q1 = apply(fit_indices, 2, quantile, probs = 0.25, na.rm = TRUE),
  Median = apply(fit_indices, 2, median, na.rm = TRUE),
  Q3 = apply(fit_indices, 2, quantile, probs = 0.75, na.rm = TRUE)
)

# Ergebnisse ausgeben
cat("\nZusammenfassung der Cross-Validation:\n")
print(fit_summary, digits = 3)

# Ergebnisse speichern
dir.create("results", showWarnings = FALSE)
write.csv(fit_indices, "results/cv_fit_indices.csv", row.names = FALSE)
write.csv(fit_summary, "results/cv_summary.csv", row.names = FALSE)

# Visualisierung
library(ggplot2)

# Boxplots der Fit-Indizes
fit_long <- as.data.frame(fit_indices) %>%
  gather(key = "Index", value = "Value")

p <- ggplot(fit_long, aes(x = Index, y = Value)) +
  geom_violin(fill = "lightblue", alpha = 0.5) +
  geom_boxplot(width = 0.2) +
  geom_hline(yintercept = c(0.90, 0.08), 
             linetype = "dashed", 
             color = "red") +
  facet_wrap(~Index, scales = "free") +
  theme_minimal() +
  labs(title = "Fit-Indizes über 5 Folds",
       subtitle = "Gestrichelte Linien zeigen akzeptable Fit-Werte",
       y = "Wert",
       x = "Fit-Index")

ggsave("results/cv_fit_indices_plot.png", p, width = 10, height = 6)

cat("\nAnalyse abgeschlossen. Ergebnisse wurden in results/ gespeichert.\n") 