-- ============================================================
-- Patient Readmission Analysis — SQL Queries
-- Pure SQL: No machine learning. All insights via aggregation.
-- Compatible with SQLite, PostgreSQL, MySQL (minor syntax diffs)
-- ============================================================

-- ── 1. Dataset Overview KPIs ──────────────────────────────────────────────────
SELECT
    COUNT(*)                                AS total_encounters,
    COUNT(DISTINCT patient_nbr)             AS unique_patients,
    SUM(readmitted)                         AS total_readmissions,
    ROUND(AVG(readmitted) * 100, 1)         AS readmission_rate_pct,
    ROUND(AVG(time_in_hospital), 1)         AS avg_los_days,
    ROUND(AVG(num_medications), 1)          AS avg_medications,
    ROUND(AVG(number_diagnoses), 1)         AS avg_diagnoses
FROM encounters;


-- ── 2. Cohort Comparison: Readmitted vs Not Readmitted ───────────────────────
SELECT
    CASE WHEN readmitted = 1 THEN 'Readmitted' ELSE 'Not Readmitted' END AS cohort,
    COUNT(*)                                AS n,
    ROUND(AVG(time_in_hospital), 2)         AS avg_los,
    ROUND(AVG(num_medications), 2)          AS avg_meds,
    ROUND(AVG(number_inpatient), 2)         AS avg_prior_inpatient,
    ROUND(AVG(number_emergency), 2)         AS avg_prior_emergency,
    ROUND(AVG(number_diagnoses), 2)         AS avg_diagnoses,
    ROUND(AVG(num_lab_procedures), 2)       AS avg_lab_procedures
FROM encounters
GROUP BY readmitted;


-- ── 3. Readmission Rate by Age Group ─────────────────────────────────────────
SELECT
    age,
    COUNT(*)                                AS encounters,
    SUM(readmitted)                         AS readmissions,
    ROUND(AVG(readmitted) * 100, 1)         AS readmission_rate_pct,
    ROUND(AVG(time_in_hospital), 1)         AS avg_los,
    ROUND(AVG(num_medications), 1)          AS avg_medications
FROM encounters
GROUP BY age
ORDER BY age;


-- ── 4. Readmission by Prior Utilization Bucket ───────────────────────────────
SELECT
    CASE
        WHEN (number_inpatient + number_emergency) = 0     THEN 'None (0 visits)'
        WHEN (number_inpatient + number_emergency) = 1     THEN 'Low (1 visit)'
        WHEN (number_inpatient + number_emergency) BETWEEN 2 AND 3 THEN 'Medium (2–3 visits)'
        ELSE 'High (4+ visits)'
    END AS prior_utilization_bucket,
    COUNT(*)                                AS n,
    ROUND(AVG(readmitted) * 100, 1)         AS readmission_rate_pct,
    ROUND(AVG(time_in_hospital), 1)         AS avg_los,
    ROUND(AVG(num_medications), 1)          AS avg_meds
FROM encounters
GROUP BY prior_utilization_bucket
ORDER BY readmission_rate_pct DESC;


-- ── 5. A1C Result Impact on Readmission ──────────────────────────────────────
SELECT
    A1Cresult,
    COUNT(*)                                AS n,
    ROUND(AVG(readmitted) * 100, 1)         AS readmission_rate_pct,
    ROUND(AVG(time_in_hospital), 1)         AS avg_los,
    ROUND(AVG(num_medications), 1)          AS avg_meds
FROM encounters
GROUP BY A1Cresult
ORDER BY readmission_rate_pct DESC;


-- ── 6. Medication + Insulin Pattern Analysis ──────────────────────────────────
SELECT
    insulin,
    diabetesMed,
    COUNT(*)                                AS n,
    ROUND(AVG(readmitted) * 100, 1)         AS readmission_rate_pct,
    ROUND(AVG(num_medications), 1)          AS avg_meds,
    ROUND(AVG(time_in_hospital), 1)         AS avg_los
FROM encounters
GROUP BY insulin, diabetesMed
ORDER BY readmission_rate_pct DESC;


-- ── 7. Length of Stay Bucket Analysis ────────────────────────────────────────
SELECT
    CASE
        WHEN time_in_hospital BETWEEN 1 AND 3   THEN '1–3 days (Short)'
        WHEN time_in_hospital BETWEEN 4 AND 6   THEN '4–6 days (Medium)'
        WHEN time_in_hospital BETWEEN 7 AND 9   THEN '7–9 days (Long)'
        ELSE '10+ days (Extended)'
    END AS los_bucket,
    COUNT(*)                                AS n,
    ROUND(AVG(readmitted) * 100, 1)         AS readmission_rate_pct,
    ROUND(AVG(num_medications), 1)          AS avg_meds,
    ROUND(AVG(number_diagnoses), 1)         AS avg_diagnoses
FROM encounters
GROUP BY los_bucket
ORDER BY readmission_rate_pct DESC;


-- ── 8. Rule-Based Risk Score Assignment ──────────────────────────────────────
-- Transparent, auditable scoring. No ML required.
SELECT
    encounter_id,
    patient_nbr,
    age,
    gender,
    time_in_hospital,
    number_inpatient,
    number_emergency,
    num_medications,
    A1Cresult,
    readmitted,
    -- Score components
    MIN(number_inpatient * 2, 4)
      + MIN(number_emergency, 2)
      + CASE WHEN time_in_hospital >= 7  THEN 1 ELSE 0 END
      + CASE WHEN time_in_hospital >= 10 THEN 1 ELSE 0 END
      + CASE WHEN A1Cresult = '>8'       THEN 1 ELSE 0 END
      + CASE WHEN num_medications >= 20  THEN 1 ELSE 0 END  AS risk_score,
    -- Risk tier
    CASE
        WHEN (MIN(number_inpatient * 2, 4) + MIN(number_emergency, 2)
              + CASE WHEN time_in_hospital >= 7  THEN 1 ELSE 0 END
              + CASE WHEN time_in_hospital >= 10 THEN 1 ELSE 0 END
              + CASE WHEN A1Cresult = '>8'       THEN 1 ELSE 0 END
              + CASE WHEN num_medications >= 20  THEN 1 ELSE 0 END) >= 7 THEN 'Critical'
        WHEN (MIN(number_inpatient * 2, 4) + MIN(number_emergency, 2)
              + CASE WHEN time_in_hospital >= 7  THEN 1 ELSE 0 END
              + CASE WHEN time_in_hospital >= 10 THEN 1 ELSE 0 END
              + CASE WHEN A1Cresult = '>8'       THEN 1 ELSE 0 END
              + CASE WHEN num_medications >= 20  THEN 1 ELSE 0 END) >= 4 THEN 'High'
        WHEN (MIN(number_inpatient * 2, 4) + MIN(number_emergency, 2)
              + CASE WHEN time_in_hospital >= 7  THEN 1 ELSE 0 END
              + CASE WHEN time_in_hospital >= 10 THEN 1 ELSE 0 END
              + CASE WHEN A1Cresult = '>8'       THEN 1 ELSE 0 END
              + CASE WHEN num_medications >= 20  THEN 1 ELSE 0 END) >= 2 THEN 'Medium'
        ELSE 'Low'
    END AS risk_tier
FROM encounters
ORDER BY risk_score DESC;


-- ── 9. Risk Tier Validation — Does the Score Predict Actual Readmission? ──────
WITH scored AS (
    SELECT *,
        MIN(number_inpatient * 2, 4) + MIN(number_emergency, 2)
        + CASE WHEN time_in_hospital >= 7  THEN 1 ELSE 0 END
        + CASE WHEN time_in_hospital >= 10 THEN 1 ELSE 0 END
        + CASE WHEN A1Cresult = '>8'       THEN 1 ELSE 0 END
        + CASE WHEN num_medications >= 20  THEN 1 ELSE 0 END AS risk_score
    FROM encounters
),
tiered AS (
    SELECT *,
        CASE
            WHEN risk_score >= 7 THEN 'Critical'
            WHEN risk_score >= 4 THEN 'High'
            WHEN risk_score >= 2 THEN 'Medium'
            ELSE 'Low'
        END AS risk_tier
    FROM scored
)
SELECT
    risk_tier,
    COUNT(*)                                AS patients,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_total,
    ROUND(AVG(readmitted) * 100, 1)         AS actual_readmission_rate_pct,
    ROUND(AVG(risk_score), 2)               AS avg_risk_score
FROM tiered
GROUP BY risk_tier
ORDER BY actual_readmission_rate_pct DESC;


-- ── 10. High-Risk Patients — Outreach Candidate List ─────────────────────────
WITH scored AS (
    SELECT *,
        MIN(number_inpatient * 2, 4) + MIN(number_emergency, 2)
        + CASE WHEN time_in_hospital >= 7  THEN 1 ELSE 0 END
        + CASE WHEN time_in_hospital >= 10 THEN 1 ELSE 0 END
        + CASE WHEN A1Cresult = '>8'       THEN 1 ELSE 0 END
        + CASE WHEN num_medications >= 20  THEN 1 ELSE 0 END AS risk_score
    FROM encounters
    WHERE readmitted = 0  -- Focus on not-yet-readmitted for proactive outreach
)
SELECT
    encounter_id,
    patient_nbr,
    age,
    time_in_hospital,
    number_inpatient,
    number_emergency,
    num_medications,
    A1Cresult,
    risk_score
FROM scored
WHERE risk_score >= 7
ORDER BY risk_score DESC, number_inpatient DESC
LIMIT 25;
