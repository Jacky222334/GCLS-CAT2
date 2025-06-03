import plotly.offline as pyo

# Definiere die Knoten (nodes)
nodes = [
    # Ebene 1: Geschlechtszuweisung bei Geburt
    "AFAB",  # 0
    "AMAB",  # 1
    
    # Ebene 2: Zeitpunkt des Outings
    "Frühes Outing",  # 2
    "Mittleres Outing",  # 3
    "Spätes Outing",  # 4
    
    # Ebene 3: Zeit zwischen innerem und äußerem Outing
    "Kurze Zeit",  # 5
    "Mittlere Zeit",  # 6
    "Lange Zeit",  # 7
    
    # Ebene 4: Biomedizinische Maßnahmen
    "Mit biomed. Maßnahmen",  # 8
    "Ohne biomed. Maßnahmen",  # 9
    
    # Ebene 5: GCLS Score
    "GCLS Niedrig",  # 10
    "GCLS Mittel",  # 11
    "GCLS Hoch"  # 12
]

# Farben für die Knoten
node_colors = [
    # Geschlechtszuweisung
    "#FF6B6B",  # AFAB - Rosa/Rot
    "#4ECDC4",  # AMAB - Türkis
    
    # Outing-Zeitpunkt
    "#95E1D3",  # Früh - Hellgrün
    "#F38181",  # Mittel - Lachs
    "#AA96DA",  # Spät - Lila
    
    # Zeit zwischen Outings
    "#FCE38A",  # Kurz - Gelb
    "#F38181",  # Mittel - Lachs
    "#95A3D3",  # Lang - Blau
    
    # Biomedizinische Maßnahmen
    "#6C5CE7",  # Mit - Violett
    "#A8E6CF",  # Ohne - Mintgrün
    
    # GCLS Score
    "#FF6B6B",  # Niedrig - Rot
    "#FFD93D",  # Mittel - Gelb
    "#6BCF7F",  # Hoch - Grün
]

# Definiere die Verbindungen (links)
source = [
    # AFAB zu Outing-Zeitpunkt
    0, 0, 0,
    # AMAB zu Outing-Zeitpunkt
    1, 1, 1,
    # Outing-Zeitpunkt zu Zeit zwischen Outings
    2, 2, 2,
    3, 3, 3,
    4, 4, 4,
    # Zeit zwischen Outings zu Biomedizinische Maßnahmen
    5, 5,
    6, 6,
    7, 7,
    # Biomedizinische Maßnahmen zu GCLS Score
    8, 8, 8,
    9, 9, 9
]

target = [
    # AFAB zu Outing-Zeitpunkt
    2, 3, 4,
    # AMAB zu Outing-Zeitpunkt
    2, 3, 4,
    # Outing-Zeitpunkt zu Zeit zwischen Outings
    5, 6, 7,
    5, 6, 7,
    5, 6, 7,
    # Zeit zwischen Outings zu Biomedizinische Maßnahmen
    8, 9,
    8, 9,
    8, 9,
    # Biomedizinische Maßnahmen zu GCLS Score
    10, 11, 12,
    10, 11, 12
]

# Werte für die Verbindungen (Anzahl der Personen)
values = [
    # AFAB zu Outing-Zeitpunkt
    30, 25, 20,
    # AMAB zu Outing-Zeitpunkt
    35, 30, 25,
    # Outing-Zeitpunkt zu Zeit zwischen Outings
    25, 20, 20,
    18, 22, 15,
    15, 18, 12,
    # Zeit zwischen Outings zu Biomedizinische Maßnahmen
    40, 25,
    35, 25,
    30, 15,
    # Biomedizinische Maßnahmen zu GCLS Score
    15, 50, 40,
    20, 30, 15
]

# Erstelle das Sankey-Diagramm
fig = go.Figure(data=[go.Sankey(
    node=dict(
        pad=15,
        thickness=20,
        line=dict(color="black", width=0.5),
        label=nodes,
        color=node_colors
    ),
    link=dict(
        source=source,
        target=target,
        value=values,
        color='rgba(0,0,0,0.2)'
    )
)])

# Layout anpassen
fig.update_layout(
    title_text="GCLS Sankey Diagramm: Von Geschlechtszuweisung bis Lebenszufriedenheit",
    title_font_size=20,
    font=dict(size=12),
    height=700,
    margin=dict(l=20, r=20, t=50, b=20)
)

# Speichere als HTML
fig.write_html("sankey_gcls_python.html", auto_open=True)

# Optional: Als statisches Bild speichern (benötigt kaleido)
# fig.write_image("sankey_gcls.png", width=1200, height=700)

print("Sankey-Diagramm wurde erstellt und als 'sankey_gcls_python.html' gespeichert!") 