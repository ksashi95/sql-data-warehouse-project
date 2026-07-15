/*
-- ------------------------------------------------------------------------
-- III. Date exploration : MIN/MAX [date dimension]
-- ------------------------------------------------------------------------

Purpose: Analyze the available time range of sales data and 
identify the oldest and youngest customers in the dataset.
*/


-- identify the earliest and latest dates (boundaries) understand the scope of data and timespan
-- find the first order date, last order date and range of dates in year, month and days

SELECT 
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(YEAR,MIN(order_date),MAX(order_date)) AS order_range_years,
DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS order_range_months,
DATEDIFF(DAY,MIN(order_date),MAX(order_date)) AS order_range_days
FROM gold.fact_sales;

-- find the youngest and oldest customers

SELECT 
MIN(birthdate) AS youngest_birthdate,
DATEDIFF(YEAR,MIN(birthdate),GETDATE()) AS oldest_age, 
MAX(birthdate) AS oldest_birthdate,
DATEDIFF(YEAR,MAX(birthdate),GETDATE()) AS youngest_age
FROM gold.dim_customers;




SELECT *
FROM
(
    SELECT TOP 1
        'Oldest' AS person_type,
        CONCAT(first_name, ' ', last_name) AS full_name,
        birthdate,
        DATEDIFF(YEAR,birthdate,GETDATE()) AS years
    FROM gold.dim_customers
    WHERE birthdate IS NOT NULL
    ORDER BY birthdate ASC
) AS oldest

UNION ALL

SELECT *
FROM
(
    SELECT TOP 1
        'Youngest' AS person_type,
        CONCAT(first_name, ' ', last_name) AS full_name,
        birthdate,
        DATEDIFF(YEAR,birthdate,GETDATE()) AS years
    FROM gold.dim_customers
    ORDER BY birthdate DESC
) AS youngest;
