# K-Fold Cross-Validation für die deutsche GCLS
# Autor: Jan Ben Schulze
# Datum: [aktuelles Datum]

# Benötigte Packages
library(tidyverse)
library(lavaan)
library(caret)
library(ggplot2)
library(gridExtra)
library(readxl)

# Daten einlesen
gcls_data <- read.csv("../../data/processed/gcls_scores.csv")
demo_data <- read_excel("../../data/processed/transition_data_cleaned.xlsx")

# ESEM Modell spezifizieren (basierend auf 7-Faktoren Struktur)
gcls_model <- '
  # Faktor 1: Psychological functioning
  f1 =~ i1 + i2 + i4 + i6 + i7 + i8 + i9 + i11 + i12 + i13
  
  # Faktor 2: Genitalia
  f2 =~ i14 + i21 + i25 + i26 + i27 + i29
  
  # Faktor 3: Social gender role recognition
  f3 =~ i16 + i19 + i20 + i22
  
  # Faktor 4: Physical and emotional intimacy
  f4 =~ i3 + i5 + i32 + i33
  
  # Faktor 5: Chest
  f5 =~ i15 + i18 + i28 + i30
  
  # Faktor 6: Other secondary sex characteristics
  f6 =~ i17 + i23 + i24
  
  # Faktor 7: Life satisfaction
  f7 =~ i10 + i31 + i34 + i35 + i36 + i37 + i38

  # Korrelationen zwischen Faktoren
  f1 ~~ f2 + f3 + f4 + f5 + f6 + f7
  f2 ~~ f3 + f4 + f5 + f6 + f7
  f3 ~~ f4 + f5 + f6 + f7
  f4 ~~ f5 + f6 + f7
  f5 ~~ f6 + f7
  f6 ~~ f7
'

# Funktion für Fit-Indizes Berechnung mit ESEM
calculate_fit <- function(model, data) {
  # ESEM Fit mit Geomin Rotation
  fit <- sem(model, 
            data = data, 
            estimator = "MLR",
            rotation = "geomin",
            orthogonal = FALSE)
  
  # Fit-Indizes extrahieren
  fits <- c(
    CFI = fitMeasures(fit)["cfi.robust"],
    TLI = fitMeasures(fit)["tli.robust"],
    RMSEA = fitMeasures(fit)["rmsea.robust"]
  )
  return(fits)
}

# K-Fold Cross-Validation
set.seed(123) # Reproduzierbarkeit
k <- 10 # Anzahl Folds

# Stratifizierte Folds basierend auf Geschlechtsidentität
folds <- createFolds(gcls_data$gender_identity, k = k, list = TRUE, returnTrain = FALSE)

# Speicher für Fit-Indizes
fit_indices <- matrix(NA, nrow = k, ncol = 3)
colnames(fit_indices) <- c("CFI", "TLI", "RMSEA")

# Cross-Validation durchführen
for(i in 1:k) {
  # Test-Fold extrahieren
  test_indices <- folds[[i]]
  test_data <- gcls_data[test_indices, ]
  
  # Fit-Indizes berechnen
  tryCatch({
    fit_indices[i,] <- calculate_fit(gcls_model, test_data)
    cat("Fold", i, "erfolgreich berechnet\n")
  }, error = function(e) {
    cat("Fehler in Fold", i, ":", e$message, "\n")
  })
}

# Ergebnisse visualisieren
fit_data <- as.data.frame(fit_indices) %>%
  gather(key = "Index", value = "Value")

# Boxplots und Violinplots erstellen
p <- ggplot(fit_data, aes(x = Index, y = Value)) +
  geom_violin(fill = "lightblue", alpha = 0.5) +
  geom_boxplot(width = 0.2) +
  geom_hline(yintercept = c(0.90, 0.08), linetype = "dashed", color = "red") +
  facet_wrap(~Index, scales = "free") +
  theme_minimal() +
  labs(title = "ESEM Fit-Indizes über 10 Folds",
       subtitle = "Gestrichelte Linien zeigen akzeptable Fit-Werte",
       y = "Wert",
       x = "Fit-Index")

# Plot speichern
ggsave("../../results/figures/kfold_fit_indices.png", p, width = 10, height = 6)

# Deskriptive Statistiken der Fit-Indizes
fit_summary <- fit_data %>%
  group_by(Index) %>%
  summarise(
    N = n(),
    Mean = mean(Value),
    Median = median(Value),
    SD = sd(Value),
    CI_lower = quantile(Value, 0.025),
    CI_upper = quantile(Value, 0.975)
  )

# Ergebnisse speichern
write.csv(fit_summary, "../../results/tables/kfold_fit_summary.csv", row.names = FALSE)

# Ausgabe der Zusammenfassung
print(fit_summary) 