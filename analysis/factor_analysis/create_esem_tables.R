# Installation und Laden der benötigten Pakete
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("psych")) install.packages("psych")
if (!require("xtable")) install.packages("xtable")
if (!require("readxl")) install.packages("readxl")
if (!require("kableExtra")) install.packages("kableExtra")
if (!require("lavaan")) install.packages("lavaan")

library(tidyverse)
library(psych)
library(xtable)
library(readxl)
library(kableExtra)
library(lavaan)

# Daten einlesen
daten <- read_excel("data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Items definieren
items <- c(
  paste0("I", c(1:25, 27:38)),
  "I10_r", "I16_r", "I20_r", "I22_r", "I30_r", "I31_r", "I34_r", "I35_r", "I36_r", "I37_r", "I38_r"
)[1:37]

# AMAB Gruppe definieren
daten_amab <- daten %>% 
  filter(grepl("AMAB", `Gender identity`))

# ESEM Analysen durchführen
esem_gesamt <- fa(daten[items], nfactors = 7, rotate = "oblimin", fm = "ml")
esem_amab <- fa(daten_amab[items], nfactors = 7, rotate = "oblimin", fm = "ml")

# Originale GCLS Faktorbezeichnungen
faktor_namen <- c(
  "Psychological Functioning",
  "Social Gender Role Recognition", 
  "Physical and Emotional Intimacy",
  "Life Satisfaction",
  "Body Image",
  "Genitalia",
  "Gender Identity"
)

# Funktion zum Berechnen der Fit-Indizes
berechne_fit_indizes <- function(modell, n) {
  # Chi-Quadrat
  chi_square <- modell$chi
  df <- modell$dof
  p_value <- pchisq(chi_square, df, lower.tail = FALSE)
  
  # RMSEA
  rmsea <- sqrt(max(chi_square/(df * n) - 1/n, 0))
  rmsea_ci_lower <- rmsea * sqrt(qchisq(0.025, df) / qchisq(0.5, df))
  rmsea_ci_upper <- rmsea * sqrt(qchisq(0.975, df) / qchisq(0.5, df))
  
  # CFI & TLI
  null_model <- principal(modell$r, nfactors = 1, rotate = "none")
  cfi <- 1 - max(chi_square - df, 0) / max(null_model$values[1] - null_model$dof, chi_square - df, 0)
  tli <- ((null_model$values[1]/null_model$dof) - (chi_square/df)) / ((null_model$values[1]/null_model$dof) - 1)
  
  # SRMR
  srmr <- sqrt(mean((modell$residual)^2, na.rm = TRUE))
  
  return(data.frame(
    Modell = "ESEM",
    N = n,
    Chi_Square = chi_square,
    df = df,
    p = p_value,
    CFI = cfi,
    TLI = tli,
    RMSEA = rmsea,
    RMSEA_CI_Lower = rmsea_ci_lower,
    RMSEA_CI_Upper = rmsea_ci_upper,
    SRMR = srmr
  ))
}

# Funktion zum Erstellen der Faktorladungstabelle
erstelle_ladungstabelle <- function(modell, gruppe) {
  loadings <- unclass(modell$loadings)
  
  # Erstelle Dataframe mit Ladungen
  ladungen_df <- as.data.frame(loadings)
  colnames(ladungen_df) <- faktor_namen
  
  # Berechne Standardfehler
  n <- nrow(loadings)
  se <- 1/sqrt(n-1)
  
  # Erstelle Dataframe mit Standardfehlern
  se_df <- as.data.frame(matrix(se, nrow=nrow(loadings), ncol=ncol(loadings)))
  colnames(se_df) <- paste0("SE_", faktor_namen)
  
  # Kombiniere Ladungen und SE
  ergebnis <- data.frame(
    Gruppe = gruppe,
    Item = rownames(loadings),
    ladungen_df,
    se_df
  )
  
  return(ergebnis)
}

# Funktion zum Erstellen der Faktorkorrelationstabelle
erstelle_korrelationstabelle <- function(modell) {
  korr <- modell$Phi
  colnames(korr) <- rownames(korr) <- faktor_namen
  
  # Füge untere Dreiecksmatrix hinzu
  korr[lower.tri(korr)] <- t(korr)[lower.tri(korr)]
  
  return(as.data.frame(korr))
}

# Funktion zum Erstellen der deskriptiven Statistiken
erstelle_deskriptive_statistiken <- function(daten, items) {
  # Berechne Mittelwerte und Standardabweichungen
  desc <- describe(daten[items])
  
  # Berechne Reliabilitäten (Cronbachs Alpha) für jeden Faktor
  # Hier müssen Sie die Items pro Faktor definieren
  # Dies ist ein Beispiel:
  faktoren_items <- list(
    F1 = items[1:5],
    F2 = items[6:10],
    F3 = items[11:15],
    F4 = items[16:20],
    F5 = items[21:25],
    F6 = items[26:31],
    F7 = items[32:37]
  )
  
  reliabilitaeten <- sapply(faktoren_items, function(x) {
    alpha(daten[x])$total$raw_alpha
  })
  
  ergebnis <- data.frame(
    Faktor = faktor_namen,
    M = sapply(faktoren_items, function(x) mean(unlist(daten[x]), na.rm = TRUE)),
    SD = sapply(faktoren_items, function(x) sd(unlist(daten[x]), na.rm = TRUE)),
    Alpha = reliabilitaeten
  )
  
  return(ergebnis)
}

# Erstelle Tabellen für Gesamtstichprobe
fit_gesamt <- berechne_fit_indizes(esem_gesamt, nrow(daten))
ladungen_gesamt <- erstelle_ladungstabelle(esem_gesamt, "Gesamtstichprobe")
korr_gesamt <- erstelle_korrelationstabelle(esem_gesamt)
desc_gesamt <- erstelle_deskriptive_statistiken(daten, items)

# Erstelle Tabellen für AMAB
fit_amab <- berechne_fit_indizes(esem_amab, nrow(daten_amab))
ladungen_amab <- erstelle_ladungstabelle(esem_amab, "AMAB")
korr_amab <- erstelle_korrelationstabelle(esem_amab)
desc_amab <- erstelle_deskriptive_statistiken(daten_amab, items)

# Speichere Tabellen als HTML und LaTeX
# Fit-Indizes
write.csv(rbind(fit_gesamt, fit_amab), "esem_fit_indices.csv", row.names = FALSE)

# Faktorladungen
write.csv(rbind(ladungen_gesamt, ladungen_amab), "esem_factor_loadings.csv", row.names = FALSE)

# Faktorkorrelationen
write.csv(list(Gesamtstichprobe = korr_gesamt, AMAB = korr_amab), "esem_factor_correlations.csv")

# Deskriptive Statistiken
write.csv(list(Gesamtstichprobe = desc_gesamt, AMAB = desc_amab), "esem_descriptives.csv")

# Erstelle auch HTML-Versionen für einfachere Ansicht
# Fit-Indizes
rbind(fit_gesamt, fit_amab) %>%
  kable("html", digits = 3, caption = "Model Fit Indices") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  save_kable("esem_fit_indices.html")

# Faktorladungen (nur signifikante Ladungen > 0.3)
rbind(ladungen_gesamt, ladungen_amab) %>%
  kable("html", digits = 3, caption = "Standardized Factor Loadings") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  save_kable("esem_factor_loadings.html")

# Faktorkorrelationen
korr_gesamt %>%
  kable("html", digits = 3, caption = "Factor Correlations (Total Sample)") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  save_kable("esem_factor_correlations_total.html")

korr_amab %>%
  kable("html", digits = 3, caption = "Factor Correlations (AMAB)") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  save_kable("esem_factor_correlations_amab.html")

# Deskriptive Statistiken
desc_gesamt %>%
  kable("html", digits = 3, caption = "Descriptive Statistics (Total Sample)") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  save_kable("esem_descriptives_total.html")

desc_amab %>%
  kable("html", digits = 3, caption = "Descriptive Statistics (AMAB)") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  save_kable("esem_descriptives_amab.html")

# Prepare item data - columns are named I1 to I38
item_data <- daten %>%
  select(starts_with("I")) %>%
  rename_with(~paste0("item", gsub("I", "", .)))

# Define the ESEM model
esem_model <- '
# Define factors
Soc =~ NA*item8 + item9 + item10 + item11 + item12 + item13
Gen =~ NA*item14 + item21 + item25 + item27 + item29
Psych =~ NA*item1 + item2 + item3 + item4 + item5 + item6 + item7
Chest =~ NA*item15 + item18 + item28 + item30
Life =~ NA*item19 + item20 + item22
Intim =~ NA*item31 + item32 + item33 + item34
Sec =~ NA*item16 + item17 + item23 + item24 + item35 + item36 + item37 + item38

# Allow factors to correlate
Soc ~~ Gen + Psych + Chest + Life + Intim + Sec
Gen ~~ Psych + Chest + Life + Intim + Sec
Psych ~~ Chest + Life + Intim + Sec
Chest ~~ Life + Intim + Sec
Life ~~ Intim + Sec
Intim ~~ Sec

# Set factor variances to 1
Soc ~~ 1*Soc
Gen ~~ 1*Gen
Psych ~~ 1*Psych
Chest ~~ 1*Chest
Life ~~ 1*Life
Intim ~~ 1*Intim
Sec ~~ 1*Sec
'

# Fit the ESEM model
esem_fit <- cfa(esem_model, 
                data = item_data,
                estimator = "ML",
                rotation = "geomin",
                rotation.args = list(orthogonal = FALSE))

# Extract factor loadings and covariances
factor_loadings <- parameterEstimates(esem_fit, standardized = TRUE) %>%
  filter(op == "=~") %>%
  select(lhs, rhs, est, std.all, pvalue)

factor_covariances <- parameterEstimates(esem_fit, standardized = TRUE) %>%
  filter(op == "~~") %>%
  select(lhs, rhs, est, std.all, pvalue)

# Create a table for factor loadings
factor_loadings_table <- factor_loadings %>%
  arrange(lhs, rhs) %>%
  mutate(
    est = round(est, 3),
    std.all = round(std.all, 3),
    pvalue = round(pvalue, 3)
  )

# Create a table for factor covariances
factor_covariances_table <- factor_covariances %>%
  arrange(lhs, rhs) %>%
  mutate(
    est = round(est, 3),
    std.all = round(std.all, 3),
    pvalue = round(pvalue, 3)
  )

# Save the tables to CSV files
write.csv(factor_loadings_table, "analysis/factor_analysis/esem_factor_loadings_lavaan.csv", row.names = FALSE)
write.csv(factor_covariances_table, "analysis/factor_analysis/esem_factor_covariances_lavaan.csv", row.names = FALSE)

# Print the tables
print(factor_loadings_table)
print(factor_covariances_table) 