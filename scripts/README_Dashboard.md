# GCLS-G CAT Dashboard Setup Guide

## 🚀 Quick Start (3 Steps)

### Step 1: Install Required Packages
```r
# Run this first to install all required packages
source("scripts/install_packages.R")
```

### Step 2: Launch Dashboard
```r
# Simple launcher (assumes packages are installed)
source("scripts/launch_dashboard_simple.R")
```

### Step 3: Open Browser
- Dashboard will automatically open in your default browser
- If not, navigate to the URL shown in the R console (usually `http://127.0.0.1:XXXX`)

---

## 📦 Package Requirements

### Required Packages (Essential)
- **shiny** - Web application framework
- **shinydashboard** - Dashboard UI components  
- **DT** - Interactive data tables
- **plotly** - Interactive visualizations
- **tidyverse** - Data manipulation tools
- **psych** - Psychometric functions

### Optional Packages (Advanced Features)
- **mirt** - Multidimensional Item Response Theory
- **catR** - Full CAT algorithm implementation

---

## 🛠️ Installation Methods

### Method 1: Automated Installation (Recommended)
```r
source("scripts/install_packages.R")
```
This script will:
- Set up CRAN mirror automatically
- Install packages with error handling
- Test package loading
- Provide detailed feedback

### Method 2: Manual Installation
```r
# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Install core packages
install.packages(c("shiny", "shinydashboard", "DT", "plotly"))
install.packages("tidyverse")
install.packages("psych")

# Optional: Install advanced packages
install.packages(c("mirt", "catR"))
```

### Method 3: Step-by-Step Installation
```r
# Install one by one if batch installation fails
install.packages("shiny")
install.packages("shinydashboard") 
install.packages("DT")
install.packages("plotly")
install.packages("tidyverse")
install.packages("psych")
```

---

## 🚀 Launch Options

### Option 1: Simple Launcher (Fastest)
```r
source("scripts/launch_dashboard_simple.R")
```
- Assumes packages are already installed
- No automatic installation
- Fastest startup time

### Option 2: Full Launcher (Comprehensive)
```r
source("scripts/run_dashboard.R")
```
- Checks and installs missing packages
- More robust error handling
- Slower startup but more reliable

### Option 3: Direct Launch
```r
# Navigate to scripts directory first
setwd("scripts")
source("cat_dashboard.R")
```
- Direct access to dashboard
- Requires manual setup

---

## 🔧 Troubleshooting

### Problem: "CRAN mirror not set"
**Solution:**
```r
options(repos = c(CRAN = "https://cloud.r-project.org/"))
```

### Problem: Package installation fails
**Solutions:**
1. **Update R**: Ensure R version ≥ 4.0.0
2. **Try different mirror**:
   ```r
   options(repos = c(CRAN = "https://cran.rstudio.com/"))
   ```
3. **Install dependencies manually**:
   ```r
   install.packages("rlang")  # Common dependency
   install.packages("ggplot2")
   ```

### Problem: "file not found" errors
**Solutions:**
1. **Check working directory**:
   ```r
   getwd()  # Should be project root
   list.files("scripts/")  # Should show dashboard files
   ```
2. **Set correct directory**:
   ```r
   setwd("path/to/GCLS_german_190520125")
   ```

### Problem: Dashboard won't start
**Solutions:**
1. **Check package loading**:
   ```r
   library(shiny)
   library(shinydashboard)
   library(DT)
   library(plotly)
   ```
2. **Check file existence**:
   ```r
   file.exists("scripts/cat_demonstration.R")
   file.exists("scripts/cat_dashboard.R")
   ```

### Problem: Browser doesn't open
**Solutions:**
1. **Manual browser navigation**: Copy URL from R console
2. **Check firewall settings**: Allow R/RStudio network access
3. **Try different port**:
   ```r
   shiny::runApp(port = 8080)
   ```

---

## 💻 System Requirements

### R Version
- **Minimum**: R 4.0.0
- **Recommended**: R 4.3.0 or newer

### Operating Systems
- **Windows**: 10/11
- **macOS**: 10.15 or newer
- **Linux**: Ubuntu 18.04+ or equivalent

### Browser Compatibility
- **Chrome**: Version 90+ (recommended)
- **Firefox**: Version 88+
- **Safari**: Version 14+
- **Edge**: Version 90+

### Hardware
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 2GB free space for packages
- **Network**: Internet connection for package installation

---

## 📁 File Structure

```
scripts/
├── cat_dashboard.R           # Main dashboard application
├── cat_demonstration.R       # CAT algorithm functions
├── run_dashboard.R          # Full launcher with auto-install
├── launch_dashboard_simple.R # Simple launcher
├── install_packages.R       # Package installation script
├── CAT_README.md           # CAT implementation documentation
├── Dashboard_Guide.md      # User guide
└── README_Dashboard.md     # This setup guide
```

---

## 🎓 Getting Started Tutorial

### 1. First Time Setup
```r
# Check R version
R.version.string

# Install packages
source("scripts/install_packages.R")

# Launch dashboard
source("scripts/launch_dashboard_simple.R")
```

### 2. Basic Usage
1. **Start Assessment**: Click "Start Assessment" in CAT Testing tab
2. **Answer Items**: Respond using 5-point scale buttons
3. **Monitor Progress**: Watch real-time theta convergence
4. **View Results**: Check final assessment summary

### 3. Performance Analysis
1. **Run Simulation**: Click "Run Performance Simulation"
2. **Analyze Metrics**: Review efficiency and correlation tables
3. **Explore Plots**: Interact with CAT vs. full test visualizations

### 4. Advanced Features
1. **Item Pool**: Explore GCLS-G item parameters
2. **Settings**: Modify CAT algorithm parameters
3. **Custom Scenarios**: Test different stopping criteria

---

## 🆘 Support

### Common Issues
- **Installation problems**: Run `source("scripts/install_packages.R")`
- **Loading errors**: Check package versions and dependencies
- **Dashboard crashes**: Restart R session and try again

### Debug Mode
```r
# Enable debug mode for detailed error messages
options(shiny.error = browser)
source("scripts/launch_dashboard_simple.R")
```

### Getting Help
1. **Check console output**: Error messages provide diagnostic information
2. **Verify file paths**: Ensure all required files are present
3. **Test basic functionality**: Try loading packages individually
4. **Restart R session**: Clear environment and try again

### Contact Information
- **Technical issues**: Check R console for detailed error messages
- **Dashboard feedback**: Review Dashboard_Guide.md for usage help
- **CAT methodology**: Refer to CAT_README.md for algorithm details

---

**Version**: 1.0  
**Last Updated**: February 2024  
**Compatibility**: R 4.0+, Modern web browsers 