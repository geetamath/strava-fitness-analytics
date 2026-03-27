# Strava Fitness Data Analytics Case Study

A comprehensive fitness data analysis project using SQL, Power BI, and Python to uncover insights from Fitbit user activity data.

## 📊 Project Overview

This project analyzes the **Mobius Fitbit Kaggle Dataset** containing fitness tracking data from 33 users during Spring 2016. The analysis mimics Strava-style fitness insights using three different analytical approaches: SQL queries, Power BI dashboards, and Python data science.

**Dataset:** 18 CSV files with 3M+ records covering daily activities, heart rate, sleep patterns, and calories burned.

## 🎯 Key Findings

- **Daily Activity:** 7.6k average steps/day, 2.3k calories burned
- **Sleep Patterns:** 7 hours average, -0.19 correlation with activity (more active = less sleep)
- **Heart Rate:** 76 bpm average baseline
- **Activity Peaks:** April showed 4.7M steps surge, evening peaks at 18:00
- **Correlations:** Steps-Calories 0.6 (strong positive relationship)

## 🛠️ Technologies Used

- **SQL (SQLite):** Database creation, data querying, trend analysis
- **Power BI Desktop:** Interactive dashboards and visualizations
- **Python:** Pandas, Matplotlib, Seaborn for statistical analysis
- **Jupyter Notebook:** Data exploration and visualization
- **Google Colab:** Cloud-based analysis environment

## 📁 Project Structure

```
Strava_Fitness_CaseStudy/
│
├── data/                          # Dataset files
│   ├── dailyActivity.csv
│   ├── dailySteps.csv
│   ├── heartrate_seconds.csv
│   ├── sleepDay.csv
│   └── ... (14 more CSV files)
│
├── sql/                           # SQL queries and scripts
│   ├── strava_analysis.sql       # Core analysis queries
│   ├── clean.sql                 # Data cleaning scripts
│   └── untapped_analysis.sql     # Additional insights
│
├── notebooks/                     # Jupyter notebooks
│   ├── strava_full_analysis.ipynb
│   └── visualizations/           # Generated plots
│
├── powerbi/                       # Power BI dashboards
│   ├── strava_dashboard.pbix
│   └── screenshots/              # Dashboard exports
│
├── reports/                       # Analysis reports
│   ├── sql_report.pdf
│   ├── powerbi_report.pdf
│   └── pandas_report.pdf
│
└── README.md
```

## 🔍 Analysis Components

### 1. SQL Analysis
- Created SQLite database from 18 CSV files
- Performed queries for daily/weekly/monthly trends
- Analyzed calories by activity level
- Heart rate trend analysis
- Sleep vs activity correlation

**Sample Query:**
```sql
-- Total steps per day
SELECT ActivityDate, SUM(TotalSteps) as total_steps 
FROM dailyActivity 
GROUP BY ActivityDate 
ORDER BY ActivityDate;
```

### 2. Power BI Dashboards
- Daily/Weekly activity overview (line charts)
- Calories vs Steps correlation (scatter plots)
- Sleep pattern analysis (bar charts)
- Heart rate trends (time series)
- Hourly activity peaks (heatmaps)

### 3. Python/Pandas Analysis
- Data cleaning and preprocessing
- Statistical analysis with `describe()`, correlation matrices
- Time series analysis
- Boxplots for outlier detection
- Heatmaps for pattern visualization

**Key Code:**
```python
import pandas as pd

# Load and analyze
df = pd.read_csv('data/dailyActivity.csv')
print(df.describe())

# Correlation analysis
correlation = df[['TotalSteps', 'Calories', 'VeryActiveMinutes']].corr()
```

## 📈 Visualizations

The project includes multiple visualization types:
- **Line Charts:** Time series trends for steps, calories, heart rate
- **Scatter Plots:** Steps vs Calories correlation
- **Heatmaps:** Activity intensity patterns, correlation matrices
- **Bar Charts:** Weekly/monthly aggregations, hourly peaks
- **Boxplots:** Distribution analysis and outlier detection

## 🚀 Getting Started

### Prerequisites
- Python 3.8+
- SQLite3
- Power BI Desktop (for .pbix files)
- Jupyter Notebook or Google Colab

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/strava-fitness-analytics.git
cd strava-fitness-analytics
```

2. Install Python dependencies
```bash
pip install pandas numpy matplotlib seaborn jupyter sqlite3
```

3. Run the analysis
```bash
jupyter notebook notebooks/strava_full_analysis.ipynb
```

## 📊 Dataset Information

**Source:** Mobius Fitbit Kaggle Dataset (Public)

**Files:** 18 CSV files including:
- dailyActivity (940 rows, 15 columns)
- heartrate_seconds (1M+ records)
- sleepDay (413 records)
- hourlyCalories, hourlySteps, hourlyIntensities
- minuteCalories, minuteSteps, minuteIntensities
- weightLogInfo (67 records)

**Time Period:** Spring 2016 (April-May)

**Users:** 33 unique participants

## 🎓 Key Insights & Recommendations

1. **Recovery is Key:** Sleep drops by -0.19 correlation on highly active days → Plan recovery days
2. **Evening Activity:** Peak calorie burn at 18:00 → Leverage evening walks
3. **Consistency Matters:** Users averaging 7.6k steps show better calorie burn (0.6 correlation)
4. **Intensity Boost:** 30+ minutes of very active exercise → 3k+ calorie days

## 📝 License

This project uses publicly available Kaggle dataset. Analysis and code are available for educational purposes.

## 👤 Author

**Geeta Siddramayya Math**
- Email: gsmvjp@gmail.com
- LinkedIn: [linkedin.com/in/geeta-math-128874353](https://linkedin.com/in/geeta-math-128874353)
- GitHub: [github.com/geetamath](https://github.com/geetamath)

## 🙏 Acknowledgments

- Mobius for the Fitbit dataset on Kaggle
- Strava for fitness tracking inspiration
- The data science community for analysis techniques

---

⭐ If you found this project helpful, please give it a star!
