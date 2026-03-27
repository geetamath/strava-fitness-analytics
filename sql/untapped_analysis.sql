-- ============================================
-- STRAVA FITNESS ANALYTICS - UNTAPPED INSIGHTS
-- Author: Geeta Siddramayya Math
-- Purpose: Additional hourly, weight, and minute-level analysis
-- ============================================

-- ============================================
-- 1. HOURLY ACTIVITY PATTERNS
-- ============================================

-- Hourly calorie burn patterns
SELECT 
    strftime('%H', ActivityHour) as hour,
    AVG(Calories) as avg_calories,
    SUM(Calories) as total_calories,
    COUNT(*) as num_readings
FROM hourlyCalories
GROUP BY hour
ORDER BY hour;

-- Peak activity hours by calories
SELECT 
    strftime('%H', ActivityHour) as hour,
    AVG(Calories) as avg_calories
FROM hourlyCalories
GROUP BY hour
ORDER BY avg_calories DESC
LIMIT 5;

-- Hourly steps analysis
SELECT 
    strftime('%H', ActivityHour) as hour,
    AVG(StepTotal) as avg_steps,
    SUM(StepTotal) as total_steps,
    MAX(StepTotal) as max_steps,
    COUNT(*) as num_readings
FROM hourlySteps
GROUP BY hour
ORDER BY hour;

-- Hourly intensity patterns
SELECT 
    strftime('%H', ActivityHour) as hour,
    AVG(TotalIntensity) as avg_intensity,
    AVG(AverageIntensity) as avg_intensity_level,
    COUNT(*) as num_readings
FROM hourlyIntensities
GROUP BY hour
ORDER BY hour;

-- ============================================
-- 2. INTENSITY ANALYSIS
-- ============================================

-- Daily intensity distribution
SELECT 
    Id,
    ActivityDate,
    VeryActiveMinutes,
    FairlyActiveMinutes,
    LightlyActiveMinutes,
    SedentaryMinutes,
    (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) as total_minutes
FROM dailyActivity
ORDER BY VeryActiveMinutes DESC
LIMIT 20;

-- Average intensity levels across all users
SELECT 
    AVG(VeryActiveMinutes) as avg_very_active,
    AVG(FairlyActiveMinutes) as avg_fairly_active,
    AVG(LightlyActiveMinutes) as avg_lightly_active,
    AVG(SedentaryMinutes) as avg_sedentary,
    AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) as avg_total_active
FROM dailyActivity;

-- Intensity correlation with calories
SELECT 
    VeryActiveMinutes,
    FairlyActiveMinutes,
    AVG(Calories) as avg_calories,
    AVG(TotalSteps) as avg_steps,
    COUNT(*) as num_records
FROM dailyActivity
GROUP BY VeryActiveMinutes, FairlyActiveMinutes
HAVING COUNT(*) >= 3
ORDER BY avg_calories DESC
LIMIT 20;

-- ============================================
-- 3. WEIGHT TRACKING ANALYSIS
-- ============================================

-- Weight trends over time
SELECT 
    Date,
    AVG(WeightKg) as avg_weight_kg,
    AVG(BMI) as avg_bmi,
    COUNT(DISTINCT Id) as num_users_logged
FROM weightLogInfo
GROUP BY Date
ORDER BY Date;

-- Individual weight progression
SELECT 
    Id,
    Date,
    WeightKg,
    BMI,
    LAG(WeightKg) OVER (PARTITION BY Id ORDER BY Date) as previous_weight,
    WeightKg - LAG(WeightKg) OVER (PARTITION BY Id ORDER BY Date) as weight_change
FROM weightLogInfo
ORDER BY Id, Date;

-- Average weight by user
SELECT 
    Id,
    AVG(WeightKg) as avg_weight_kg,
    AVG(BMI) as avg_bmi,
    COUNT(*) as num_logs,
    MIN(Date) as first_log,
    MAX(Date) as last_log
FROM weightLogInfo
GROUP BY Id
ORDER BY avg_weight_kg;

-- Weight vs Activity correlation
SELECT 
    w.Id,
    AVG(w.WeightKg) as avg_weight,
    AVG(a.TotalSteps) as avg_steps,
    AVG(a.Calories) as avg_calories,
    AVG(a.VeryActiveMinutes) as avg_very_active_min
FROM weightLogInfo w
JOIN dailyActivity a ON w.Id = a.Id AND DATE(w.Date) = a.ActivityDate
GROUP BY w.Id
HAVING COUNT(*) >= 3
ORDER BY avg_weight;

-- ============================================
-- 4. MINUTE-LEVEL ANALYSIS
-- ============================================

-- Minute calorie burst analysis
SELECT 
    strftime('%H:%M', ActivityMinute) as time,
    AVG(Calories) as avg_calories,
    MAX(Calories) as max_calories,
    COUNT(*) as num_readings
FROM minuteCaloriesNarrow
GROUP BY strftime('%H', ActivityMinute)
ORDER BY avg_calories DESC
LIMIT 20;

-- Minute steps burst analysis
SELECT 
    strftime('%H:%M', ActivityMinute) as time,
    AVG(Steps) as avg_steps,
    MAX(Steps) as max_steps,
    COUNT(*) as num_readings
FROM minuteStepsNarrow
GROUP BY strftime('%H', ActivityMinute)
ORDER BY avg_steps DESC
LIMIT 20;

-- Minute intensity bursts
SELECT 
    strftime('%H:%M', ActivityMinute) as time,
    AVG(Intensity) as avg_intensity,
    MAX(Intensity) as max_intensity,
    COUNT(*) as num_readings
FROM minuteIntensitiesNarrow
GROUP BY strftime('%H', ActivityMinute)
ORDER BY avg_intensity DESC
LIMIT 20;

-- ============================================
-- 5. SLEEP QUALITY ANALYSIS
-- ============================================

-- Sleep efficiency (time asleep / time in bed)
SELECT 
    Id,
    SleepDay,
    TotalMinutesAsleep,
    TotalTimeInBed,
    ROUND(TotalMinutesAsleep * 100.0 / TotalTimeInBed, 2) as sleep_efficiency_percent,
    (TotalTimeInBed - TotalMinutesAsleep) as awake_in_bed_minutes
FROM sleepDay
WHERE TotalTimeInBed > 0
ORDER BY sleep_efficiency_percent;

-- Average sleep quality by user
SELECT 
    Id,
    AVG(TotalMinutesAsleep) / 60.0 as avg_hours_sleep,
    AVG(TotalTimeInBed) / 60.0 as avg_hours_in_bed,
    AVG(TotalMinutesAsleep * 100.0 / TotalTimeInBed) as avg_sleep_efficiency,
    COUNT(*) as sleep_records
FROM sleepDay
WHERE TotalTimeInBed > 0
GROUP BY Id
ORDER BY avg_sleep_efficiency DESC;

-- Sleep patterns by day of week
SELECT 
    CASE CAST(strftime('%w', SleepDay) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END as day_of_week,
    AVG(TotalMinutesAsleep) / 60.0 as avg_hours_sleep,
    COUNT(*) as num_records
FROM sleepDay
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
-- 6. COMBINED HOURLY INSIGHTS
-- ============================================

-- Hourly activity summary (steps, calories, intensity)
SELECT 
    strftime('%H', hc.ActivityHour) as hour,
    AVG(hc.Calories) as avg_calories,
    AVG(hs.StepTotal) as avg_steps,
    AVG(hi.AverageIntensity) as avg_intensity
FROM hourlyCalories hc
LEFT JOIN hourlySteps hs 
    ON hc.Id = hs.Id AND hc.ActivityHour = hs.ActivityHour
LEFT JOIN hourlyIntensities hi 
    ON hc.Id = hi.Id AND hc.ActivityHour = hi.ActivityHour
GROUP BY hour
ORDER BY hour;

-- Peak vs low activity hours
SELECT 
    'Peak Hours' as period,
    strftime('%H', ActivityHour) as hour,
    AVG(Calories) as avg_calories
FROM hourlyCalories
GROUP BY hour
HAVING AVG(Calories) >= (SELECT AVG(Calories) * 1.2 FROM hourlyCalories)
UNION ALL
SELECT 
    'Low Hours' as period,
    strftime('%H', ActivityHour) as hour,
    AVG(Calories) as avg_calories
FROM hourlyCalories
GROUP BY hour
HAVING AVG(Calories) <= (SELECT AVG(Calories) * 0.8 FROM hourlyCalories)
ORDER BY period, avg_calories DESC;

-- ============================================
-- 7. ACTIVE VS SEDENTARY BALANCE
-- ============================================

-- Daily active/sedentary ratio
SELECT 
    Id,
    ActivityDate,
    VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes as total_active_minutes,
    SedentaryMinutes,
    ROUND((VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) * 100.0 / 
          (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes), 2) as active_percentage
FROM dailyActivity
WHERE (VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) > 0
ORDER BY active_percentage DESC
LIMIT 20;

-- User activity classification
SELECT 
    Id,
    AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) as avg_active_minutes,
    AVG(SedentaryMinutes) as avg_sedentary_minutes,
    CASE 
        WHEN AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) >= 60 THEN 'Highly Active'
        WHEN AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) >= 30 THEN 'Moderately Active'
        WHEN AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) >= 15 THEN 'Lightly Active'
        ELSE 'Sedentary'
    END as activity_classification
FROM dailyActivity
GROUP BY Id
ORDER BY avg_active_minutes DESC;

-- ============================================
-- 8. MONTHLY TRENDS
-- ============================================

-- Monthly progression
SELECT 
    strftime('%Y-%m', ActivityDate) as month,
    AVG(TotalSteps) as avg_steps,
    AVG(Calories) as avg_calories,
    AVG(VeryActiveMinutes) as avg_very_active,
    COUNT(DISTINCT Id) as active_users
FROM dailyActivity
GROUP BY month
ORDER BY month;

-- Month-over-month growth
SELECT 
    strftime('%Y-%m', ActivityDate) as month,
    SUM(TotalSteps) as total_steps,
    LAG(SUM(TotalSteps)) OVER (ORDER BY strftime('%Y-%m', ActivityDate)) as prev_month_steps,
    SUM(TotalSteps) - LAG(SUM(TotalSteps)) OVER (ORDER BY strftime('%Y-%m', ActivityDate)) as steps_change
FROM dailyActivity
GROUP BY month
ORDER BY month;

-- ============================================
-- 9. ADVANCED CORRELATIONS
-- ============================================

-- Steps vs Distance efficiency
SELECT 
    Id,
    ActivityDate,
    TotalSteps,
    TotalDistance,
    CASE 
        WHEN TotalSteps > 0 THEN ROUND(TotalDistance * 1000 / TotalSteps, 2)
        ELSE 0
    END as meters_per_step
FROM dailyActivity
WHERE TotalSteps > 0
ORDER BY meters_per_step DESC
LIMIT 20;

-- Calorie burn efficiency (calories per step)
SELECT 
    Id,
    ActivityDate,
    TotalSteps,
    Calories,
    CASE 
        WHEN TotalSteps > 0 THEN ROUND(Calories * 1.0 / TotalSteps, 4)
        ELSE 0
    END as calories_per_step
FROM dailyActivity
WHERE TotalSteps > 0
ORDER BY calories_per_step DESC
LIMIT 20;

-- ============================================
-- END OF UNTAPPED ANALYSIS
-- ============================================
