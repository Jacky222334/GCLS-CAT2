# 🏥 GCLS-G Advanced Computerized Adaptive Testing (CAT) System

[![R](https://img.shields.io/badge/R-4.3%2B-blue.svg)](https://cran.r-project.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CAT](https://img.shields.io/badge/CAT-Advanced-orange.svg)](scripts/cat_final_demo.R)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/Jacky222334/GCLS-CAT2/HEAD?urlpath=rstudio)

## 📋 Overview

This repository contains the **advanced Computerized Adaptive Testing (CAT) implementation** for the German Gender Congruence and Life Satisfaction Scale (GCLS-G). 

**Note:** The validation manuscript is being prepared for journal submission and is not included in this public repository.

## 🚀 Key Features

### ⚡ **Efficiency Gains**
- **60-70% reduction** in items administered (38 → 13-15 items)
- **r > 0.92 correlation** with full-scale scores
- **Real-time adaptive selection** using Maximum Information criterion

### 🎯 **Technical Implementation**
- **2-Parameter Logistic IRT** model for 38 GCLS-G items
- **Maximum Likelihood estimation** with real-time theta updates
- **SE threshold stopping** rule (default 0.30)
- **Seven subscales**: Psychological Functioning, Genitalia, Social Gender Role, Physical & Emotional Intimacy, Chest, Other Secondary Sex, Life Satisfaction

### 📊 **Performance Benchmarks**
- **Testing**: 15 items used (60.5% reduction), final SE 0.394
- **Simulation (50 participants)**: 14.5 mean items, 61.8% reduction, theta correlation 0.928

## 🌐 Try Online (No Installation Required)

**Click here for immediate access:**
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/Jacky222334/GCLS-CAT2/HEAD?urlpath=rstudio)

Wait 2-3 minutes for setup, then run:
```r
source("scripts/cat_final_demo.R")
```

## 💻 Local Installation

```r
# Install required packages
install.packages(c("mirt", "dplyr", "ggplot2", "DT", "plotly"))

# Run CAT demo
source("scripts/cat_final_demo.R")

# Launch interactive dashboard (requires shiny)
install.packages(c("shiny", "shinydashboard"))
source("scripts/advanced_cat_dashboard.R")
```

## 📁 Repository Structure

```
├── scripts/
│   ├── cat_final_demo.R           # Main CAT demonstration (344 lines)
│   ├── advanced_cat_dashboard.R   # Interactive Shiny dashboard (498 lines)
│   └── cat_demonstration.R        # Core CAT algorithms
├── Dashboard_Guide.md             # Comprehensive dashboard documentation
├── CAT_README.md                  # Technical CAT documentation
└── RUN_ONLINE.md                  # Online execution instructions
```

## 🎯 Usage Examples

### Basic CAT Demo
```r
# Load and run complete CAT demonstration
source("scripts/cat_final_demo.R")
```

### Advanced Dashboard
```r
# Launch interactive web interface
source("scripts/advanced_cat_dashboard.R")
```

## 📖 Documentation

- **[Dashboard Guide](Dashboard_Guide.md)**: Complete usage instructions (269 lines)
- **[CAT Technical Details](CAT_README.md)**: Implementation specifications
- **[Online Access Guide](RUN_ONLINE.md)**: Cloud execution options

## 🏥 Clinical Applications

### Ideal for:
- **Routine assessment** in gender-affirming care
- **Treatment monitoring** and outcome evaluation
- **Research applications** requiring efficient measurement
- **Multi-site studies** with standardized protocols

### Benefits:
- **Reduced respondent burden** (5-10 min vs. 15-20 min)
- **Maintained precision** with fewer items
- **Real-time scoring** and interpretation
- **Standardized implementation** across settings

## 🔬 Research Applications

The CAT system supports:
- **Longitudinal studies** with repeated measurements
- **Intervention trials** requiring sensitive outcome detection
- **Cross-cultural research** with standardized protocols
- **Quality assurance** in clinical settings

## ⚙️ Technical Specifications

- **IRT Framework**: 2-Parameter Logistic Model
- **Item Selection**: Maximum Information Criterion
- **Theta Estimation**: Maximum Likelihood (real-time updates)
- **Stopping Rules**: SE threshold (0.30) + maximum items (20)
- **Computational**: Hardware-agnostic (tested on ARM Cortex-A78AE)

## 📊 Validation Results

- **Factor Structure**: 7-factor solution (RMSEA = 0.054, TLI = 0.907)
- **Internal Consistency**: α = 0.77-0.90 across subscales
- **Cross-Validation**: Stable across 3-fold validation (CV < 6%)
- **Known-Groups Validity**: Significant differences on theoretically relevant dimensions

## 🤝 Citation

When using this CAT system, please cite:

```
Schulze, J. B., Ammann, F., Jones, B. A., von Känel, R., & Euler, S. (in preparation). 
Gender Congruence and Life Satisfaction Scale (GCLS-Gv1.1): German Validation Study 
with Advanced Computerized Adaptive Testing Implementation.
```

## 📧 Contact

**Corresponding Author**: Jan Ben Schulze  
Department of Consultation-Liaison Psychiatry and Psychosomatic Medicine  
University Hospital Zurich, Switzerland  
Email: jan.schulze@usz.ch

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

## 🔄 Updates

- **Latest**: Advanced CAT implementation with 60-70% efficiency gains
- **Binder Integration**: One-click online access without installation
- **Cross-Platform**: Validated on ARM and x86 architectures

---

**Note**: This repository provides the computational implementation. The associated validation manuscript is being prepared for peer-reviewed publication.