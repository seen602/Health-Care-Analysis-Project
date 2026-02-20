# 🏥 Patient Readmission Analysis
### End-to-End Healthcare Data Analysis Portfolio Project — No ML Required

![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python) ![SQL](https://img.shields.io/badge/SQL-SQLite-orange?logo=sqlite) ![Pandas](https://img.shields.io/badge/Analysis-pandas%20%2F%20scipy-150458?logo=pandas) ![Tableau](https://img.shields.io/badge/BI-Tableau%20%2F%20Power%20BI-1F77B4?logo=tableau) ![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

---

## 📌 Overview

This project performs a **full end-to-end healthcare data analysis** to understand *who* gets readmitted to hospital within 30 days, *why*, and *which clinical factors* drive readmission risk — using only **SQL, statistical tests, and a transparent rule-based scoring system**. No machine learning is used.

> **Why no ML?** A rules-based approach is often preferred in clinical settings: it is fully auditable, explainable to clinicians, and can be validated and adjusted by domain experts without data science expertise.

---

## 🗂️ Project Structure

```
healthcare-readmission/
│
├── 📓 patient_readmission_analysis.ipynb   # Main analysis notebook
├── 🗄️ sql/
│   └── analysis_queries.sql                # 10 production-ready SQL queries
├── 📄 readmission_analysis_report.docx     # Written report
├── 📁 outputs/
│   ├── eda_charts.png
│   ├── segment_analysis.png
│   ├── risk_scoring.png
│   └── scored_patients.csv                 # Dashboard data source
└── README.md
```

---

## 🔬 Dataset

| Property | Detail |
|----------|--------|
| **Source** | [UCI ML Repository — Diabetes 130-US Hospitals (1999–2008)](https://archive.ics.uci.edu/dataset/296/diabetes+130-us+hospitals+for+years+1999-2008) |
| **Size** | ~101,766 encounters |
| **Features** | 50 clinical & administrative variables |
| **Target** | `readmitted` within 30 days (binary) |

---

## 🔄 Analysis Pipeline

```
Raw Data (CSV / UCI)
   ↓
SQL Queries (SQLite)   ─── 10 analytical queries: cohort profiling,
                            utilization buckets, A1C impact, risk scoring
   ↓
Exploratory Data Analysis  ─── Distributions, heatmaps, age segmentation
(Python / pandas / seaborn)
   ↓
Statistical Testing    ─── t-tests (numeric), chi-square (categorical)
(scipy.stats)               to confirm which factors are significant
   ↓
Segment & Trend Analysis ── Diverging bars, stacked cohorts, bubble charts
   ↓
Rule-Based Risk Scoring  ── Transparent 0–10 score; validated against
                            actual readmission rates
   ↓
Dashboard (Tableau / Power BI) ─── scored_patients.csv as data source
```

---

## 📊 Key Findings

| Factor | Not Readmitted | Readmitted | Signal Strength |
|--------|---------------|------------|-----------------|
| Prior inpatient visits | 0.3 avg | 0.8 avg | ⬆️ **2.6x lift** |
| Prior emergency visits | 0.2 avg | 0.5 avg | ⬆️ **2.5x lift** |
| Length of stay | 4.1 days | 5.3 days | ⬆️ **Significant** |
| A1C > 8 | ~10% rate | ~17% rate | ⬆️ **Significant** |
| Medications ≥ 20 | ~9% rate | ~14% rate | ⬆️ Moderate |

### Risk Tier Performance (validated against actual readmissions)

| Tier | Score Range | % of Patients | Actual Readmission Rate |
|------|-------------|---------------|------------------------|
| Low | 0–1 | ~60% | ~7% |
| Medium | 2–3 | ~27% | ~11% |
| High | 4–6 | ~11% | ~18% |
| Critical | 7–10 | ~2% | ~29% |

---

## 🚦 Risk Scoring Rules (Fully Transparent)

| Rule | Points |
|------|--------|
| Prior inpatient stays × 2 (max 4 pts) | 0–4 |
| Prior emergency visits (max 2 pts) | 0–2 |
| Length of stay ≥ 7 days | +1 |
| Length of stay ≥ 10 days | +1 |
| A1C result > 8 | +1 |
| Medications ≥ 20 | +1 |

Every rule is **grounded in statistical analysis** from the EDA phase and validated against actual readmission outcomes.

---

## 🛠️ Tech Stack

| Layer | Tools |
|-------|-------|
| Data Storage | SQLite (in-memory), CSV |
| SQL Analysis | 10 analytical queries (SQLite3) |
| EDA | pandas, numpy, matplotlib, seaborn |
| Statistical Testing | scipy.stats (t-test, chi-square, Cramér's V) |
| Risk Scoring | Rule-based (pandas apply) |
| Dashboard | Tableau Public / Power BI Desktop |
| Report | Microsoft Word (.docx) |

---

## ⚙️ Setup

```bash
git clone https://github.com/yourusername/healthcare-readmission.git
cd healthcare-readmission

pip install pandas numpy matplotlib seaborn scipy jupyter ucimlrepo

jupyter notebook patient_readmission_analysis.ipynb
```

### Load the real dataset

```python
from ucimlrepo import fetch_ucirepo
ds = fetch_ucirepo(id=296)
df = ds.data.features.copy()
df['readmitted'] = (ds.data.targets['readmitted'] == '<30').astype(int)
```

---

## 📈 Dashboard (Tableau / Power BI)

Connect `scored_patients.csv` to your BI tool. Recommended views:

- **KPI Strip:** Total patients · Overall readmission rate · % in Critical tier
- **Risk Tier Bar Chart** with drillthrough to patient list
- **Readmission Rate by Age Group** (filterable by gender, race, A1C)
- **Utilization Heatmap:** Prior inpatient × Emergency → Readmission %
- **High-Risk Patient Table:** Sorted by risk score for care manager outreach

---

## 💡 Clinical Recommendations

1. **Target discharge planning resources** on patients with 2+ prior inpatient stays
2. **Standardize A1C testing** at admission — untested patients are a hidden risk group
3. **Assign care coordinators** to all Critical-tier patients before discharge
4. **Post-discharge follow-up calls** within 48–72 hours for High and Critical tiers
5. **Review polypharmacy protocols** for patients on 20+ medications
6. **Embed the rule-based score in EHR** as a discharge workflow decision-support alert

---

## 👤 Author

**Your Name** | Data Analyst  
📧 email@example.com | 🔗 [LinkedIn](https://linkedin.com) | 🌐 [Portfolio](https://yourportfolio.com)

---

*⭐ Star this repo if it helped you!*
