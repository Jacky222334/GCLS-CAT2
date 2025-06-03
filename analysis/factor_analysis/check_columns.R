# Pakete laden
library(readxl)

# Daten einlesen
daten <- read_excel("../../data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Spaltennamen anzeigen
print("Spaltennamen:")
print(names(daten))

# Wenn es eine Spalte mit "gender" oder "Gender" im Namen gibt, deren Werte anzeigen
gender_cols <- grep("gender|Gender", names(daten), value = TRUE, ignore.case = TRUE)
if(length(gender_cols) > 0) {
  print("\nWerte in Gender-Spalten:")
  for(col in gender_cols) {
    print(paste("\nSpalte:", col))
    print(table(daten[[col]]))
  }
} 