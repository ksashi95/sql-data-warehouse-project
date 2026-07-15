/*
-- -----------------------------------------------------------------------------------------
-- IV. Part-To-Whole Analysis : Analyse how an individual part is performing compared to 
--                              the overall, allowing us to understand which category has 
--                              the greatest impact on the business

--                    ([measure] / total[measure]) * 100 by [dimension]
-- -----------------------------------------------------------------------------------------
    Measure each product category's contribution to 
    overall sales using percentage-of-total calculations.
*/

-- 1. which categories contribute the most of overall sales?
WITH   category_sales
AS     
(
    SELECT   p.category,
             SUM(f.sales_amount) AS total_sales
    FROM     gold.fact_sales AS f
             LEFT OUTER JOIN gold.dim_products AS p
             ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT category,
       total_sales,
       SUM(total_sales) OVER () AS overall_sales,
       CONCAT(ROUND(CAST (total_sales AS FLOAT) / SUM(total_sales) OVER () * 100, 2),'%') AS contribution
FROM   category_sales
ORDER BY contribution DESC;

