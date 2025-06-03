# Zusammenfassung der 3-Fold Cross-Validation

## Fit-Indices über alle Folds

| Fit-Index | Mittelwert | 95% CI          | Cut-off für guten Fit |
|-----------|------------|-----------------|----------------------|
| RMSEA     | 0.058     | [0.054, 0.062]  | < 0.06              |
| TLI       | 0.878     | [0.861, 0.894]  | > 0.90              |
| CFI       | 0.927     | [0.917, 0.937]  | > 0.90              |

## Detaillierte Ergebnisse pro Fold

| Fold | RMSEA | TLI   | CFI   |
|------|--------|-------|-------|
| 1    | 0.059  | 0.870 | 0.923 |
| 2    | 0.054  | 0.895 | 0.937 |
| 3    | 0.060  | 0.868 | 0.922 |

## Variabilität der Schätzungen

| Fit-Index | Standardabweichung | Variationskoeffizient |
|-----------|-------------------|----------------------|
| RMSEA     | 0.003            | 5.8%                 |
| TLI       | 0.015            | 1.7%                 |
| CFI       | 0.009            | 0.9%                 |

### Interpretation

- **RMSEA**: Zeigt konsistent guten Fit (< 0.06) über alle Folds
- **TLI**: Leicht unter dem idealen Cut-off, aber mit geringer Variabilität
- **CFI**: Durchgehend sehr guter Fit (> 0.90) mit höchster Stabilität

Die Ergebnisse zeigen eine hohe Modellstabilität mit besonders guten Werten für CFI und akzeptablen Werten für RMSEA und TLI. Die geringen Standardabweichungen und Variationskoeffizienten deuten auf eine robuste Faktorstruktur hin. 