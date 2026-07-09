/*
-- ====================================================
-- Gold Layer – Dimension and Fact View Creation
-- ====================================================

This script creates the Gold layer of the data warehouse by building analytical views from the cleaned Silver layer. 
It transforms and integrates customer, product, and sales data into a star schema consisting of two dimension views (dim_customers, dim_products) 
and one fact view (fact_sales).

*/
-- ====================================================
-- dim_customer: gold.dim_customers
-- ==================================================== 
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers
GO
  
CREATE VIEW gold.dim_customers  -- silver.crm_cust_info, silver.erp_cust_az12, silver.erp_loc_a101
AS
SELECT 
       ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
       ci.cst_id AS customer_id,
       ci.cst_key AS customer_number,
       ci.cst_firstname AS first_name,
       ci.cst_lastname AS last_name,
       la.cntry AS country,
       ci.cst_marital_status AS marital_status,
       CASE 
           WHEN ci.cst_gndr = 'n/a' THEN COALESCE (ca.GEN, 'n/a') 
           ELSE ci.cst_gndr 
           END AS gender,
       ca.BDATE AS birthdate,
       ci.cst_create_date AS create_date
FROM   silver.crm_cust_info AS ci
       LEFT OUTER JOIN silver.erp_cust_az12 AS ca
       ON ci.cst_key = ca.CID
       LEFT OUTER JOIN silver.erp_loc_a101 AS la
       ON ci.cst_key = la.CID;
GO

select * from gold.dim_customers;

GO

-- ====================================================
-- dim_products: gold.dim_products
-- ==================================================== 
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products
GO

  
CREATE VIEW gold.dim_products  --  silver.crm_prd_info, silver.erp_px_cat_g1v2
AS
SELECT 
       ROW_NUMBER() OVER (ORDER BY  pn.prd_start_dt, pn.prd_key) AS product_key,
       pn.prd_id AS product_id,
       pn.prd_key AS product_number,
       pn.prd_nm AS product_name,
       pn.cat_id AS category_id,
       pc.CAT AS category,
       pc.SUBCAT AS subcategory,
       pc.MAINTENANCE AS maintainance,
       pn.prd_cost AS cost,
       pn.prd_line AS product_line,
       pn.prd_start_dt AS start_date
FROM   silver.crm_prd_info AS pn
       LEFT OUTER JOIN
       silver.erp_px_cat_g1v2 AS pc
       ON pn.cat_id = pc.ID
WHERE  prd_end_dt IS NULL; -- filtered all historical data
GO

-- ====================================================
-- fact_sales: gold.fact_sales
-- ==================================================== 
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales
GO
  
CREATE VIEW gold.fact_sales
AS
SELECT sls_ord_num AS order_number,
       pr.product_key,       -- dim_products surrogate key
       cu.customer_key,      -- dim_customers surrogate key
       sls_order_dt AS order_date,
       sls_ship_dt AS shipping_date,
       sls_due_dt AS due_date,
       sls_sales AS sales_amount,
       sls_quantity AS quantity,
       sls_price AS price
FROM   silver.crm_sales_details AS sd
LEFT OUTER JOIN gold.dim_products AS pr
ON sd.sls_prd_key = pr.product_number
LEFT OUTER JOIN gold.dim_customers AS cu
ON sd.sls_cust_id = cu.customer_id;
GO
