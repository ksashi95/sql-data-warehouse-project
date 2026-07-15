/*
-- ------------------------------------------------------------------------
-- IV. measure exploration : ∑ [measure]
-- ------------------------------------------------------------------------

Purpose: Calculate core KPIs including Total Sales, Total Quantity, Average Price, 
Total Orders, Total Products, and Total Customers.

*/
-- 1. find the total sales
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- 2. find how many items are sold
SELECT SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- 3. find the average selling price
SELECT AVG(price) AS average_price
FROM gold.fact_sales;

-- 4. find the total number of orders
SELECT 
COUNT(order_number) AS total_orders,
COUNT(DISTINCT(order_number)) AS total_distinct_orders
FROM gold.fact_sales;

-- 5. find the total number of products
SELECT COUNT(product_number) AS total_orders
FROM gold.dim_products;

SELECT COUNT(product_key) AS total_orders
FROM gold.dim_products;


SELECT COUNT(product_name) AS total_orders
FROM gold.dim_products;

-- 6. find the total number of customers
SELECT COUNT(customer_id) AS total_customers
FROM gold.dim_customers;

SELECT COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

-- 7. find the total number of customers that has placed an order
SELECT COUNT(DISTINCT (customer_key))
FROM   gold.fact_sales;

-- generate a report that shows all key metrics of the business


SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure_name, COUNT(DISTINCT(order_number)) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure_name, COUNT(DISTINCT(product_number)) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(customer_id) AS measure_value FROM gold.dim_customers;
