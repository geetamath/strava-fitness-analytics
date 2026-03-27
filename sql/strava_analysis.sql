-- ============================================
-- STRAVA FITNESS ANALYTICS - CORE SQL QUERIES
-- Author: Geeta Siddramayya Math
-- Database: SQLite (strava_fitness.db)
-- ============================================

-- ============================================
-- 1. TOTAL STEPS ANALYSIS
-- ============================================

-- Total steps per day (aggregate across all users)
SELECT 
    ActivityDate, 
    SUM(TotalSteps) as total_steps,
    COUNT(DISTINCT Id) as num_users
FROM dailyActivity 
GROUP BY ActivityDate 
ORDER BY ActivityDate;

-- Total steps per week
SELECT 
    strftime('%Y-%W', ActivityDate) as week,
    SUM(TotalSteps) as total_steps,
    AVG(TotalSteps) as avg_steps_per_day
FROM dailyActivity 
GROUP BY week
ORDER BY week;

-- Total steps per month
SELECT 
    strftime('%Y-%m', ActivityDate) as month,
    SUM(TotalSteps) as total_steps,
    AVG(TotalSteps) as avg_steps_per_day,
    COUNT(DISTINCT Id) as active_users
FROM dailyActivity 
GROUP BY month
ORDER BY month;

-- ============================================
-- 2. CALORIES ANALYSIS
-- ============================================

-- Average calories by activity level
SELECT 
    VeryActiveMinutes,
    AVG(Calories) as avg_calories,
    COUNT(*) as num_records
FROM dailyActivity 
GROUP BY VeryActiveMinutes
ORDER BY VeryActiveMinutes;

-- Calories burned by activity category
SELECT 
    CASE 
        WHEN VeryActiveMinutes >= 30 THEN 'High Activity'
        WHEN VeryActiveMinutes >= 15 THEN 'Moderate Activity'
        WHEN VeryActiveMinutes > 0 THEN 'Low Activity'
        ELSE 'Sedentary'
    END as activity_level,
    AVG(Calories) as avg_calories,
    AVG(TotalSteps) as avg_steps,
    COUNT(*) as num_days
FROM dailyActivity
GROUP BY activity_level
ORDER BY avg_calories DESC;

-- Daily calories summary
SELECT 
    ActivityDate,
    SUM(Calories) as total_calories,
    AVG(Calories) as avg_calories_per_user,
    MAX(Calories) as max_calories,
    MIN(Calories) as min_calories
FROM dailyActivity
GROUP BY ActivityDate
ORDER BY ActivityDate;

-- ============================================
-- 3. HEART RATE ANALYSIS
-- ============================================

-- Average heart rate by day
SELECT 
    DATE(Time) as day,
    AVG(Value) as avg_heart_rate,
    MIN(Value) as min_heart_rate,
    MAX(Value) as max_heart_rate,
    COUNT(*) as num_readings
FROM heartrate_seconds
GROUP BY day
ORDER BY day;

-- Heart rate distribution
SELECT 
    CASE
        WHEN Value < 60 THEN 'Low (<60)'
        WHEN Value BETWEEN 60 AND 100 THEN 'Normal (60-100)'
        WHEN Value BETWEEN 101 AND 120 THEN 'Elevated (101-120)'
        ELSE 'High (>120)'
    END as heart_rate_category,
    COUNT(*) as num_readings,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM heartrate_seconds), 2) as percentage
FROM heartrate_seconds
GROUP BY heart_rate_category
ORDER BY num_readings DESC;

-- ============================================
-- 4. SLEEP VS ACTIVITY CORRELATION
-- ============================================

-- Sleep and activity correlation data
SELECT 
    s.Id,
    s.SleepDay,
    s.TotalMinutesAsleep / 60.0 as hours_asleep,
    s.TotalTimeInBed / 60.0 as hours_in_bed,
    a.TotalSteps,
    a.Calories,
    a.VeryActiveMinutes,
    a.FairlyActiveMinutes,
    a.LightlyActiveMinutes,
    a.SedentaryMinutes
FROM sleepDay s
JOIN dailyActivity a 
    ON s.Id = a.Id 
    AND DATE(s.SleepDay) = a.ActivityDate
ORDER BY s.SleepDay;

-- Average sleep by activity level
SELECT 
    CASE 
        WHEN a.VeryActiveMinutes >= 30 THEN 'High Activity'
        WHEN a.VeryActiveMinutes >= 15 THEN 'Moderate Activity'
        WHEN a.VeryActiveMinutes > 0 THEN 'Low Activity'
        ELSE 'Sedentary'
    END as activity_level,
    AVG(s.TotalMinutesAsleep) / 60.0 as avg_hours_sleep,
    AVG(a.TotalSteps) as avg_steps,
    COUNT(*) as num_days
FROM sleepDay s
JOIN dailyActivity a 
    ON s.Id = a.Id 
    AND DATE(s.SleepDay) = a.ActivityDate
GROUP BY activity_level
ORDER BY avg_hours_sleep DESC;

-- ============================================
-- 5. USER ACTIVITY PATTERNS
-- ============================================

-- Individual user summary
SELECT 
    Id,
    COUNT(*) as active_days,
    AVG(TotalSteps) as avg_steps,
    AVG(Calories) as avg_calories,
    AVG(VeryActiveMinutes) as avg_very_active_min,
    SUM(TotalSteps) as total_steps
FROM dailyActivity
GROUP BY Id
ORDER BY avg_steps DESC;

-- Most active users
SELECT 
    Id,
    AVG(TotalSteps) as avg_daily_steps,
    AVG(Calories) as avg_daily_calories,
    COUNT(*) as days_tracked
FROM dailyActivity
GROUP BY Id
HAVING COUNT(*) >= 20  -- At least 20 days of data
ORDER BY avg_daily_steps DESC
LIMIT 10;

-- Least active users
SELECT 
    Id,
    AVG(TotalSteps) as avg_daily_steps,
    AVG(Calories) as avg_daily_calories,
    COUNT(*) as days_tracked
FROM dailyActivity
GROUP BY Id
HAVING COUNT(*) >= 20
ORDER BY avg_daily_steps ASC
LIMIT 10;

-- ============================================
-- 6. DAILY PATTERNS
-- ============================================

-- Day of week analysis
SELECT 
    CASE CAST(strftime('%w', ActivityDate) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as day_of_week,
    AVG(TotalSteps) as avg_steps,
    AVG(Calories) as avg_calories,
    AVG(VeryActiveMinutes) as avg_very_active_min,
    COUNT(*) as num_records
FROM dailyActivity
GROUP BY day_of_week
ORDER BY 
    CASE day_of_week
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- ============================================
-- 7. ACTIVITY DISTANCE ANALYSIS
-- ============================================

-- Distance by activity type
SELECT 
    ActivityDate,
    SUM(VeryActiveDistance) as total_very_active_distance,
    SUM(ModeratelyActiveDistance) as total_moderate_distance,
    SUM(LightActiveDistance) as total_light_distance,
    SUM(SedentaryActiveDistance) as total_sedentary_distance,
    SUM(TotalDistance) as total_distance
FROM dailyActivity
GROUP BY ActivityDate
ORDER BY ActivityDate;

-- Average distance per activity level
SELECT 
    AVG(VeryActiveDistance) as avg_very_active_km,
    AVG(ModeratelyActiveDistance) as avg_moderate_km,
    AVG(LightActiveDistance) as avg_light_km,
    AVG(TotalDistance) as avg_total_km
FROM dailyActivity;

-- ============================================
-- 8. OVERALL STATISTICS
-- ============================================

-- Grand summary of all metrics
SELECT 
    COUNT(DISTINCT Id) as total_users,
    COUNT(*) as total_records,
    AVG(TotalSteps) as avg_steps,
    AVG(Calories) as avg_calories,
    AVG(TotalDistance) as avg_distance_km,
    AVG(VeryActiveMinutes) as avg_very_active_min,
    AVG(FairlyActiveMinutes) as avg_fairly_active_min,
    AVG(LightlyActiveMinutes) as avg_lightly_active_min,
    AVG(SedentaryMinutes) as avg_sedentary_min
FROM dailyActivity;

-- Data quality check
SELECT 
    'dailyActivity' as table_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT Id) as unique_users,
    MIN(ActivityDate) as start_date,
    MAX(ActivityDate) as end_date
FROM dailyActivity
UNION ALL
SELECT 
    'sleepDay' as table_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT Id) as unique_users,
    MIN(DATE(SleepDay)) as start_date,
    MAX(DATE(SleepDay)) as end_date
FROM sleepDay
UNION ALL
SELECT 
    'heartrate_seconds' as table_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT Id) as unique_users,
    MIN(DATE(Time)) as start_date,
    MAX(DATE(Time)) as end_date
FROM heartrate_seconds;
