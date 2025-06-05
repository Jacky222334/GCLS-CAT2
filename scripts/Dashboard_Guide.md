# GCLS-G CAT Dashboard User Guide

## 🚀 Quick Start

### Starting the Dashboard
```bash
# From the main project directory
Rscript scripts/run_dashboard.R

# Or from R console
source("scripts/run_dashboard.R")
```

The dashboard will automatically:
- Install missing R packages
- Launch in your default web browser
- Display at `http://127.0.0.1:XXXX` (port varies)

---

## 📊 Dashboard Overview

The GCLS-G CAT Dashboard provides an interactive interface for testing and analyzing Computerized Adaptive Testing algorithms. It consists of four main sections:

### 1. **CAT Testing** 📝
Interactive assessment simulation with real-time algorithm visualization

### 2. **Performance Analysis** 📈  
Comparative analysis between CAT and full-test approaches

### 3. **Item Pool** 🗄️
Exploration of GCLS-G item parameters and characteristics

### 4. **Settings** ⚙️
Configuration of CAT algorithm parameters

---

## 🎯 CAT Testing Tab

### Assessment Process

1. **Start Assessment**
   - Click "Start Assessment" to begin adaptive testing
   - Items are selected based on maximum information criterion
   - Response options: Always, Often, Sometimes, Rarely, Never

2. **Real-time Monitoring**
   - **Items Administered**: Current count of administered items
   - **Current Theta**: Latest ability estimate (standardized scale)
   - **Standard Error**: Measurement precision (lower = better)
   - **Progress Bar**: Visual progress toward completion

3. **Interactive Elements**
   - **Theta Convergence Plot**: Shows how ability estimates stabilize
   - **Item Information Curve**: Displays information function for current item
   - **Response History**: Complete log of administered items and responses

### Stopping Criteria

The assessment automatically stops when:
- **Precision reached**: SE < 0.30 (default threshold)
- **Maximum items**: 20 items administered (safety limit)
- **Manual termination**: User chooses to stop

### Interpreting Results

| Theta Range | Interpretation |
|-------------|----------------|
| < -1.0 | High gender congruence |
| -1.0 to 0.0 | Good gender congruence |
| 0.0 to 1.0 | Moderate concerns |
| > 1.0 | Significant difficulties |

---

## 📈 Performance Analysis Tab

### Running Simulations

1. Click **"Run Performance Simulation"**
2. Dashboard runs 50 virtual participants (adjustable in Settings)
3. Compares CAT vs. full 38-item test performance

### Key Metrics

#### **Efficiency Table**
- **Mean Items Used**: Average items required for CAT
- **Item Reduction**: Percentage reduction vs. full test
- **Correlation**: Agreement between CAT and full test scores
- **Mean SE**: Average measurement precision

#### **Expected Performance**
| Metric | Target Value |
|--------|-------------|
| Items Used | 10-15 items |
| Item Reduction | 60-70% |
| Correlation | r > 0.95 |
| Mean SE | < 0.35 |

### Visualization Plots

#### **CAT vs Full Test Correlation**
- **Perfect correlation**: Points fall on diagonal line
- **Systematic bias**: Points consistently above/below diagonal
- **Random error**: Scatter around diagonal

#### **Precision Distribution**
- **Red line**: SE threshold (0.30)
- **Distribution**: Most assessments should achieve target precision
- **Outliers**: High SE values indicate measurement challenges

---

## 🗄️ Item Pool Tab

### Item Parameters Table

Displays complete GCLS-G item bank with:
- **Item Number**: Sequential identifier (1-38)
- **Discrimination**: Item's ability to differentiate between participants
- **Difficulty**: Item difficulty level (standardized)
- **Factor**: GCLS subscale assignment (1-7)
- **Subscale**: Descriptive subscale name

### Item Characteristics

#### **Discrimination Values**
- **High (> 2.0)**: Excellent discriminating items
- **Good (1.5-2.0)**: Adequate discrimination
- **Moderate (1.0-1.5)**: Acceptable discrimination
- **Low (< 1.0)**: Poor discrimination

#### **Difficulty Range**
- **Easy (< -1.0)**: Most participants endorse
- **Moderate (-1.0 to 1.0)**: Balanced difficulty
- **Hard (> 1.0)**: Few participants endorse

### Visualization Features

#### **Discrimination vs Difficulty Scatter**
- **Optimal items**: High discrimination, moderate difficulty
- **Color coding**: Items grouped by GCLS subscale
- **Interactive**: Click points for item details

#### **Item Information Functions**
- Shows how much information each item provides across ability range
- **Peak**: Maximum information point
- **Width**: Range of effective measurement

---

## ⚙️ Settings Tab

### CAT Algorithm Settings

#### **Maximum Items** (5-38)
- **Default**: 20 items
- **Lower values**: Faster testing, potentially less precision
- **Higher values**: Better precision, longer testing time

#### **SE Threshold** (0.1-0.5)
- **Default**: 0.30 (good precision)
- **Lower values**: Higher precision requirement, more items
- **Higher values**: Lower precision, fewer items

#### **Minimum Items** (3-15)
- **Default**: 5 items
- **Prevents**: Unreliable estimates from too few items
- **Balance**: Reliability vs. efficiency

#### **Exposure Control**
- **Purpose**: Prevents overuse of highly informative items
- **Effect**: More balanced item usage, slightly lower efficiency

### Simulation Parameters

#### **Number of Simulations** (10-500)
- **Recommended**: 100 simulations for stable results
- **Higher values**: More accurate estimates, longer runtime
- **Lower values**: Faster results, more variable

#### **Initial Theta** (-3 to 3)
- **Default**: 0.0 (average ability)
- **Custom starting points**: Can influence first few item selections
- **Clinical use**: Could use previous assessment scores

---

## 🔧 Technical Notes

### Browser Compatibility
- **Recommended**: Chrome, Firefox, Safari, Edge (latest versions)
- **Features**: Interactive plots require JavaScript enabled
- **Performance**: Modern browsers handle visualizations better

### Troubleshooting

#### **Dashboard Won't Start**
```r
# Check package installation
install.packages(c("shiny", "shinydashboard", "DT", "plotly"))

# Verify file locations
list.files("scripts/")  # Should show dashboard files
```

#### **Slow Performance**
- Reduce number of simulations in Settings
- Close other browser tabs
- Restart R session if memory issues occur

#### **Missing Plots**
- Ensure all required packages are installed
- Check browser console for JavaScript errors
- Try refreshing the page

### Data Privacy
- **No data storage**: All responses are temporary
- **Local processing**: Everything runs on your computer
- **No internet required**: Fully offline operation

---

## 🎓 Educational Use

### Learning Objectives

1. **Understanding CAT**: See adaptive algorithms in action
2. **Efficiency demonstration**: Compare CAT vs. traditional testing
3. **Psychometric concepts**: Visualize information functions, measurement precision
4. **Clinical application**: Experience realistic assessment workflow

### Exercise Ideas

#### **Basic Exploration**
1. Complete a full CAT assessment
2. Compare your theta trajectory with different response patterns
3. Observe how item selection changes based on responses

#### **Algorithm Comparison**
1. Run simulations with different SE thresholds
2. Compare efficiency vs. precision trade-offs
3. Analyze item exposure patterns

#### **Clinical Scenarios**
1. Simulate different patient profiles
2. Test algorithm performance with extreme responses
3. Evaluate stopping criteria effectiveness

---

## 📚 Additional Resources

### References
- **CAT Theory**: van der Linden (2016). *Handbook of Item Response Theory*
- **Implementation**: Choi (2009). *Firestar: Computerized Adaptive Testing Simulation*
- **Clinical Application**: Reeve et al. (2007). *Applying item response theory*

### Support
- **Technical issues**: Check R console for error messages
- **Methodology questions**: Refer to CAT literature
- **GCLS-specific queries**: Contact instrument developers

---

**Version**: 1.0  
**Last Updated**: February 2024  
**Compatibility**: R 4.0+, Modern web browsers 