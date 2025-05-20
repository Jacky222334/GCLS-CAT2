# Datenaufbereitung für demografische und transspezifische Daten
library(readxl)
library(tidyverse)
library(lubridate)

#' Bereinige und strukturiere Rohdaten
#' @param file_path Pfad zur Excel-Datei
#' @return Liste mit aufbereiteten Datensätzen
prepare_data <- function(file_path) {
  # Rohdaten einlesen
  raw_data <- read_excel(file_path)
  
  # Demografische Daten
  demographic_data <- raw_data %>%
    select(
      id = antwortid,
      geburtsjahr = geb,
      wohnsituation = `@2wieistihremomentanewohnsituation`,
      beziehungsstatus = `@3wieistihrmomentanerbeziehungsstatus`,
      bildung = `@4wasistihrhoechsterabgeschlossenerbildungsgrad`,
      arbeit = `@5wieistihrederzeitigearbeitssituation`,
      alter = age2
    ) %>%
    mutate(
      alter = as.numeric(alter),
      geburtsjahr = as.numeric(geburtsjahr)
    )
  
  # Transspezifische Daten
  trans_specific_data <- raw_data %>%
    select(
      id = antwortid,
      geburtsgeschlecht = `@6welchesgeschlechtwurdeihnenbeigeburtzugewiesen`,
      geschlechtsidentitaet = `@7welchegeschlechtsidentitaetordnensiesichselbstzu`,
      inneres_coming_out_alter = inwelchemalterhattensieihrinnerescomingout,
      aeusseres_coming_out_alter = inwelchemalterhattensieihraeusserescomingout
    ) %>%
    mutate(
      inneres_coming_out_alter = as.numeric(inneres_coming_out_alter),
      aeusseres_coming_out_alter = as.numeric(aeusseres_coming_out_alter)
    )
  
  # Biomedizinische Maßnahmen
  transition_data <- raw_data %>%
    select(
      id = antwortid,
      massnahmen_allgemein = `@8habensieindervergangenheitmedizinischetransitionmassnahmeninan`,
      hormontherapie_oestrogen = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_a`,
      testosteron_blocker = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_b`,
      hormontherapie_testosteron = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_c`,
      logopaedie = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_d`,
      laserepilation = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_e`,
      gesichtsfeminisierung = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_f`,
      mastektomie = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_g`,
      brustaufbau = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_h`,
      hysterektomie = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_i`,
      neovaginoplastik = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_j`,
      phalloplastik = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_k`,
      stimmbandop = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_l`,
      adamsapfel = `@9fallssiediefrage 8mitjabeantwortethabenbeantwortensiebittef_m`,
      hormontherapie_beginn = fallssieuntereinerhormontherapiestehenseitwannnehmensiedieseein,
      retest_regret
    )
  
  # Erstelle Zusammenfassung der demografischen Daten
  demographic_summary <- demographic_data %>%
    summarise(
      n = n(),
      alter_mean = mean(alter, na.rm = TRUE),
      alter_sd = sd(alter, na.rm = TRUE),
      alter_range = paste(min(alter, na.rm = TRUE), max(alter, na.rm = TRUE), sep = "-")
    )
  
  # Erstelle Zusammenfassung der transspezifischen Daten
  trans_summary <- trans_specific_data %>%
    summarise(
      n = n(),
      inneres_coming_out_mean = mean(inneres_coming_out_alter, na.rm = TRUE),
      aeusseres_coming_out_mean = mean(aeusseres_coming_out_alter, na.rm = TRUE)
    )
  
  # Erstelle Zusammenfassung der biomedizinischen Maßnahmen
  transition_summary <- transition_data %>%
    summarise(
      across(
        starts_with(c("hormontherapie", "testosteron", "logopaedie", "laser", 
                     "gesichts", "mastek", "brust", "hyster", "neo", "phallo", 
                     "stimmband", "adamsapfel")),
        ~sum(. == "Ja", na.rm = TRUE)
      )
    ) %>%
    pivot_longer(
      everything(),
      names_to = "Massnahme",
      values_to = "Anzahl"
    ) %>%
    arrange(desc(Anzahl))
  
  # Gruppiere Maßnahmen nach Typ
  massnahmen_kategorien <- list(
    "Hormonelle Maßnahmen" = c("hormontherapie_oestrogen", "testosteron_blocker", 
                              "hormontherapie_testosteron"),
    "Operative Maßnahmen" = c("mastektomie", "brustaufbau", "hysterektomie", 
                             "neovaginoplastik", "phalloplastik", "stimmbandop", 
                             "adamsapfel", "gesichtsfeminisierung"),
    "Andere Maßnahmen" = c("logopaedie", "laserepilation")
  )
  
  # Erstelle kategorisierte Zusammenfassung
  kategorie_summary <- transition_data %>%
    summarise(
      across(unlist(massnahmen_kategorien), ~sum(. == "Ja", na.rm = TRUE))
    ) %>%
    pivot_longer(
      everything(),
      names_to = "Massnahme",
      values_to = "Anzahl"
    ) %>%
    mutate(
      Kategorie = case_when(
        Massnahme %in% massnahmen_kategorien[["Hormonelle Maßnahmen"]] ~ "Hormonell",
        Massnahme %in% massnahmen_kategorien[["Operative Maßnahmen"]] ~ "Operativ",
        TRUE ~ "Andere"
      )
    )
  
  # Speichere aufbereitete Daten
  write_csv(demographic_data, "data/processed/demographic_data.csv")
  write_csv(trans_specific_data, "data/processed/trans_specific_data.csv")
  write_csv(transition_data, "data/processed/transition_data.csv")
  
  # Erstelle Datenzusammenfassung
  cat("\nDatenzusammenfassung:\n")
  cat("====================\n")
  
  cat("\nDemografische Daten:\n")
  print(demographic_summary)
  
  cat("\nTransspezifische Daten:\n")
  print(trans_summary)
  
  cat("\nBiomedizinische Maßnahmen:\n")
  print(transition_summary)
  
  cat("\nMaßnahmen nach Kategorien:\n")
  print(kategorie_summary)
  
  return(list(
    demographic = demographic_data,
    trans_specific = trans_specific_data,
    transition = transition_data,
    summary = list(
      demographic = demographic_summary,
      trans = trans_summary,
      transition = transition_summary,
      transition_categories = kategorie_summary
    )
  ))
}

# Führe Datenaufbereitung aus
results <- prepare_data("data/raw/rwa_demo_trans_transpez.xlsx") 