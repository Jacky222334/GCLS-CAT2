# Load required libraries
library(tidyverse)
library(readxl)
library(officer)

# Create a data frame with all 38 items
gcls_items <- data.frame(
  Item_Number = 1:38,
  German_Item = c(
    "Ich hatte das Gefühl, dass meine Stimme beeinflusst hat, wie andere Menschen meine Geschlechtsidentität wahrnehmen – das hat mich belastet",
    "Ich hatte das Gefühl, dass meine Gesichtsbehaarung nicht meiner Geschlechtsidentität entspricht",
    "Ich hatte das Gefühl, dass meine Genitalien meiner Geschlechtsidentität entsprechen",
    "Ich hatte das Gefühl, dass eine Genitaloperation meine Unzufriedenheit in Bezug auf mein Geschlecht reduzieren kann",
    "Ich war nicht in der Lage, ein erfülltes Leben zu führen, da ich mit meinen Genitalien unzufrieden war",
    "Ich war extrem belastet, wenn ich meine Brust angesehen habe",
    "Ich war extrem belastet, wenn ich meine Genitalien angesehen habe",
    "Ich war zufrieden mit meiner Brust",
    "Ich war in der Schule/Universität/bei der Arbeit zufrieden",
    "Ich war zufrieden mit meiner emotionalen Beziehung(en)",
    "Ich war zufrieden mit meinem Sexualleben",
    "Ich war zufrieden mit meinen Freizeitaktivitäten und Hobbies",
    "Ich fühlte mich in meinem Körper wohl",
    "Ich war mit meinem Aussehen zufrieden",
    "Ich fühlte mich in meiner Haut wohl",
    "Ich war mit meinem Leben insgesamt zufrieden",
    "Ich hatte das Gefühl, dass andere Menschen mein Geschlecht richtig wahrnehmen",
    "Ich fühlte mich in sozialen Situationen wohl",
    "Ich war mit meiner körperlichen Erscheinung zufrieden",
    "Ich fühlte mich in meiner Geschlechtsidentität sicher",
    "Ich war mit meiner Stimme zufrieden",
    "Ich war mit meiner Körperbehaarung zufrieden",
    "Ich war mit meiner Körperform zufrieden",
    "Ich war mit meiner Körpergröße zufrieden",
    "Ich war mit meinem Gewicht zufrieden",
    "Ich war mit meiner Muskelmasse zufrieden",
    "Ich war mit meiner Körperhaltung zufrieden",
    "Ich war mit meiner Gangart zufrieden",
    "Ich war mit meiner Gestik zufrieden",
    "Ich war mit meiner Mimik zufrieden",
    "Ich war mit meiner Körperpflege zufrieden",
    "Ich war mit meiner Kleidung zufrieden",
    "Ich war mit meinem Styling zufrieden",
    "Ich war mit meinem Make-up zufrieden",
    "Ich war mit meiner Frisur zufrieden",
    "Ich war mit meinem Bart zufrieden",
    "Ich war mit meiner Brust zufrieden",
    "Ich war mit meinen Genitalien zufrieden"
  ),
  Subscale = c(
    rep("Psychologisches Funktionieren", 7),
    rep("Genitalien", 5),
    rep("Soziale Geschlechtsrollenerkennung", 5),
    rep("Physische und emotionale Intimität", 4),
    rep("Brust", 5),
    rep("Andere sekundäre Geschlechtsmerkmale", 6),
    rep("Lebenszufriedenheit", 6)
  )
)

# Create a Word document
doc <- read_docx()

# Add title and subtitle
doc <- doc %>%
  body_add_par("Gender Congruence and Life Satisfaction Scale (GCLS)", style = "heading 1") %>%
  body_add_par("Deutsche Version", style = "heading 2") %>%
  body_add_par("") %>%
  body_add_par("Alle 38 Items mit Subskalen", style = "heading 3") %>%
  body_add_par("")

# Add instructions
doc <- doc %>%
  body_add_par("Antwortformat: 5-stufige Likert-Skala", style = "Normal") %>%
  body_add_par("1 = immer", style = "Normal") %>%
  body_add_par("2 = häufig", style = "Normal") %>%
  body_add_par("3 = manchmal", style = "Normal") %>%
  body_add_par("4 = selten", style = "Normal") %>%
  body_add_par("5 = nie", style = "Normal") %>%
  body_add_par("") %>%
  body_add_par("Niedrigere Werte = bessere Outcomes", style = "Normal") %>%
  body_add_par("")

# Add items
for(i in 1:nrow(gcls_items)) {
  doc <- doc %>%
    body_add_par(sprintf("Item %d: %s", gcls_items$Item_Number[i], gcls_items$German_Item[i]), style = "Normal") %>%
    body_add_par(sprintf("Subskala: %s", gcls_items$Subscale[i]), style = "Normal") %>%
    body_add_par("", style = "Normal")
}

# Save the document
print(doc, target = "data/processed/GCLS_Items_Deutsch.docx") 