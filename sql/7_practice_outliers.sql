WITH practice_rates AS (
    SELECT
        practice_code,
        practice_name,
        icb_name,
        SUM(appointment_count) AS total_appointments,
        ROUND(SUM(CASE WHEN appointment_status = 'dna' 
            THEN appointment_count ELSE 0 END) / 
            SUM(appointment_count) * 100, 2) AS dna_rate
    FROM `nhs-dna-analytics.analytics.appointments_clean`
    GROUP BY practice_code, practice_name, icb_name
    HAVING SUM(appointment_count) > 500
),
stats AS (
    SELECT
        AVG(dna_rate) AS mean_dna,
        STDDEV(dna_rate) AS std_dna
    FROM practice_rates
)
SELECT
    p.practice_code,
    p.practice_name,
    p.icb_name,
    p.total_appointments,
    p.dna_rate,
    ROUND((p.dna_rate - s.mean_dna) / s.std_dna, 2) AS z_score,
    CASE 
        WHEN (p.dna_rate - s.mean_dna) / s.std_dna > 2 THEN 'High Outlier'
        WHEN (p.dna_rate - s.mean_dna) / s.std_dna < -2 THEN 'Low Outlier'
        ELSE 'Normal'
    END AS outlier_status
FROM practice_rates p, stats s
ORDER BY z_score DESC