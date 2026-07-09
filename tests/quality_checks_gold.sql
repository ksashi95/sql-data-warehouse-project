/*
---------------------------------
** Gold Layer Quality Checks
---------------------------------
This script performs data quality validation on the Gold layer by verifying the integrity of the dimension and fact views. 
It checks for duplicate records after joins, validates data standardization, confirms successful key mappings between fact and dimension tables, 
and verifies that the final Gold views are complete and ready for reporting and analytics.
*/


USE DataWarehouse;

-- check for duplicates after joining

select cst_key,count(*)
from
(SELECT ci.cst_id,
       ci.cst_key,
       ci.cst_firstname,
       ci.cst_lastname,
       ci.cst_marital_status,
       CASE 
        WHEN ci.cst_gndr = 'n/a' THEN COALESCE (ca.GEN, 'n/a') 
        ELSE ci.cst_gndr 
        END AS gender,
       ci.cst_create_date,
       ca.BDATE,
       la.cntry
FROM   silver.crm_cust_info AS ci
LEFT OUTER JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.CID
LEFT OUTER JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.CID) t
GROUP BY cst_key
HAVING COUNT(*) > 1


-- -------------------------------------------------
-- standardizing gender column
SELECT
       ci.cst_gndr,
       ca.GEN,
       case when ci.cst_gndr = 'n/a' then coalesce(ca.GEN,'n/a')
       else ci.cst_gndr
       end as gender
     
FROM   silver.crm_cust_info AS ci
LEFT OUTER JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.CID
LEFT OUTER JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.CID


--  ----------------------
  
SELECT DISTINCT ci.cst_marital_status
FROM   silver.crm_cust_info AS ci
LEFT OUTER JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.CID
LEFT OUTER JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.CID;


-- ------------------------

select * from silver.crm_prd_info;
select * from silver.erp_px_cat_g1v2;

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


-- ------------------------

SELECT *
FROM   silver.crm_sales_details;

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



SELECT * FROM   gold.fact_sales;

SELECT * FROM   gold.dim_customers;

SELECT * FROM   gold.dim_products;
