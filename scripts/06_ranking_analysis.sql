/*
-- -----------------------------------------------------------------------------------
-- VI. ranking analysis - order the values of dimension based on a measure 
--                        inorder to identify TOP N /BOTTOM N performers

--                        RANK[dimension] by ∑ [measure]
-- -----------------------------------------------------------------------------------

Purpose: Identify top-performing products, bottom-performing products, 
highest-value customers,and customers with the fewest orders using TOP and RANK() window functions.
*/


-- 1. which products generate the highest revenue?
SELECT   TOP 5 
p.category,
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM     gold.fact_sales AS f
LEFT OUTER JOIN gold.dim_products AS p
ON f.product_key = p.product_key
GROUP BY p.category,p.product_name
ORDER BY total_revenue DESC;

-- using rank functions
SELECT *
FROM   (SELECT   p.product_name,
                 SUM(f.sales_amount) AS total_revenue,
                 RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS ranking
        FROM     gold.fact_sales AS f
                 LEFT OUTER JOIN
                 gold.dim_products AS p
                 ON f.product_key = p.product_key
        GROUP BY p.product_name) AS t
WHERE  ranking <= 5;
 

-- 2. what are the 5 worst performing products in terms of sales?

SELECT   TOP 5 
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM     gold.fact_sales AS f
LEFT OUTER JOIN gold.dim_products AS p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- using rank functions
SELECT *
FROM   (SELECT   product_name,
                 SUM(sales_amount) AS total_revenue,
                 RANK() OVER (ORDER BY SUM(sales_amount) ASC) AS ranking
        FROM     gold.fact_sales AS f
                 LEFT OUTER JOIN
                 gold.dim_products AS p
                 ON f.product_key = p.product_key
        GROUP BY product_name) AS t
WHERE  ranking <= 5;


-- 3. find the top 10 customers who have generated the highest revenue
-- (a) handles ties and ordered
SELECT   *  
FROM     (SELECT   c.first_name,
                   c.last_name,
                   SUM(sales_amount) AS total_revenue,
                   RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS ranking
          FROM     gold.fact_sales AS f
                   LEFT OUTER JOIN
                   gold.dim_customers AS c
                   ON f.customer_key = c.customer_key
          GROUP BY c.first_name, c.last_name) AS t
WHERE    ranking <= 10
ORDER BY ranking;

--  
-- (b) handles ties and unordered
SELECT *   
FROM   (SELECT   c.first_name,
                 c.last_name,
                 SUM(sales_amount) AS total_revenue,
                 RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS ranking
        FROM     gold.fact_sales AS f
                 LEFT OUTER JOIN
                 gold.dim_customers AS c
                 ON f.customer_key = c.customer_key
        GROUP BY c.first_name, c.last_name) AS t
WHERE  ranking <= 10;

-- 
-- (c) does not handle ties and is ordered
SELECT   TOP 10 c.first_name, 
                c.last_name,
                SUM(sales_amount) AS total_revenue
FROM     gold.fact_sales AS f
         LEFT OUTER JOIN
         gold.dim_customers AS c
         ON f.customer_key = c.customer_key
GROUP BY c.first_name, c.last_name
ORDER BY total_revenue DESC;


-- 4. the 3 customers with fewer orders placed
SELECT  TOP 3 
        c.customer_key,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT (order_number)) AS total_orders
FROM     gold.fact_sales AS f
         LEFT JOIN
         gold.dim_customers AS c
         ON f.customer_key = c.customer_key
GROUP BY 
        c.customer_key,
        c.first_name, 
        c.last_name
ORDER BY total_orders;
