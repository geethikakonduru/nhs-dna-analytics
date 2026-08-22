SELECT
    lead_time_category,
    lead_time_days,
    SUM(appointment_count) AS total_appointments,
    ROUND(SUM(CASE WHEN appointment_status = 'dna' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) AS dna_rate
FROM `nhs-dna-analytics.analytics.appointments_clean`
WHERE lead_time_days IS NOT NULL
GROUP BY lead_time_category, lead_time_days
ORDER BY lead_time_days