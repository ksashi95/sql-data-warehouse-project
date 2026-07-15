/*
-- ------------------------------------------------------------------------
-- I. Changes-Over-Time Analysis : A technique inorder to analyse,
-- 								   how a measure evolves over time

--                        ∑ [measure] by [date dimension]
-- ------------------------------------------------------------------------
    Analyze sales trends over time using monthly and 
    yearly aggregations to understand business growth and seasonality.
*/


-- 1. analyse sales performance over time

SELECT   YEAR(order_date) AS order_year,
         MONTH(order_date) AS order_month,
         SUM(sales_amount) AS total_Sales,
         COUNT(DISTINCT (customer_key)) AS total_customers,
         SUM(quantity) AS total_quantity
FROM     gold.fact_sales
WHERE    order_date IS NOT NULL
         -- AND YEAR(order_date) = '2013'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


--   DATETRUNC(MONTH, order_date)

SELECT   DATETRUNC(MONTH, order_date) AS order_date,
         SUM(sales_amount) AS total_Sales,
         COUNT(DISTINCT (customer_key)) AS total_customers,
         SUM(quantity) AS total_quantity
FROM     gold.fact_sales
WHERE    order_date IS NOT NULL
         -- AND YEAR(order_date) = '2013'
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);


--    FORMAT(order_date, 'yyyy-MMM') 

SELECT   FORMAT(order_date,'yyyy-MMM') AS order_date,
         SUM(sales_amount) AS total_Sales,
         COUNT(DISTINCT (customer_key)) AS total_customers,
         SUM(quantity) AS total_quantity
FROM     gold.fact_sales
WHERE    order_date IS NOT NULL
         -- AND YEAR(order_date) = '2013'
GROUP BY FORMAT(order_date,'yyyy-MMM')
ORDER BY FORMAT(order_date,'yyyy-MMM'); --  not ordered by month


--    FORMAT(order_date, 'yyyy-MMM') 

SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    FORMAT(order_date, 'yyyy-MMM')
ORDER BY
    YEAR(order_date),
    MONTH(order_date);

-- preferred method FORMAT(DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1), 'yyyy-MMM')

SELECT 
    FORMAT(DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1), 'yyyy-MMM') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1);

