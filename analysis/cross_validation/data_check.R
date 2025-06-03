# Datenprüfung für GCLS K-Fold Cross-Validation
library(tidyverse)
library(readxl)
library(psych)

# Daten einlesen
data_path <- "/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_ESEM_compl_wI26_GI.xlsx"
data <- read_excel(data_path)

# Deskriptive Statistiken
desc_stats <- data %>%
  select(starts_with("I")) %>%
  summarise(across(everything(),
                  list(
                    mean = ~mean(., na.rm = TRUE),
                    sd = ~sd(., na.rm = TRUE),
                    skew = ~psych::skew(., na.rm = TRUE),
                    kurtosis = ~psych::kurtosi(., na.rm = TRUE)
                  )))

# Ergebnisse speichern
write.csv(desc_stats, "results/descriptive_stats.csv")

# Verteilung der Geschlechtsidentitäten
gender_dist <- table(data$`Gender identity`)
write.csv(as.data.frame(gender_dist), "results/gender_distribution.csv")

# Prüfe auf fehlende Werte
missing_values <- colSums(is.na(data))
write.csv(as.data.frame(missing_values), "results/missing_values.csv")

# Korrelationsmatrix der Items
cor_matrix <- cor(data[,1:38], use = "pairwise.complete.obs")
write.csv(cor_matrix, "results/correlation_matrix.csv")

# Visualisierung der Korrelationsmatrix
pdf("results/correlation_heatmap.pdf")
heatmap(cor_matrix,
        main = "GCLS Item Korrelationen",
        xlab = "Items",
        ylab = "Items",
        col = colorRampPalette(c("blue", "white", "red"))(100))
dev.off()

# Ausgabe der Ergebnisse
cat("\nDatenprüfung abgeschlossen. Ergebnisse wurden in results/ gespeichert.\n")
cat("\nStichprobengröße:", nrow(data))
cat("\nGeschlechtsidentitäts-Verteilung:\n")
print(gender_dist)
cat("\nBereich der Item-Werte:\n")
print(range(data[,1:38])) 