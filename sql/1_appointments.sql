CREATE OR REPLACE TABLE `nhs-dna-analytics.analytics.appointments_clean` AS

SELECT
    GP_CODE AS practice_code,
    GP_NAME AS practice_name,
    SUB_ICB_LOCATION_CODE AS icb_code,
    SUB_ICB_LOCATION_NAME AS icb_name,
    PCN_CODE AS pcn_code,
    PCN_NAME AS pcn_name,
    SUPPLIER AS supplier,
    
    CASE 
        WHEN APPT_MODE = 'Face-to-Face' THEN 'face_to_face'
        WHEN APPT_MODE = 'Telephone' THEN 'telephone'
        WHEN APPT_MODE = 'Video Conference/Online' THEN 'online_video'
        WHEN APPT_MODE = 'Home Visit' THEN 'home_visit'
        ELSE 'unknown'
    END AS appointment_mode,
    
    CASE
        WHEN APPT_STATUS = 'Attended' THEN 'attended'
        WHEN APPT_STATUS = 'DNA' THEN 'dna'
        ELSE 'unknown'
    END AS appointment_status,
    
    CASE
        WHEN HCP_TYPE = 'GP' THEN 'gp'
        WHEN HCP_TYPE = 'Other Practice staff' THEN 'other_staff'
        ELSE 'unknown'
    END AS hcp_type,
    
    CASE 
        WHEN TIME_BETWEEN_BOOK_AND_APPT = 'Same Day' THEN 0
        WHEN TIME_BETWEEN_BOOK_AND_APPT = '1 Day' THEN 1
        WHEN TIME_BETWEEN_BOOK_AND_APPT = '2 to 7 Days' THEN 4
        WHEN TIME_BETWEEN_BOOK_AND_APPT = '8  to 14 Days' THEN 11
        WHEN TIME_BETWEEN_BOOK_AND_APPT = '15  to 21 Days' THEN 18
        WHEN TIME_BETWEEN_BOOK_AND_APPT = '22  to 28 Days' THEN 25
        WHEN TIME_BETWEEN_BOOK_AND_APPT = 'More than 28 Days' THEN 35
        ELSE NULL
    END AS lead_time_days,
    
    TIME_BETWEEN_BOOK_AND_APPT AS lead_time_category,
    NATIONAL_CATEGORY AS national_category,
    PARSE_DATE('%d%b%Y', APPOINTMENT_MONTH_START_DATE) AS appointment_month,
    source_month,
    COUNT_OF_APPOINTMENTS AS appointment_count

FROM `nhs-dna-analytics.raw.appointments_all`
WHERE APPT_STATUS IN ('Attended', 'DNA')