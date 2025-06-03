# tidySEM Pfaddiagramm für das ESEM-Modell

# Pakete installieren (nur falls noch nicht vorhanden)
if (!require("tidySEM")) install.packages("tidySEM")
if (!require("DiagrammeR")) install.packages("DiagrammeR")
if (!require("DiagrammeRsvg")) install.packages("DiagrammeRsvg")
if (!require("rsvg")) install.packages("rsvg")
if (!require("readxl")) install.packages("readxl")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("lavaan")) install.packages("lavaan")

library(lavaan)
library(tidySEM)
library(tidyverse)
library(readxl)
library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

# --------------------------------------------------------------------
# Daten einlesen
# --------------------------------------------------------------------
daten <- read_excel("data/raw/dat_ESEM_compl_wI26_GI.xlsx")

# Items vorbereiten
item_data <- daten %>%
  select(starts_with("I")) %>%
  rename_with(~paste0("item", gsub("I", "", .)))

# --------------------------------------------------------------------
# ESEM-Modell definieren und schätzen (identisch zu vorheriger Analyse)
# --------------------------------------------------------------------
esem_model <- '
Soc =~ NA*item8 + item9 + item10 + item11 + item12 + item13
Gen =~ NA*item14 + item21 + item25 + item27 + item29
Psych =~ NA*item1 + item2 + item3 + item4 + item5 + item6 + item7
Chest =~ NA*item15 + item18 + item28 + item30
Life =~ NA*item19 + item20 + item22
Intim =~ NA*item31 + item32 + item33 + item34
Sec =~ NA*item16 + item17 + item23 + item24 + item35 + item36 + item37 + item38

Soc ~~ Gen + Psych + Chest + Life + Intim + Sec
Gen ~~ Psych + Chest + Life + Intim + Sec
Psych ~~ Chest + Life + Intim + Sec
Chest ~~ Life + Intim + Sec
Life ~~ Intim + Sec
Intim ~~ Sec

Soc ~~ 1*Soc
Gen ~~ 1*Gen
Psych ~~ 1*Psych
Chest ~~ 1*Chest
Life ~~ 1*Life
Intim ~~ 1*Intim
Sec ~~ 1*Sec
'

esem_fit <- cfa(esem_model,
                data = item_data,
                estimator = "ML",
                rotation  = "geomin",
                rotation.args = list(orthogonal = FALSE))

# --------------------------------------------------------------------
# Pfaddiagramm mit tidySEM + DiagrammeR
# --------------------------------------------------------------------

# Graph erstellen (tree-Layout, standardisierte Schätzwerte)
g <- graph_sem(esem_fit,
               layout = "tree",
               columns = 1,
               label = "est_std",   # zeigt est (unstd) & std
               angle = 90)          # vertikale Darstellung

# Schwarze Kanten, weiße Knoten
# Kanten
g <- set_edge_attrs(g, edge_attr = "color", values = "black")
# Knotenfüllung & Rahmen
g <- set_node_attrs(g, node_attr = "fillcolor", values = "white")
g <- set_node_attrs(g, node_attr = "color",     values = "black")

# Schriftgrößen anpassen (kleiner für Items)
all_nodes <- get_node_df(g)
item_nodes <- grep("item", all_nodes$label)
latent_nodes <- setdiff(seq_len(nrow(all_nodes)), item_nodes)

# Latente Variablen etwas größer
g <- set_node_attrs_ws(g, nodes = latent_nodes, node_attr = "fontsize", values = 12)
# Items kleiner
g <- set_node_attrs_ws(g, nodes = item_nodes,   node_attr = "fontsize", values = 9)
# Kantenschriftgröße
g <- set_edge_attrs(g, edge_attr = "fontsize", values = 8)

# --------------------------------------------------------------------
# Export als PDF
# --------------------------------------------------------------------
svg_txt <- export_svg(g)
char_vec <- charToRaw(svg_txt)
# Zielpfad
out_file <- "analysis/factor_analysis/esem_path_tidySEM.pdf"
# Verzeichnis sicherstellen
if (!dir.exists("analysis/factor_analysis")) dir.create("analysis/factor_analysis", recursive = TRUE)
# SVG in PDF konvertieren
rsvg_pdf(char_vec, file = out_file)

cat("Pfaddiagramm wurde als", out_file, "gespeichert.\n") 