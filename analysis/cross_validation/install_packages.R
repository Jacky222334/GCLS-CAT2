# Installation der benötigten Packages für die K-Fold Cross-Validation

# Liste der benötigten Packages
required_packages <- c(
  "tidyverse",  # für Datenverarbeitung und ggplot2
  "lavaan",     # für ESEM/SEM Analysen
  "caret",      # für K-Fold Cross-Validation
  "gridExtra",  # für Plot-Layouts
  "readxl",     # für Excel-Dateien
  "psych"       # für psychometrische Analysen
)

# Funktion zur Überprüfung und Installation
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE)) {
    cat(sprintf("Installing package: %s\n", package))
    install.packages(package, dependencies = TRUE)
  } else {
    cat(sprintf("Package already installed: %s\n", package))
  }
}

# Packages installieren
for (pkg in required_packages) {
  install_if_missing(pkg)
}

# Überprüfen der erfolgreichen Installation
successfully_loaded <- sapply(required_packages, require, character.only = TRUE)
if (all(successfully_loaded)) {
  cat("\nAlle Packages wurden erfolgreich installiert und geladen!\n")
} else {
  failed_packages <- required_packages[!successfully_loaded]
  cat("\nFehler beim Laden folgender Packages:\n")
  cat(paste(failed_packages, collapse = "\n"))
} 