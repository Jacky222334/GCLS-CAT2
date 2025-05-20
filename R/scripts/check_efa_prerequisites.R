# EFA Prerequisites Check
# Voraussetzungsprüfung für Exploratorische Faktorenanalyse

# Benötigte Pakete laden
library(psych)
library(corrplot)
library(tidyverse)

#' Prüfe EFA-Voraussetzungen
#' @param data Datensatz mit den GCLS-Items
#' @return Liste mit Testergebnissen und Visualisierungen
check_efa_prerequisites <- function(data) {
  # 1. Stichprobengröße
  n_subjects <- nrow(data)
  n_items <- ncol(data)
  subject_item_ratio <- n_subjects / n_items
  
  # 2. KMO-Test
  kmo_result <- KMO(cor(data))
  
  # 3. Bartlett-Test
  bartlett_result <- cortest.bartlett(cor(data), n = n_subjects)
  
  # 4. Verteilungsanalyse
  distribution_stats <- data.frame(
    Item = names(data),
    Mean = colMeans(data, na.rm = TRUE),
    SD = apply(data, 2, sd, na.rm = TRUE),
    Skewness = apply(data, 2, psych::skew, na.rm = TRUE),
    Kurtosis = apply(data, 2, psych::kurtosi, na.rm = TRUE)
  )
  
  # 5. Korrelationsmatrix
  cor_matrix <- cor(data, use = "pairwise.complete.obs")
  
  # Ergebnistabelle erstellen
  results_table <- data.frame(
    Criterion = c(
      "Stichprobengröße (N)",
      "Anzahl Items",
      "Verhältnis N:Items",
      "KMO-Gesamtwert",
      "Bartlett Chi-Quadrat",
      "Bartlett p-Wert"
    ),
    Value = c(
      n_subjects,
      n_items,
      round(subject_item_ratio, 2),
      round(kmo_result$MSA, 3),
      round(bartlett_result$chisq, 2),
      format.pval(bartlett_result$p.value, digits = 3)
    ),
    Interpretation = c(
      ifelse(n_subjects >= 200, "✓ Ausreichend", "× Zu klein"),
      "",
      ifelse(subject_item_ratio >= 5, "✓ Ausreichend", "× Zu klein"),
      ifelse(kmo_result$MSA >= 0.8, "✓ Sehr gut", "× Unzureichend"),
      "",
      ifelse(bartlett_result$p.value < 0.05, "✓ Signifikant", "× Nicht signifikant")
    )
  )
  
  # Verteilungstabelle erstellen
  distribution_summary <- distribution_stats %>%
    mutate(
      Normal = ifelse(abs(Skewness) < 2 & abs(Kurtosis) < 7,
                     "✓ Normal", "× Nicht normal")
    )
  
  # Ergebnisse zurückgeben
  return(list(
    sample_size = list(
      n = n_subjects,
      items = n_items,
      ratio = subject_item_ratio
    ),
    kmo = kmo_result,
    bartlett = bartlett_result,
    distributions = distribution_summary,
    correlations = cor_matrix,
    summary_table = results_table
  ))
}

# Funktion zum Erstellen der Korrelationsmatrix-Visualisierung
plot_correlation_matrix <- function(cor_matrix) {
  corrplot(cor_matrix,
          method = "color",
          type = "upper",
          order = "hclust",
          tl.col = "black",
          tl.srt = 45,
          addCoef.col = "black",
          number.cex = 0.7,
          title = "Korrelationsmatrix der GCLS-Items")
} 