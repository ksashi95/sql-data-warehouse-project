/*
-- -----------------------------------------------------------------------------------------
-- II. Cumulative Analysis : Aggregating the data progressively over the time
--                          helps to understand whether our business is growing or declining

--                    ∑ [cumulative measure] by [date dimension] aggregate window function
-- -----------------------------------------------------------------------------------------

Calculate running totals and moving averages to track long-term sales performance and business trends.
*/

-- 1. calculate the total sales per month and the running total of sales over time
SELECT   DATETRUNC(MONTH, order_date) AS order_date,
         SUM(sales_amount) AS total_sales
FROM     gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);




-- Running total across all months
SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_total
FROM
(
SELECT   DATETRUNC(MONTH, order_date) AS order_date,
         SUM(sales_amount) AS total_sales
FROM     gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
) t;


-- Running total per year
SELECT
order_date,
total_sales,
SUM(total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total
FROM
(
SELECT   DATETRUNC(MONTH, order_date) AS order_date,
         SUM(sales_amount) AS total_sales
FROM     gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
) t;


-- Running total by year
SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales
FROM
(
SELECT   DATETRUNC(YEAR, order_date) AS order_date,
         SUM(sales_amount) AS total_sales
FROM     gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
) t;


-- 2-year moving average 
SELECT
order_date,
total_sales,
avg_price,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS moving_avg_price
FROM
(
SELECT   DATETRUNC(YEAR, order_date) AS order_date,
         SUM(sales_amount) AS total_sales,
         AVG(price) AS avg_price
FROM     gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
) t;


-- 12-month moving average within each year
SELECT
order_date,
total_sales,
avg_price,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS moving_avg_price
FROM
(
SELECT   DATETRUNC(MONTH, order_date) AS order_date,
         SUM(sales_amount) AS total_sales,
         AVG(price) AS avg_price
FROM     gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
) t
ORDER BY DATETRUNC(MONTH, order_date) 


