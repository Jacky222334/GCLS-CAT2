# Datenstruktur-Check für GCLS K-Fold Cross-Validation
library(tidyverse)
library(readxl)
library(psych)

# Daten einlesen
cat("Lese ESEM Daten ein...\n")
esem_data <- try(read_excel("/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_ESEM_compl_wI26_GI.xlsx"))

# Funktion für Datencheck
check_data <- function(data, name) {
  cat("\nPrüfe", name, ":\n")
  cat("Dimensionen:", dim(data)[1], "Zeilen,", dim(data)[2], "Spalten\n")
  cat("Fehlende Werte pro Spalte:\n")
  print(colSums(is.na(data)))
  cat("\nStruktur der Daten:\n")
  str(data)
  cat("\nZusammenfassung der numerischen Variablen:\n")
  print(summary(data))
}

# GCLS Items prüfen
check_gcls_items <- function(data) {
  cat("\nPrüfe GCLS Items:\n")
  # Erwartete Items basierend auf dem ESEM Modell
  expected_items <- paste0("i", 1:38)
  
  # Prüfe ob alle Items vorhanden sind
  missing_items <- setdiff(expected_items, names(data))
  if(length(missing_items) > 0) {
    cat("Fehlende Items:", paste(missing_items, collapse=", "), "\n")
  } else {
    cat("Alle erwarteten Items sind vorhanden.\n")
  }
  
  # Prüfe Wertebereich (sollte 1-5 sein)
  # Finde alle Spalten, die mit 'i' beginnen
  item_cols <- grep("^i\\d+", names(data), value = TRUE)
  if(length(item_cols) > 0) {
    item_ranges <- sapply(data[,item_cols], range, na.rm=TRUE)
    cat("\nWertebereich der Items:\n")
    print(item_ranges)
    
    # Prüfe auf unerwartete Werte
    for(col in item_cols) {
      unique_vals <- sort(unique(data[[col]]))
      if(!all(unique_vals %in% 1:5)) {
        cat("\nWarnung: Unerwartete Werte in", col, ":", 
            setdiff(unique_vals, 1:5), "\n")
      }
    }
  } else {
    cat("Keine GCLS Items (beginnend mit 'i') gefunden.\n")
  }
}

# Hauptprüfung durchführen
cat("=== Datenstruktur-Prüfung für GCLS Cross-Validation ===\n")

if(inherits(esem_data, "try-error")) {
  cat("Fehler beim Einlesen der ESEM-Daten!\n")
  cat("Fehlermeldung:", attr(esem_data, "condition")$message, "\n")
} else {
  check_data(esem_data, "ESEM Daten")
  check_gcls_items(esem_data)
  
  # Prüfe Geschlechtsidentitäts-Variable für Stratifizierung
  gender_cols <- grep("gender|GI", names(esem_data), value = TRUE, ignore.case = TRUE)
  if(length(gender_cols) > 0) {
    cat("\nGefundene Gender-Variablen:", paste(gender_cols, collapse=", "), "\n")
    for(col in gender_cols) {
      cat("\nVerteilung für", col, ":\n")
      print(table(esem_data[[col]], useNA = "ifany"))
    }
  } else {
    cat("\nWarnung: Keine Geschlechtsidentitäts-Variable gefunden!\n")
  }
  
  # Speichere detaillierte Ergebnisse
  sink("../../results/data_check_results.txt")
  cat("=== Detaillierte Datenstruktur-Prüfung für GCLS Cross-Validation ===\n")
  cat("\nZeitpunkt der Prüfung:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
  check_data(esem_data, "ESEM Daten")
  check_gcls_items(esem_data)
  if(length(gender_cols) > 0) {
    cat("\nGeschlechtsidentitäts-Verteilungen:\n")
    for(col in gender_cols) {
      cat("\n", col, ":\n")
      print(table(esem_data[[col]], useNA = "ifany"))
    }
  }
  sink()
}

# Erstelle zusätzlich eine Korrelationsmatrix der Items
if(!inherits(esem_data, "try-error")) {
  item_cols <- grep("^i\\d+", names(esem_data), value = TRUE)
  if(length(item_cols) > 0) {
    cor_matrix <- cor(esem_data[,item_cols], use = "pairwise.complete.obs")
    write.csv(cor_matrix, "../../results/item_correlations.csv")
    
    # Visualisiere Korrelationsmatrix
    png("../../results/correlation_heatmap.png", width = 1200, height = 1000)
    heatmap(cor_matrix, 
            main = "GCLS Item Korrelationen",
            xlab = "Items",
            ylab = "Items",
            col = colorRampPalette(c("blue", "white", "red"))(100))
    dev.off()
  }
} 