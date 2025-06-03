# Manuelle Bearbeitungsschritte für das Manuskript

## Dateistruktur

```
manuscript/
├── manuscript_consolidated.md   # Hauptmanuskript
├── tables/                     # Alle Tabellen
│   ├── demographic/           # Demografische Tabellen
│   ├── results/              # Ergebnistabellen
│   └── supplementary/        # Zusätzliche Tabellen
├── figures/                   # Alle Abbildungen
└── references/               # Literaturverzeichnis
```

## Wichtige Dateien

- `manuscript_consolidated.md`: Hauptmanuskript, enthält den vollständigen Text
- `tables/results/transition_measures.md`: Tabelle zu Gender-Affirming Care
- `tables/results/factor_loadings.md`: Faktorladungen der Hauptanalyse

## Manuelle Bearbeitungsschritte

### Tabellen aktualisieren

1. Gender-Affirming Care Tabelle:
   ```bash
   python3 scripts/python/analyze_by_gender_identity.py
   ```
   - Erzeugt `data/processed/transition_measures_by_identity.csv`
   - Manuell in `tables/results/transition_measures.md` konvertieren

2. Faktorenanalyse:
   ```bash
   python3 scripts/python/calculate_factor_analysis.py
   ```
   - Ergebnisse in `tables/results/factor_loadings.md` überprüfen

### Manuskript bearbeiten

1. Neue Abschnitte:
   - In `manuscript_consolidated.md` einfügen
   - Referenzen im Text überprüfen
   - Tabellen- und Abbildungsverweise aktualisieren

2. Tabellen einbinden:
   - Tabellen in separaten Dateien unter `tables/` behalten
   - Im Manuskript mit relativen Pfaden referenzieren

3. Formatierung:
   - Markdown-Syntax verwenden
   - Zeilenumbrüche nach jedem Satz
   - Einheitliche Einrückung (4 Spaces)

## Sicherheit

- Immer Backup erstellen vor größeren Änderungen
- Keine automatischen Update-Skripte verwenden
- Änderungen dokumentieren
- Bei Unsicherheit neue Branch erstellen

## Checkliste vor Finalisierung

1. [ ] Alle Tabellen aktuell
2. [ ] Referenzen vollständig
3. [ ] Formatierung einheitlich
4. [ ] Backup erstellt
5. [ ] Figures im korrekten Format
6. [ ] Spelling check durchgeführt
7. [ ] Zitationen überprüft

## Kontakt

Bei Fragen oder Problemen:
- Technische Fragen: [IT Support]
- Inhaltliche Fragen: [Projektleitung] 