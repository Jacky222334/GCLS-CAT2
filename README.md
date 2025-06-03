# German Validation of the Gender Congruence and Life Satisfaction Scale (G-GCLS)

This repository contains the validation study of the German version of the Gender Congruence and Life Satisfaction Scale (G-GCLS).

## Project Structure

```
.
├── data/               # Data files
│   ├── raw/           # Original survey data
│   ├── processed/     # Cleaned and prepared data
│   └── results/       # Analysis outputs and tables
├── docs/              # Documentation and literature
├── manuscript/        # Manuscript files and drafts
├── figures/           # Visualizations (300 DPI, APA style)
└── R/                 # R code and scripts
```

## File Guidelines

### Data Files
- Keep raw data separate from processed data
- File naming: `YYYYMMDD_description.ext`
- All variable names in English
- Document all data processing steps

### Figures
- All text in English
- APA 7th Edition style
- 300 DPI minimum
- PNG format
- Times New Roman font

### R Scripts
- Comments in English
- Variable names in English
- Document analysis steps

## Setup

1. Install R packages:
```r
# Install required R packages
install.packages("papaja")
install.packages(c("knitr", "kableExtra", "tidyverse", "psych"))
```

2. Install LaTeX:
   - Install a LaTeX distribution (e.g., TeX Live or MiKTeX)
   - XeLaTeX is required for Unicode support

# GCLS Sankey Diagramm

Dieses Projekt visualisiert den Fluss von der Geschlechtszuweisung bei Geburt bis zum GCLS-Score (German Clinical Life Satisfaction) mit einem interaktiven Sankey-Diagramm.

## Übersicht

Das Sankey-Diagramm zeigt den Fluss durch folgende Ebenen:

1. **Geschlechtszuweisung bei Geburt**
   - AFAB (Assigned Female At Birth)
   - AMAB (Assigned Male At Birth)

2. **Zeitpunkt des Outings**
   - Frühes Outing
   - Mittleres Outing
   - Spätes Outing

3. **Zeit zwischen innerem und äußerem Outing**
   - Kurze Zeit
   - Mittlere Zeit
   - Lange Zeit

4. **Biomedizinische Maßnahmen**
   - Mit biomedizinischen Maßnahmen
   - Ohne biomedizinische Maßnahmen

5. **GCLS Score**
   - GCLS Niedrig
   - GCLS Mittel
   - GCLS Hoch

## Dateien

- `sankey_gcls.html` - Standalone HTML-Version mit interaktiven Buttons
- `sankey_gcls.py` - Python-Script zur Generierung des Diagramms
- `sankey_gcls_python.html` - Von Python generierte HTML-Datei
- `requirements.txt` - Python-Abhängigkeiten

## Verwendung

### HTML-Version

Öffnen Sie einfach `sankey_gcls.html` in einem modernen Webbrowser. Die Datei enthält:
- Zwei verschiedene Beispieldatensätze
- Interaktive Buttons zum Wechseln zwischen den Datensätzen
- Zoom- und Pan-Funktionalität

### Python-Version

1. Installieren Sie die benötigten Pakete:
```bash
pip install -r requirements.txt
```

2. Führen Sie das Script aus:
```bash
python sankey_gcls.py
```

Das Script erstellt automatisch eine HTML-Datei und öffnet sie im Browser.

## Anpassung der Daten

### In der HTML-Version

Bearbeiten Sie die Objekte `beispielDaten1` und `beispielDaten2` im Script-Bereich:

```javascript
const beispielDaten1 = {
    source: [...],  // Startknoten der Verbindungen
    target: [...],  // Zielknoten der Verbindungen
    value: [...]    // Werte (Anzahl der Personen)
};
```

### In der Python-Version

Passen Sie die Listen `source`, `target` und `values` an:

```python
source = [...]  // Startknoten (0-basierte Indizes)
target = [...]  // Zielknoten (0-basierte Indizes)
values = [...]  // Werte (Anzahl der Personen)
```

## Farbanpassung

Die Farben der Knoten können in beiden Versionen angepasst werden:

- HTML: Array `nodeColors`
- Python: Liste `node_colors`

## Zusätzliche Features

### Statisches Bild exportieren (Python)

Uncommentieren Sie die letzte Zeile im Python-Script und installieren Sie kaleido:
```bash
pip install kaleido
```

### Weitere Ebenen hinzufügen

1. Fügen Sie neue Knoten zum `nodes` Array hinzu
2. Erweitern Sie die `source`, `target` und `value` Arrays
3. Fügen Sie entsprechende Farben hinzu

## Hinweise

- Die Breite der Flüsse repräsentiert die Anzahl der Personen
- Die Beispieldaten sind fiktiv und dienen nur zur Demonstration
- Das Diagramm ist vollständig interaktiv - Sie können über Elemente hovern für Details