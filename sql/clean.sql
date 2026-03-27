-- ============================================
-- STRAVA FITNESS ANALYTICS - DATA CLEANING
-- Author: Geeta Siddramayya Math
-- Purpose: Clean and validate data before analysis
-- ============================================

-- ============================================
-- 1. DATA VALIDATION CHECKS
-- ============================================

-- Check for negative values in steps
SELECT 'Negative Steps Check' as check_name, COUNT(*) as count
FROM dailyActivity 
WHERE TotalSteps < 0;

-- Check for negative calories
SELECT 'Negative Calories Check' as check_name, COUNT(*) as count
FROM dailyActivity 
WHERE Calories < 0;

-- Check for negative distances
SELECT 'Negative Distance Check' as check_name, COUNT(*) as count
FROM dailyActivity 
WHERE TotalDistance < 0;

-- Check for impossible activity minutes (>1440 minutes in a day)
SELECT 'Invalid Activity Minutes' as check_name, COUNT(*) as count
FROM dailyActivity 
WHERE (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) > 1440;

-- ============================================
-- 2. NULL VALUE CHECKS
-- ============================================

-- Check for NULL values in critical columns
SELECT 
    'dailyActivity' as table_name,
    SUM(CASE WHEN Id IS NULL THEN 1 ELSE 0 END) as null_id,
    SUM(CASE WHEN ActivityDate IS NULL THEN 1 ELSE 0 END) as null_date,
    SUM(CASE WHEN TotalSteps IS NULL THEN 1 ELSE 0 END) as null_steps,
    SUM(CASE WHEN Calories IS NULL THEN 1 ELSE 0 END) as null_calories
FROM dailyActivity;

SELECT 
    'sleepDay' as table_name,
    SUM(CASE WHEN Id IS NULL THEN 1 ELSE 0 END) as null_id,
    SUM(CASE WHEN SleepDay IS NULL THEN 1 ELSE 0 END) as null_date,
    SUM(CASE WHEN TotalMinutesAsleep IS NULL THEN 1 ELSE 0 END) as null_sleep
FROM sleepDay;

-- ============================================
-- 3. DUPLICATE CHECK
-- ============================================

-- Check for duplicate records in dailyActivity
SELECT 
    Id, 
    ActivityDate, 
    COUNT(*) as duplicate_count
FROM dailyActivity
GROUP BY Id, ActivityDate
HAVING COUNT(*) > 1;

-- Check for duplicate sleep records
SELECT 
    Id, 
    DATE(SleepDay) as sleep_date, 
    COUNT(*) as duplicate_count
FROM sleepDay
GROUP BY Id, DATE(SleepDay)
HAVING COUNT(*) > 1;

-- ============================================
-- 4. DATA RANGE VALIDATION
-- ============================================

-- Validate heart rate ranges (normal: 40-200 bpm)
SELECT 
    'Heart Rate Out of Range' as check_name,
    COUNT(*) as count,
    MIN(Value) as min_value,
    MAX(Value) as max_value
FROM heartrate_seconds
WHERE Value < 40 OR Value > 200;

-- Validate sleep duration (0-24 hours)
SELECT 
    'Invalid Sleep Duration' as check_name,
    COUNT(*) as count
FROM sleepDay
WHERE TotalMinutesAsleep < 0 OR TotalMinutesAsleep > 1440;

-- Validate calories (reasonable range: 0-8000)
SELECT 
    'Extreme Calories' as check_name,
    COUNT(*) as count,
    MIN(Calories) as min_cal,
    MAX(Calories) as max_cal
FROM dailyActivity
WHERE Calories > 8000 OR Calories < 0;

-- ============================================
-- 5. DATE FORMAT STANDARDIZATION
-- ============================================

-- Check date formats in dailyActivity
SELECT 
    ActivityDate,
    typeof(ActivityDate) as date_type,
    COUNT(*) as count
FROM dailyActivity
GROUP BY typeof(ActivityDate);

-- Verify date ranges
SELECT 
    'dailyActivity' as table_name,
    MIN(ActivityDate) as earliest_date,
    MAX(ActivityDate) as latest_date,
    COUNT(DISTINCT ActivityDate) as unique_dates
FROM dailyActivity;

-- ============================================
-- 6. OUTLIER DETECTION
-- ============================================

-- Detect extreme step counts (potential outliers)
SELECT 
    Id,
    ActivityDate,
    TotalSteps,
    Calories
FROM dailyActivity
WHERE TotalSteps > 30000 OR TotalSteps = 0
ORDER BY TotalSteps DESC;

-- Detect extreme calorie burns
SELECT 
    Id,
    ActivityDate,
    Calories,
    TotalSteps,
    VeryActiveMinutes
FROM dailyActivity
WHERE Calories > 4000 OR Calories < 1000
ORDER BY Calories DESC;

-- ============================================
-- 7. MISSING DATA ANALYSIS
-- ============================================

-- Users with incomplete data
SELECT 
    Id,
    COUNT(*) as days_logged,
    MIN(ActivityDate) as first_log,
    MAX(ActivityDate) as last_log
FROM dailyActivity
GROUP BY Id
HAVING COUNT(*) < 20
ORDER BY days_logged;

-- Sleep tracking completeness
SELECT 
    a.Id,
    COUNT(DISTINCT a.ActivityDate) as total_active_days,
    COUNT(DISTINCT DATE(s.SleepDay)) as sleep_logged_days,
    ROUND(COUNT(DISTINCT DATE(s.SleepDay)) * 100.0 / COUNT(DISTINCT a.ActivityDate), 2) as sleep_tracking_percent
FROM dailyActivity a
LEFT JOIN sleepDay s ON a.Id = s.Id AND a.ActivityDate = DATE(s.SleepDay)
GROUP BY a.Id
ORDER BY sleep_tracking_percent;

-- ============================================
-- 8. DATA CONSISTENCY CHECKS
-- ============================================

-- Check if total distance matches sum of activity distances
SELECT 
    Id,
    ActivityDate,
    TotalDistance,
    (VeryActiveDistance + ModeratelyActiveDistance + LightActiveDistance + SedentaryActiveDistance) as calculated_distance,
    ABS(TotalDistance - (VeryActiveDistance + ModeratelyActiveDistance + LightActiveDistance + SedentaryActiveDistance)) as distance_diff
FROM dailyActivity
WHERE ABS(TotalDistance - (VeryActiveDistance + ModeratelyActiveDistance + LightActiveDistance + SedentaryActiveDistance)) > 0.1
LIMIT 20;

-- Check if time in bed is greater than or equal to sleep time
SELECT 
    Id,
    SleepDay,
    TotalMinutesAsleep,
    TotalTimeInBed,
    (TotalTimeInBed - TotalMinutesAsleep) as awake_in_bed
FROM sleepDay
WHERE TotalMinutesAsleep > TotalTimeInBed;

-- ============================================
-- 9. SUMMARY OF DATA QUALITY
-- ============================================

-- Overall data quality report
SELECT 
    'Total Users' as metric,
    COUNT(DISTINCT Id) as value
FROM dailyActivity
UNION ALL
SELECT 
    'Total Daily Records' as metric,
    COUNT(*) as value
FROM dailyActivity
UNION ALL
SELECT 
    'Records with Zero Steps' as metric,
    COUNT(*) as value
FROM dailyActivity
WHERE TotalSteps = 0
UNION ALL
SELECT 
    'Date Range (Days)' as metric,
    JULIANDAY(MAX(ActivityDate)) - JULIANDAY(MIN(ActivityDate)) + 1 as value
FROM dailyActivity
UNION ALL
SELECT 
    'Sleep Records' as metric,
    COUNT(*) as value
FROM sleepDay
UNION ALL
SELECT 
    'Heart Rate Records' as metric,
    COUNT(*) as value
FROM heartrate_seconds;

-- ============================================
-- END OF CLEANING SCRIPT
-- Note: This script identifies issues but does not modify data
-- Use results to inform data cleaning decisions
-- ============================================
