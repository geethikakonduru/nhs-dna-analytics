SELECT
    icb_name,
    SUM(appointment_count) AS total_appointments,
    ROUND(SUM(CASE WHEN appointment_status = 'dna' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) AS dna_rate,
    RANK() OVER (ORDER BY SUM(CASE WHEN appointment_status = 'dna' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) DESC) AS dna_rank
FROM `nhs-dna-analytics.analytics.appointments_clean`
GROUP BY icb_name
ORDER BY dna_rate DESC