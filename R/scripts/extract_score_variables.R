# Skript zur Extraktion der Score-Variablen
library(tidyverse)
library(readxl)

# Daten einlesen
data <- read_excel("data/raw/raw_quest_all.xlsx")

# Funktion zur Zusammenfassung der Variablenstatistiken
summarize_score <- function(data, var_name) {
  stats <- data %>%
    summarise(
      n = sum(!is.na(!!sym(var_name))),
      mean = mean(!!sym(var_name), na.rm = TRUE),
      sd = sd(!!sym(var_name), na.rm = TRUE),
      min = min(!!sym(var_name), na.rm = TRUE),
      max = max(!!sym(var_name), na.rm = TRUE),
      missing = sum(is.na(!!sym(var_name)))
    )
  return(bind_cols(Variable = var_name, stats))
}

# SF-12 Variablen
sf12_vars <- c(
  "pcs12", "mcs12",           # Hauptscores
  "pf02_1", "pf02_2",         # Physical Functioning
  "rp2_1", "rp3_1",           # Role Physical
  "bp2_1", "bp2_2",           # Bodily Pain
  "gh1_1", "gh1_2",           # General Health
  "vt2_1", "vt2_2",           # Vitality
  "sf2_1", "sf2_2",           # Social Functioning
  "re2_1", "re3_1",           # Role Emotional
  "mh3_1", "mh3_2"            # Mental Health
)

# WHOQOL-BREF Variablen
whoqol_vars <- c(
  "phys", "psych", "social", "envir", "global",  # Domänenscores
  paste0("bref", 1:26),                          # Einzelitems
  "bref3r", "bref4r", "bref26r"                  # Rekodierte Items
)

# ZUF-8 Variablen
zuf_vars <- c(
  "zuf_score",                # Gesamtscore
  paste0("zuf_", 1:8)         # Einzelitems
)

# Alle Scores extrahieren und zusammenfassen
sf12_summary <- map_dfr(sf12_vars, ~summarize_score(data, .x))
whoqol_summary <- map_dfr(whoqol_vars, ~summarize_score(data, .x))
zuf_summary <- map_dfr(zuf_vars, ~summarize_score(data, .x))

# Ergebnisse in Markdown-Tabellen formatieren
create_md_table <- function(summary_data, title) {
  md <- sprintf("# %s\n\n", title)
  md <- paste0(md, "| Variable | N | Mittelwert | SD | Min | Max | Fehlend |\n")
  md <- paste0(md, "|:---------|--:|:-----------|:---|:----|:----|:--------|\n")
  
  for(i in 1:nrow(summary_data)) {
    md <- paste0(md, sprintf("| %s | %d | %.2f | %.2f | %.2f | %.2f | %d |\n",
                            summary_data$Variable[i],
                            summary_data$n[i],
                            summary_data$mean[i],
                            summary_data$sd[i],
                            summary_data$min[i],
                            summary_data$max[i],
                            summary_data$missing[i]))
  }
  
  return(md)
}

# Markdown-Tabellen erstellen
sf12_md <- create_md_table(sf12_summary, "SF-12 Variablen")
whoqol_md <- create_md_table(whoqol_summary, "WHOQOL-BREF Variablen")
zuf_md <- create_md_table(zuf_summary, "ZUF-8 Variablen")

# Gesamtdokument erstellen
full_md <- paste(
  "# Übersicht der Score-Variablen\n\n",
  sf12_md, "\n\n",
  whoqol_md, "\n\n",
  zuf_md,
  sep = ""
)

# Ergebnisse speichern
writeLines(full_md, "output/score_variables.md")

# CSV-Dateien für weitere Analysen speichern
write_csv(sf12_summary, "output/sf12_summary.csv")
write_csv(whoqol_summary, "output/whoqol_summary.csv")
write_csv(zuf_summary, "output/zuf_summary.csv")

# Ausgabe der Variablennamen in der Konsole
cat("\nSF-12 Variablen:\n")
print(sf12_vars)
cat("\nWHOQOL-BREF Variablen:\n")
print(whoqol_vars)
cat("\nZUF-8 Variablen:\n")
print(zuf_vars)

print("Analyse abgeschlossen. Ergebnisse wurden in output/ gespeichert.") 