# Überprüfung von I26
library(readxl)

# Daten einlesen
data <- read_excel('/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_ESEM_compl_wI26_GI.xlsx')

# I26 extrahieren
i26 <- data$I26

# Verteilung vor Bereinigung
cat("\nVerteilung I26 vor Bereinigung:\n")
print(table(i26))

# Anzahl 0-Werte
n_zeros <- sum(i26 == 0)
cat("\nAnzahl 0-Werte:", n_zeros, "\n")

# Bereinigung
i26[i26 == 0] <- NA

# Verteilung nach Bereinigung
cat("\nVerteilung I26 nach Bereinigung:\n")
print(table(i26, useNA = "always"))

# Speichere die Information
sink("results/i26_info.txt")
cat("I26 Bereinigung:\n")
cat("Anzahl 0-Werte:", n_zeros, "\n")
cat("\nVerteilung nach Bereinigung:\n")
print(table(i26, useNA = "always"))
sink() 