# Run EFA Prerequisites Check
# Ausführung der EFA-Voraussetzungsprüfung

source("R/scripts/check_efa_prerequisites.R")

# Daten laden
data_file <- "data/processed/gcls_data.csv"
data <- read.csv(data_file)

# Nur GCLS-Items auswählen (38 Items)
gcls_items <- data[paste0("item_", 1:38)]

# Voraussetzungen prüfen
prerequisites <- check_efa_prerequisites(gcls_items)

# Ergebnisse ausgeben
cat("\nEFA-Voraussetzungsprüfung für G-GCLS\n")
cat("=====================================\n\n")

# Zusammenfassungstabelle ausgeben
print(prerequisites$summary_table)

cat("\nVerteilungsanalyse:\n")
print(prerequisites$distributions)

# Korrelationsmatrix visualisieren
pdf("figures/correlation_matrix.pdf")
plot_correlation_matrix(prerequisites$correlations)
dev.off()

# KMO-Details für einzelne Items
cat("\nKMO-Werte für einzelne Items:\n")
print(round(prerequisites$kmo$MSAi, 3))

# Ergebnisse speichern
saveRDS(prerequisites, "output/efa_prerequisites.rds") 