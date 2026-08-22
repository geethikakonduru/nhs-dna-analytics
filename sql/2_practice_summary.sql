CREATE OR REPLACE TABLE `nhs-dna-analytics.analytics.practice_summary` AS

SELECT
    practice_code,
    practice_name,
    icb_name,
    source_month,
    
    SUM(appointment_count) AS total_appointments,
    
    SUM(CASE WHEN appointment_status = 'dna' 
        THEN appointment_count ELSE 0 END) AS total_dna,
    
    ROUND(SUM(CASE WHEN appointment_status = 'dna' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) AS dna_rate,
    
    ROUND(SUM(CASE WHEN appointment_mode = 'face_to_face' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) AS pct_face_to_face,
    
    ROUND(SUM(CASE WHEN appointment_mode = 'telephone' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) AS pct_telephone,
    
    ROUND(SUM(CASE WHEN appointment_mode = 'online_video' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) AS pct_online,
    
    ROUND(SUM(CASE WHEN appointment_mode = 'home_visit' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) AS pct_home_visit,
    
    ROUND(SUM(CASE WHEN hcp_type = 'gp' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) AS pct_gp_appointments,
    
    ROUND(AVG(lead_time_days), 1) AS avg_lead_time_days,
    
    CASE WHEN ROUND(SUM(CASE WHEN appointment_status = 'dna' 
        THEN appointment_count ELSE 0 END) / 
        SUM(appointment_count) * 100, 2) > 8
        THEN 1 ELSE 0 
    END AS is_high_dna_practice

FROM `nhs-dna-analytics.analytics.appointments_clean`
GROUP BY practice_code, practice_name, icb_name, source_month
HAVING SUM(appointment_count) > 100