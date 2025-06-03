# lavaanPlot: klassisches Pfaddiagramm des ESEM-Modells

# -------------------------------------------------------------
# Setup & Pakete
# -------------------------------------------------------------
options(repos = c(CRAN = "https://cloud.r-project.org"))
if (!require("lavaanPlot")) install.packages("lavaanPlot")
if (!require("readxl"))     install.packages("readxl")
if (!require("lavaan"))     install.packages("lavaan")
if (!require("DiagrammeRsvg")) install.packages("DiagrammeRsvg")
if (!require("rsvg")) install.packages("rsvg")

library(readxl)
library(lavaan)
library(lavaanPlot)
library(DiagrammeRsvg)
library(rsvg)

# -------------------------------------------------------------
# Daten laden
# -------------------------------------------------------------
dat <- read_excel("data/raw/dat_ESEM_compl_wI26_GI.xlsx")
item_data <- dat |>
  dplyr::select(dplyr::starts_with("I")) |>
  dplyr::rename_with(~paste0("item", gsub("I", "", .)))

# -------------------------------------------------------------
# Modell definieren (identisch zu semPaths-Version)
# -------------------------------------------------------------
model_txt <- '
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

fit <- cfa(model_txt, data = item_data,
           estimator = "ML",
           rotation = "geomin",
           rotation.args = list(orthogonal = FALSE))

# -------------------------------------------------------------
# Pfaddiagramm erstellen und speichern
# -------------------------------------------------------------
out_file <- "analysis/factor_analysis/esem_path_lavaanPlot.pdf"
if (!dir.exists("analysis/factor_analysis")) dir.create("analysis/factor_analysis", recursive = TRUE)

g <- lavaanPlot(model = fit,
            stand = TRUE,
            edge_options  = list(color = "black", fontsize = 8),
            node_options  = list(shape = "box", fontsize = 10, fillcolor = "white"),
            graph_options = list(layout = "circle"))

svg_txt <- DiagrammeRsvg::export_svg(g)
char_vec <- charToRaw(svg_txt)
rsvg::rsvg_pdf(char_vec, file = out_file)

cat("PDF erstellt:", out_file, "\n") 