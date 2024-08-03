# PART 1: Data Cleaning

------------------------------------------------
## 1. Handling Missing Values

### 1.1. Identify missing value in the Dataset

SELECT *
FROM worldlifeexpectancy
WHERE Status = '' OR Status IS NULL;

SELECT *
FROM worldlifeexpectancy
WHERE Lifeexpectancy = '' OR Lifeexpectancy IS NULL;

/* Columns: Status & Lifeexpectancy have missing values */

### 1.2. Handle missing values: "Status"

/* For the "Status" column, use the "Status" data from the same Country in the remaining years to replace the missing value */

UPDATE worldlifeexpectancy
SET Status = 'Developing' 
WHERE Country IN ('Afghanistan', 'Albania' ,'Georgia', 'Vanuatu', 'Zambia'); 

UPDATE worldlifeexpectancy
SET Status = 'Developed' 
WHERE Country = 'United States of America';

### 1.3. Handle missing values: "Lifeexpectancy"

/* For the "Lifeexpectancy" column, use the average value of the previous year and the next year to replace the missing value */

UPDATE worldlifeexpectancy
SET Lifeexpectancy = '59.1'
WHERE Country = 'Afghanistan' AND Lifeexpectancy = '';

UPDATE worldlifeexpectancy
SET Lifeexpectancy = '76.5'
WHERE Country = 'Albania' AND Lifeexpectancy = '';

------------------------------------------------
## 2. Data Consistency

### 2.1. Check for inconsistencies in categorical columns such as "Country" and "Status"

SELECT DISTINCT Country 
FROM worldlifeexpectancy;

/* Data in the "Country" column has many non-standard values - For example: Iran (Islamic Republic of) 
-> Needs to be changed to Islamic Republic of Iran to standardize with other values, similarly with other values */

### 2.2. Handle inconsistencies in categorical columns such as "Country" and "Status"

UPDATE worldlifeexpectancy
SET Country = 'Plurinational State of Bolivia'
WHERE Country = 'Bolivia (Plurinational State of)';

UPDATE worldlifeexpectancy
SET Country = 'Islamic Republic of Iran'
WHERE Country = 'Iran (Islamic Republic of)';

UPDATE worldlifeexpectancy
SET Country = 'Federated States of Micronesia'
WHERE Country = 'Micronesia (Federated States of)';

UPDATE worldlifeexpectancy
SET Country = 'Federated States of Micronesia'
WHERE Country = 'Venezuela (Bolivarian Republic of)';

------------------------------------------------
## 3. Removing Duplicates: 

### 3.1. Find duplicates by using the first three columns (Country, Year, Status)

WITH row_num_table AS (
SELECT Country
	, Year
    , Status
    , Row_id
	, ROW_NUMBER() OVER(PARTITION BY Country, Year, Status ORDER BY Year) AS row_num
FROM worldlifeexpectancy
) 
SELECT *
FROM row_num_table
WHERE Row_num > 1;

### 3.2. Delete duplicate values from the table

DELETE FROM worldlifeexpectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT 
            Row_ID,
            ROW_NUMBER() OVER (PARTITION BY Country, Year, Status ORDER BY Year) AS row_num
        FROM 
            worldlifeexpectancy
    ) AS ranked_data
    WHERE row_num > 1
);

------------------------------------------------
## 4. Outlier Detection and Treatment:

SELECT * 
FROM worldlifeexpectancy
WHERE Country = 'Afghanistan';

/* Check visually the data for Afghanistan to see if there are outliers and what kind of outliers there are.*/
/* The column AdultMortality has one value of 3 which is very different from the usual values of this column (291, 293, 295). If we use only the Z-score method and replace it with the mean value, it will not be accurate due to the influence of outliers. Therefore, use the IQR method to identify outliers as well.*/

### 4.1. Lifeexpectancy (group by country)

#### 4.1.1. Find Outlier

-- Create a temporary table to store the number of rows in each group
CREATE TEMPORARY TABLE group_stats AS
SELECT country
    , COUNT(*) AS total_rows
FROM worldlifeexpectancy
GROUP BY country;

-- Use the ROW_NUMBER() window function to assign a sequential number to each value within each group
WITH ranked_data AS (
    SELECT Country
        , Year
        , Lifeexpectancy
        , ROW_NUMBER() OVER (PARTITION BY country ORDER BY Lifeexpectancy) AS row_num
    FROM worldlifeexpectancy
)
-- Calculate Q1 and Q3 for each `country` group
, quartiles AS (
    SELECT ranked_data.country
        , CASE 
            WHEN total_rows < 4 THEN MIN(Lifeexpectancy)  -- If less than 4 rows, use the minimum value of the group
            ELSE MAX(CASE WHEN row_num <= 0.25 * total_rows THEN Lifeexpectancy END)
        END AS Q1
        , CASE 
            WHEN total_rows < 4 THEN MAX(Lifeexpectancy)  -- If less than 4 rows, use the maximum value of the group
            ELSE MAX(CASE WHEN row_num <= 0.75 * total_rows THEN Lifeexpectancy END)
        END AS Q3
    FROM ranked_data
    JOIN group_stats ON ranked_data.country = group_stats.country
    GROUP BY ranked_data.country, group_stats.total_rows
)
-- Calculate IQR for each `country` group
, iqr AS (
    SELECT country
        , Q1
        , Q3
        , Q3 - Q1 AS IQR
        , Q1 - 1.5 * (Q3 - Q1) AS lower_bound
        , Q3 + 1.5 * (Q3 - Q1) AS upper_bound
    FROM quartiles
)
, outlier_iqr AS (
SELECT wd.Country
    , wd.Year
    , wd.Lifeexpectancy
    , iqr.lower_bound
    , iqr.upper_bound
    , CASE
        WHEN wd.Lifeexpectancy < iqr.lower_bound THEN 'Below Lower Bound'
        WHEN wd.Lifeexpectancy > iqr.upper_bound THEN 'Above Upper Bound'
        ELSE 'Within Range'
    END AS outlier_status_iqr
FROM worldlifeexpectancy wd
JOIN iqr ON wd.country = iqr.country
)
-- Calculate mean and std
, stats AS (
    SELECT country
        , AVG(Lifeexpectancy) AS mean
        , STDDEV(Lifeexpectancy) AS std_dev
    FROM worldlifeexpectancy
    GROUP BY country
)
-- Find zscore
, z_score AS (
    SELECT w.Country
        , w.Year
        , Lifeexpectancy
        , (Lifeexpectancy - mean) / std_dev AS z_score
    FROM worldlifeexpectancy AS w
    JOIN stats s ON w.country = s.country
)
, outlier_z_score AS (
SELECT Country
    , Year
    , Lifeexpectancy
    , z_score
    , CASE
        WHEN ABS(z_score) > 3 THEN 'Outlier'
        ELSE 'Normal'
    END AS outlier_status_zscore
FROM z_score
)
, outlier_status AS (
SELECT z_score.Country
    , z_score.Year 
    , z_score.Lifeexpectancy
    , outlier_status_iqr
    , outlier_status_zscore
FROM outlier_iqr AS iqr
JOIN outlier_z_score AS z_score
    ON iqr.Country = z_score.Country AND iqr.Year = z_score.Year
)
-- Find outliers using both methods
SELECT *
FROM outlier_status
WHERE outlier_status_iqr <> 'Within Range' AND outlier_status_zscore = 'Outlier';

#### 4.1.2. Handle Outlier

-- Check if the outliers are reasonable.

SELECT *
FROM worldlifeexpectancy
WHERE Country = 'Haiti';

/*5 outliers:
- Cabo Verde (2009): 77 -> Not unusually high compared to other years, so it can be ignored.
- Eritrea (2007): 45.3 -> The first year, so it might be low; life expectancy increases in subsequent years, so it can be ignored.
- Haiti (2017): 36.3 -> Unusually low, and the mortality rate in 2017 is also high -> Needs further investigation to identify any issues.
- Libya (2007): 78 -> Not unusually high compared to other years, so it can be ignored.
- Paraguay (2007): 79 -> Not unusually high compared to other years, so it can be ignored.*/

/*According to actual data, there was nothing unusual in Haiti in 2017, so the sudden drop in lifeexpectancy is not reasonable. 
--> Replace the outlier with the average value. */

UPDATE worldlifeexpectancy
SET Lifeexpectancy = (
    SELECT ROUND(AVG(Lifeexpectancy), 1)
    FROM worldlifeexpectancy
    WHERE Country = 'Haiti'
)
WHERE Country = 'Haiti' AND Year = 2017;

### 4.2. AdultMortality

#### 4.2.1. Find Outlier: 

-- Create temporary table to save outliers list
CREATE TEMPORARY TABLE temp_outliers AS
-- Use the ROW_NUMBER() window function to assign a sequential number to each value within each group
WITH ranked_data AS (
    SELECT Country
        , Year
        , AdultMortality
        , ROW_NUMBER() OVER (PARTITION BY country ORDER BY AdultMortality) AS row_num
    FROM worldlifeexpectancy
)
-- Calculate Q1 and Q3 for each `country` group
, quartiles AS (
    SELECT ranked_data.country
        , CASE 
            WHEN total_rows < 4 THEN MIN(AdultMortality)  -- If less than 4 rows, use the minimum value of the group
            ELSE MAX(CASE WHEN row_num <= 0.25 * total_rows THEN AdultMortality END)
        END AS Q1
        , CASE 
            WHEN total_rows < 4 THEN MAX(AdultMortality)  -- If less than 4 rows, use the maximum value of the group
            ELSE MAX(CASE WHEN row_num <= 0.75 * total_rows THEN AdultMortality END)
        END AS Q3
    FROM ranked_data
    JOIN group_stats ON ranked_data.country = group_stats.country
    GROUP BY ranked_data.country, group_stats.total_rows
)
-- Calculate IQR for each `country` group
, iqr AS (
    SELECT country
        , Q1
        , Q3
        , Q3 - Q1 AS IQR
        , Q1 - 1.5 * (Q3 - Q1) AS lower_bound
        , Q3 + 1.5 * (Q3 - Q1) AS upper_bound
    FROM quartiles
)
, outlier_iqr AS (
SELECT wd.Country
    , wd.Year
    , wd.AdultMortality
    , iqr.lower_bound
    , iqr.upper_bound
    , CASE
        WHEN wd.AdultMortality < iqr.lower_bound THEN 'Below Lower Bound'
        WHEN wd.AdultMortality > iqr.upper_bound THEN 'Above Upper Bound'
        ELSE 'Within Range'
    END AS outlier_status_iqr
FROM worldlifeexpectancy wd
JOIN iqr ON wd.country = iqr.country
)
-- Calculate mean and std
, stats AS (
    SELECT country
        , AVG(AdultMortality) AS mean
        , STDDEV(AdultMortality) AS std_dev
    FROM worldlifeexpectancy
    GROUP BY country
)
-- Find zscore
, z_score AS (
    SELECT w.Country
        , w.Year
        , AdultMortality
        , (AdultMortality - mean) / std_dev AS z_score
    FROM worldlifeexpectancy AS w
    JOIN stats s ON w.country = s.country
)
, outlier_z_score AS (
SELECT Country
    , Year
    , AdultMortality
    , z_score
    , CASE
        WHEN ABS(z_score) > 3 THEN 'Outlier'
        ELSE 'Normal'
    END AS outlier_status_zscore
FROM z_score
)
, outlier_status AS (
SELECT z_score.Country
    , z_score.Year 
    , z_score.AdultMortality
    , outlier_status_iqr
    , outlier_status_zscore
FROM outlier_iqr AS iqr
JOIN outlier_z_score AS z_score
    ON iqr.Country = z_score.Country AND iqr.Year = z_score.Year
)
-- Find outliers using both methods
SELECT *
FROM outlier_status
WHERE outlier_status_iqr <> 'Within Range' AND outlier_status_zscore = 'Outlier';

#### 4.2.1. Handle Outlier: 

UPDATE worldlifeexpectancy
SET AdultMortality = 300
WHERE Country = 'Afghanistan' AND year = 2009;

UPDATE worldlifeexpectancy
SET AdultMortality = 60
WHERE Country = 'Australia' AND year = 2021;

UPDATE worldlifeexpectancy
SET AdultMortality = 140
WHERE Country = 'Bangladesh' AND year = 2018;

-- After updating some outliers, I realized that the outliers were due to missing zeros >> Add zeros to the AdultMortality values of the outlier rows

UPDATE worldlifeexpectancy AS w
INNER JOIN temp_outliers AS t
  ON w.Country = t.Country AND w.Year = t.Year
SET w.AdultMortality = CONCAT(w.AdultMortality, '0');

SELECT *
FROM worldlifeexpectancy
WHERE Country = 'Viet Nam';

### 4.3. GDP

#### 4.3.1. Find Outlier

-- Use the ROW_NUMBER() window function to assign a sequential number to each value within each group
WITH ranked_data AS (
    SELECT Country
        , Year
        , GDP
        , ROW_NUMBER() OVER (PARTITION BY country ORDER BY GDP) AS row_num
    FROM worldlifeexpectancy
)
-- Calculate Q1 and Q3 for each `country` group
, quartiles AS (
    SELECT ranked_data.country
        , CASE 
            WHEN total_rows < 4 THEN MIN(GDP)  -- If less than 4 rows, use the minimum value of the group
            ELSE MAX(CASE WHEN row_num <= 0.25 * total_rows THEN GDP END)
        END AS Q1
        , CASE 
            WHEN total_rows < 4 THEN MAX(GDP)  -- If less than 4 rows, use the maximum value of the group
            ELSE MAX(CASE WHEN row_num <= 0.75 * total_rows THEN GDP END)
        END AS Q3
    FROM ranked_data
    JOIN group_stats ON ranked_data.country = group_stats.country
    GROUP BY ranked_data.country, group_stats.total_rows
)
-- Calculate IQR for each `country` group
, iqr AS (
    SELECT country
        , Q1
        , Q3
        , Q3 - Q1 AS IQR
        , Q1 - 1.5 * (Q3 - Q1) AS lower_bound
        , Q3 + 1.5 * (Q3 - Q1) AS upper_bound
    FROM quartiles
)
, outlier_iqr AS (
SELECT wd.Country
    , wd.Year
    , wd.GDP
    , iqr.lower_bound
    , iqr.upper_bound
    , CASE
        WHEN wd.GDP < iqr.lower_bound THEN 'Below Lower Bound'
        WHEN wd.GDP > iqr.upper_bound THEN 'Above Upper Bound'
        ELSE 'Within Range'
    END AS outlier_status_iqr
FROM worldlifeexpectancy wd
JOIN iqr ON wd.country = iqr.country
)
-- Calculate mean and std
, stats AS (
    SELECT country
        , AVG(GDP) AS mean
        , STDDEV(GDP) AS std_dev
    FROM worldlifeexpectancy
    GROUP BY country
)
-- Find zscore
, z_score AS (
    SELECT w.Country
        , w.Year
        , GDP
        , (GDP - mean) / std_dev AS z_score
    FROM worldlifeexpectancy AS w
    JOIN stats s ON w.country = s.country
)
, outlier_z_score AS (
SELECT Country
    , Year
    , GDP
    , z_score
    , CASE
        WHEN ABS(z_score) > 3 THEN 'Outlier'
        ELSE 'Normal'
    END AS outlier_status_zscore
FROM z_score
)
, outlier_status AS (
SELECT z_score.Country
    , z_score.Year 
    , z_score.GDP
    , outlier_status_iqr
    , outlier_status_zscore
FROM outlier_iqr AS iqr
JOIN outlier_z_score AS z_score
    ON iqr.Country = z_score.Country AND iqr.Year = z_score.Year
)
-- Find outliers using both methods
SELECT *
FROM outlier_status
WHERE outlier_status_iqr <> 'Within Range' AND outlier_status_zscore = 'Outlier';

#### 4.3.2 Handle outliers (e.g., average).

SELECT *
FROM worldlifeexpectancy
WHERE Country = 'Belize';

/* 1 outlier Belize (2015): 447 
the issue might be due to missing trailing digits. 
--> Add extra zeros to the end of the value.*/

UPDATE worldlifeexpectancy
SET GDP = 4470
WHERE Country = 'Belize' AND year = 2015;

#### 4.4: 

WITH row_num_table AS (
SELECT country
    , COUNT(*) AS total_rows
FROM worldlifeexpectancy
GROUP BY country
)
SELECT *
FROM worldlifeexpectancy AS w
LEFT JOIN row_num_table AS r
	ON w.country = r.country
WHERE total_rows = 1;

/*There are 4 countries with incomplete data for the years compared to other countries. Checking the data for Life Expectancy, Adult Mortality, and Infant Deaths shows all values as 0, which is unrealistic 
--> Remove these rows to prevent them from affecting the overall results. */

DELETE FROM worldlifeexpectancy 
WHERE Country IN ('Cook Islands', 'Dominica', 'Marshall Islands', 'San Marino', 'Niue', 'Palau', 'Monaco', 'Saint Kitts and Nevis', 'Tuvalu', 'Nauru');



    
