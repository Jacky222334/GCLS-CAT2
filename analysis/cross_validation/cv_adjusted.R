# Angepasste Cross-Validation der deutschen GCLS
library(readxl)
library(lavaan)
library(tidyverse)
library(caret)
library(psych)

# Daten einlesen
data <- read_excel('/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_ESEM_compl_wI26_GI.xlsx')

# Datenbereinigung
# 1. I26 als NA kodieren (0-Werte)
data$I26[data$I26 == 0] <- NA

# 2. I25 umpolen
data$I25_r <- 6 - data$I25  # Umpolung auf 5er Skala

# Diagnostische Informationen
cat("\nStichprobengröße:", nrow(data))
cat("\nGeschlechtsidentitäts-Verteilung:\n")
print(table(data$`Gender identity`))

# ESEM Modell spezifizieren (angepasst)
model <- '
  # Faktor 1: Psychological functioning (ohne I8 wegen niedriger Trennschärfe)
  f1 =~ I1 + I2 + I4 + I6 + I7 + I9 + I11 + I12 + I13
  
  # Faktor 2: Genitalia (mit umgepoltem I25)
  f2 =~ I14 + I21 + I25_r + I26 + I27 + I29
  
  # Faktor 3: Social gender role recognition
  f3 =~ I16 + I19 + I20 + I22
'

# K-Fold Cross-Validation Setup
set.seed(123)
k <- 5

# Stratifizierte Folds basierend auf Geschlechtsidentität
folds <- createFolds(data$`Gender identity`, k = k, list = TRUE)

# Speicher für Fit-Indizes und zusätzliche Statistiken
results <- list()
for(i in 1:k) {
  results[[i]] <- list(
    fit_indices = NA,
    factor_correlations = NA,
    reliability = NA
  )
}

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
    
    # Fit-Indizes
    results[[i]]$fit_indices <- c(
      CFI = fitMeasures(fit)["cfi.robust"],
      TLI = fitMeasures(fit)["tli.robust"],
      RMSEA = fitMeasures(fit)["rmsea.robust"]
    )
    
    # Faktorkorrelationen
    results[[i]]$factor_correlations <- lavInspect(fit, "cor.lv")
    
    # Reliabilität
    items_f1 <- c("I1","I2","I4","I6","I7","I9","I11","I12","I13")
    items_f2 <- c("I14","I21","I25_r","I26","I27","I29")
    items_f3 <- c("I16","I19","I20","I22")
    
    results[[i]]$reliability <- c(
      f1 = psych::alpha(test_data[,items_f1])$total$raw_alpha,
      f2 = psych::alpha(test_data[,items_f2], use="pairwise")$total$raw_alpha,
      f3 = psych::alpha(test_data[,items_f3])$total$raw_alpha
    )
    
    cat(sprintf("CFI = %.3f, TLI = %.3f, RMSEA = %.3f\n", 
                results[[i]]$fit_indices[1],
                results[[i]]$fit_indices[2],
                results[[i]]$fit_indices[3]))
    
    cat("Reliabilität:\n")
    print(results[[i]]$reliability)
    
  }, error = function(e) {
    cat("Fehler in Fold", i, ":", e$message, "\n")
  })
}

# Ergebnisse zusammenfassen
fit_indices <- t(sapply(results, function(x) x$fit_indices))
reliability <- t(sapply(results, function(x) x$reliability))

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

reliability_summary <- data.frame(
  Factor = c("F1", "F2", "F3"),
  Mean = colMeans(reliability, na.rm = TRUE),
  SD = apply(reliability, 2, sd, na.rm = TRUE),
  Min = apply(reliability, 2, min, na.rm = TRUE),
  Max = apply(reliability, 2, max, na.rm = TRUE)
)

# Ergebnisse ausgeben
cat("\nZusammenfassung der Cross-Validation:\n")
cat("\nFit-Indizes:\n")
print(fit_summary, digits = 3)
cat("\nReliabilität:\n")
print(reliability_summary, digits = 3)

# Ergebnisse speichern
dir.create("results", showWarnings = FALSE)
write.csv(fit_summary, "results/cv_fit_summary.csv", row.names = FALSE)
write.csv(reliability_summary, "results/cv_reliability_summary.csv", row.names = FALSE)

# Visualisierung
library(ggplot2)

# Boxplots der Fit-Indizes
fit_long <- as.data.frame(fit_indices) %>%
  gather(key = "Index", value = "Value")

p1 <- ggplot(fit_long, aes(x = Index, y = Value)) +
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

# Boxplots der Reliabilität
reliability_long <- as.data.frame(reliability) %>%
  gather(key = "Factor", value = "Alpha")

p2 <- ggplot(reliability_long, aes(x = Factor, y = Alpha)) +
  geom_violin(fill = "lightgreen", alpha = 0.5) +
  geom_boxplot(width = 0.2) +
  geom_hline(yintercept = 0.7, 
             linetype = "dashed", 
             color = "red") +
  theme_minimal() +
  labs(title = "Reliabilität über 5 Folds",
       subtitle = "Gestrichelte Linie zeigt akzeptablen Alpha-Wert",
       y = "Cronbachs Alpha",
       x = "Faktor")

# Plots speichern
ggsave("results/cv_fit_indices_plot.png", p1, width = 10, height = 6)
ggsave("results/cv_reliability_plot.png", p2, width = 8, height = 6)

cat("\nAnalyse abgeschlossen. Ergebnisse wurden in results/ gespeichert.\n") 