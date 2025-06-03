# ESEM-Analyse der deutschen GCLS
library(readxl)
library(lavaan)
library(tidyverse)

# Daten einlesen und I26 bereinigen
data <- read_excel('/Users/janschulze/Dokumente/GCLS_german_190520125/data/raw/dat_ESEM_compl_wI26_GI.xlsx')
cat("Anzahl 0-Werte in I26:", sum(data$I26 == 0), "\n")
data$I26[data$I26 == 0] <- NA
cat("Anzahl NA-Werte in I26 nach Bereinigung:", sum(is.na(data$I26)), "\n")

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

# ESEM mit FIML für fehlende Werte
fit <- sem(model, 
          data = data,
          estimator = "MLR",
          rotation = "geomin",
          orthogonal = FALSE,
          missing = "fiml")

# Fit-Indizes
fit_indices <- fitMeasures(fit, c("cfi.robust", "tli.robust", "rmsea.robust"))
cat("\nFit-Indizes:\n")
print(fit_indices)

# Faktorladungen
loadings <- standardizedSolution(fit)
write.csv(loadings, "results/esem_loadings.csv", row.names = FALSE)

# Modifikationsindizes
mi <- modificationindices(fit)
write.csv(mi[order(-mi$mi),], "results/modification_indices.csv", row.names = FALSE)

# Residuen
residuals <- residuals(fit, type = "normalized")
write.csv(as.data.frame(residuals), "results/residuals.csv") 