# Umfassende Analyse der deutschen GCLS-Validierung
# Autor: Jan Ben Schulze
# Datum: [aktuelles Datum]

# Benötigte Packages
library(tidyverse)
library(readxl)
library(lavaan)
library(psych)
library(caret)
library(gridExtra)

# Daten einlesen
data_path <- "/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_ESEM_compl_wI26_GI.xlsx"
data <- read_excel(data_path)

# I26 bereinigen: 0-Werte als NA kodieren
cat("Anzahl von 0-Werten in I26 vor der Bereinigung:", sum(data$I26 == 0), "\n")
data$I26[data$I26 == 0] <- NA
cat("Anzahl von NA-Werten in I26 nach der Bereinigung:", sum(is.na(data$I26)), "\n")

# Speichere bereinigte Daten
write_csv(data, "results/cleaned_data.csv")

###################
# 1. Datenprüfung #
###################

# Funktion für deskriptive Statistiken der Items
item_descriptives <- function(data) {
  items <- select(data, starts_with("I"))
  
  desc_stats <- items %>%
    summarise(across(everything(), 
                    list(
                      n = ~sum(!is.na(.)),
                      mean = ~mean(., na.rm = TRUE),
                      sd = ~sd(., na.rm = TRUE),
                      skew = ~psych::skew(., na.rm = TRUE),
                      kurtosis = ~psych::kurtosi(., na.rm = TRUE)
                    )))
  
  # Reshape für bessere Lesbarkeit
  desc_stats_long <- desc_stats %>%
    pivot_longer(everything(),
                names_to = c("Item", "Statistic"),
                names_pattern = "I(\\d+)_(.*)",
                values_to = "Value")
  
  # Umformen in breites Format
  desc_stats_wide <- desc_stats_long %>%
    pivot_wider(names_from = Statistic, values_from = Value)
  
  return(desc_stats_wide)
}

# Deskriptive Statistiken berechnen
desc_stats <- item_descriptives(data)
write.csv(desc_stats, "../../results/item_descriptives.csv", row.names = FALSE)

# Visualisierung der Item-Verteilungen
pdf("../../results/item_distributions.pdf")
for(i in 1:38) {
  item_name <- paste0("I", i)
  hist_data <- data[[item_name]]
  if(item_name == "I26") {
    hist_data <- hist_data[!is.na(hist_data)]  # Entferne NAs für I26
  }
  hist(hist_data, 
       main = paste("Verteilung", item_name),
       xlab = "Wert",
       ylab = "Häufigkeit",
       breaks = seq(0.5, 5.5, by = 1))
}
dev.off()

############################
# 2. K-Fold Cross-Validation #
############################

# ESEM Modell spezifizieren
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

# K-Fold Cross-Validation durchführen
set.seed(123)
k <- 10

# Stratifizierte Folds erstellen
folds <- createFolds(data$`Gender identity`, k = k, list = TRUE)

# Speicher für Fit-Indizes
fit_indices <- matrix(NA, nrow = k, ncol = 3)
colnames(fit_indices) <- c("CFI", "TLI", "RMSEA")

# Cross-Validation
for(i in 1:k) {
  cat("Bearbeite Fold", i, "von", k, "\n")
  
  # Test-Set
  test_indices <- folds[[i]]
  test_data <- data[test_indices, ]
  
  # Fit-Indizes berechnen
  tryCatch({
    fit <- sem(model, 
              data = test_data,
              estimator = "MLR",
              rotation = "geomin",
              orthogonal = FALSE,
              missing = "fiml")  # FIML für fehlende Werte
    
    fit_indices[i,] <- c(
      CFI = fitMeasures(fit)["cfi.robust"],
      TLI = fitMeasures(fit)["tli.robust"],
      RMSEA = fitMeasures(fit)["rmsea.robust"]
    )
    
    cat("Fold", i, "erfolgreich berechnet\n")
  }, error = function(e) {
    cat("Fehler in Fold", i, ":", e$message, "\n")
  })
}

# Ergebnisse speichern
fit_results <- as.data.frame(fit_indices)
write_csv(fit_results, "results/cv_fit_indices.csv")

# Visualisierung der Fit-Indizes
fit_long <- fit_results %>%
  pivot_longer(everything(), 
              names_to = "Index", 
              values_to = "Value")

# Boxplots mit Referenzlinien
p <- ggplot(fit_long, aes(x = Index, y = Value)) +
  geom_violin(fill = "lightblue", alpha = 0.5) +
  geom_boxplot(width = 0.2) +
  geom_hline(yintercept = c(0.90, 0.08), 
             linetype = "dashed", 
             color = "red") +
  facet_wrap(~Index, scales = "free") +
  theme_minimal() +
  labs(title = "Fit-Indizes über 10 Folds",
       subtitle = "Gestrichelte Linien zeigen akzeptable Fit-Werte",
       y = "Wert",
       x = "Fit-Index")

ggsave("results/cv_fit_indices_plot.png", p, width = 10, height = 6)

# Zusammenfassung der Fit-Indizes
fit_summary <- fit_long %>%
  group_by(Index) %>%
  summarise(
    N = n(),
    Mean = mean(Value, na.rm = TRUE),
    SD = sd(Value, na.rm = TRUE),
    Median = median(Value, na.rm = TRUE),
    CI_lower = quantile(Value, 0.025, na.rm = TRUE),
    CI_upper = quantile(Value, 0.975, na.rm = TRUE)
  )

write_csv(fit_summary, "results/cv_fit_summary.csv")

######################
# 3. Item-Analysen #
######################

# Interne Konsistenz (Cronbach's Alpha) für jeden Faktor
reliability <- list(
  f1 = psych::alpha(data[,c("I1","I2","I4","I6","I7","I8","I9","I11","I12","I13")])$total$raw_alpha,
  f2 = psych::alpha(data[,c("I14","I21","I25","I26","I27","I29")], use = "pairwise")$total$raw_alpha,  # pairwise für NA
  f3 = psych::alpha(data[,c("I16","I19","I20","I22")])$total$raw_alpha,
  f4 = psych::alpha(data[,c("I3","I5","I32","I33")])$total$raw_alpha,
  f5 = psych::alpha(data[,c("I15","I18","I28","I30")])$total$raw_alpha,
  f6 = psych::alpha(data[,c("I17","I23","I24")])$total$raw_alpha,
  f7 = psych::alpha(data[,c("I10","I31","I34","I35","I36","I37","I38")])$total$raw_alpha
)

write.csv(as.data.frame(reliability), "../../results/reliability.csv")

# Item-Total Korrelationen
item_total <- data %>%
  select(starts_with("I")) %>%
  psych::item.total(use = "pairwise")  # pairwise für NA

write.csv(item_total$item.stats, "../../results/item_total_correlations.csv")

# Zusammenfassende Statistiken pro Subgruppe
group_stats <- data %>%
  group_by(`Gender identity`) %>%
  summarise(across(starts_with("I"), 
                  list(n = ~sum(!is.na(.)),
                       mean = ~mean(., na.rm = TRUE),
                       sd = ~sd(., na.rm = TRUE))))

write.csv(group_stats, "../../results/group_statistics.csv")

# Abschließende Nachricht
cat("\nAnalyse abgeschlossen. Alle Ergebnisse wurden im 'results' Ordner gespeichert.\n") 