SELECT
    appointment_mode,
    SUM(appointment_count) AS total_appointments,
    SUM(CASE WHEN appointment_status = 'dna' 
        THEN appointment_count ELSE 0 END) AS total_dna,
    ROUND(SUM(CASE WHEN appointment_status = 'dna' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) AS dna_rate
FROM `nhs-dna-analytics.analytics.appointments_clean`
WHERE appointment_mode != 'unknown'
GROUP BY appointment_mode
ORDER BY dna_rate DESC