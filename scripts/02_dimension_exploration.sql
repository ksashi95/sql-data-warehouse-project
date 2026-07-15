/*
-- ------------------------------------------------------------------------
-- II.Dimensions exploration : DISTINCT [dimension]
-- ------------------------------------------------------------------------

Purpose: Identify unique business dimensions such as countries, categories, 
subcategories, and product names for segmentation and reporting.

*/
SELECT DISTINCT country
FROM   gold.dim_customers;


SELECT DISTINCT category, subcategory, product_name
FROM   gold.dim_products
ORDER BY category, subcategory, product_name;