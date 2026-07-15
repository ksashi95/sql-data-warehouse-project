/*

-- -----------------------------------------------------------------------------------------
-- IV. Data Segmentation : Group the data based on a specific range.
--                         Helps understand the correlation between two measures.

--                    [measure] by [measure]
-- -----------------------------------------------------------------------------------------
    Group products and customers into meaningful segments based on 
    cost, spending, and purchasing behavior for deeper business insights.
*/

-- 1. segment products into cost ranges and count how many products fall into each segment.

-- Sub query
SELECT   cost_range,
         COUNT(product_name) AS product_counts
FROM     
    (SELECT 
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100' 
            WHEN cost < 100 THEN 'Below 100' 
            WHEN cost BETWEEN 100 AND 500 THEN '100-500' 
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000' 
            ELSE 'Above 1000' 
        END AS cost_range
     FROM gold.dim_products
    ) AS product_segment
GROUP BY cost_range
ORDER BY product_counts;


-- CTE
WITH product_segment 
AS
    (SELECT 
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100' 
            WHEN cost < 100 THEN 'Below 100' 
            WHEN cost BETWEEN 100 AND 500 THEN '100-500' 
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000' 
            ELSE 'Above 1000' 
        END AS cost_range
     FROM gold.dim_products
    )
SELECT 
cost_range,
COUNT(product_name) AS product_counts
FROM product_segment
GROUP BY cost_range
ORDER BY product_counts;

-- -----------------------------------------------------------------------------------------

/*
2. Group customers into three segments based on their spending behaviour:
    - VIP: customers with atleast 12 months of history and spending more than 5000.
    - Regular: customers with atleast 12 months of history but  spending 5000 or less.
    - New: customers with a lifespan of 12 months.
and find the total number of customers by each group
*/

WITH     customer_spending
AS       (SELECT   c.customer_key,
                   SUM(f.sales_amount) AS total_spending,
                   MIN(order_date) AS first_order,
                   MAX(order_date) AS last_order,
                   DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
          FROM     gold.fact_sales AS f
                   LEFT OUTER JOIN gold.dim_customers AS c
                   ON f.customer_key = c.customer_key
          GROUP BY c.customer_key),
         customer_class 
AS       (SELECT customer_key,
                 total_spending,
                 lifespan,
                 CASE 
                     WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP' 
                     WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular' 
                     ELSE 'New' 
                 END AS customer_segment
          FROM   customer_spending)
SELECT   customer_segment,
         count(customer_key) AS customer_count
FROM     customer_class
GROUP BY customer_segment 
ORDER BY customer_count DESC;