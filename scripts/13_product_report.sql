/*
-- -----------------------------------------------------------------------------
-- PRODUCT REPORT:
-- -----------------------------------------------------------------------------
purpose : this report consolidates key metrics and behaviours

Highlights :
1. gather essential fields such as product name,category, and cost
2. segments products by revenue to identify High-performers, Mid_range or Low-performers.
3. aggregates product level metrics:
	- total orders
	- total sales
	- total quantity sold
	- total products
	- lifespan (in months)
4. calculate valuable KPIs:
	- recency (months since last order)
	- average order revenue (AOR)
	- average monthly revenue
*/

DROP VIEW IF EXISTS gold.product_report
GO
CREATE VIEW gold.product_report AS
WITH   base_query
AS     
(SELECT 
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        f.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
FROM   gold.fact_sales AS f
LEFT OUTER JOIN gold.dim_products AS p
ON f.product_key = p.product_key
WHERE  order_date IS NOT NULL
),
-- product aggregation
product_aggregation
AS    
(SELECT   
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT (order_number)) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity_sold,
        COUNT(DISTINCT (product_key)) AS total_products,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT(customer_key)) AS total_customers,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)),1) AS average_selling_price
FROM     base_query
GROUP BY product_key, 
         product_name,
         category,
         subcategory,
         cost)

SELECT product_key,
       product_name,
       category,
       subcategory,
       cost,
       last_sale_date,
       DATEDIFF(MONTH,last_sale_date,GETDATE()) AS recency_in_months,
       -- product segment
       CASE 
        WHEN total_sales >= 50000 THEN 'High Performance'
        WHEN total_sales >= 10000 THEN 'Mid Range'
        ELSE 'Low Performance'
       END AS product_segment,

       total_orders,
       total_sales,
       total_quantity_sold,
       total_customers,
       lifespan,
       average_selling_price,

       -- Average Order Revenue (AOR)
       CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales/total_orders  
       END AS avg_order_revenue,

       -- Average Montly Revenue
       CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales/lifespan
       END AS avg_monthly_revenue
FROM   product_aggregation;
GO


SELECT * FROM gold.product_report;