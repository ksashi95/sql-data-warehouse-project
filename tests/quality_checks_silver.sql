/*
-------------------------------------
** Data Quality Checks
-------------------------------------
This script contains the data quality validation queries used before loading data into the **Silver** layer. 
The queries profile the Bronze data, identify data quality issues, and verify that transformations produce clean and consistent records.

-------------------------------------
** Validation Checks
-------------------------------------

* Detect duplicate records and validate primary keys.
* Identify unwanted leading and trailing spaces.
* Standardize categorical values for consistency.
* Validate and convert data types.
* Detect missing, null, negative, or invalid values.
* Verify date formats and logical date relationships.
* Validate referential integrity between related tables.
* Recalculate and verify sales and pricing values.
* Ensure transformed data meets the business rules defined for the Silver layer.
* Compare Bronze and Silver data to confirm successful data cleansing and transformation. 

*/


USE DataWarehouse;

-- ==========================================================================================================================
-- crm_cust_info
-- ==========================================================================================================================




SELECT TOP 100 *
FROM bronze.crm_cust_info;

SELECT *
FROM silver.crm_cust_info;

SELECT count(*)
FROM silver.crm_cust_info

SELECT count(*)
FROM bronze.crm_cust_info




-- check for duplicates in primary key cst_id

SELECT *
FROM   (SELECT *,
               Row_number()
                 OVER (
                   partition BY cst_id
                   ORDER BY cst_create_date DESC) AS flag_last
        FROM   bronze.crm_cust_info) t
WHERE  flag_last = 1; 


-- check for unwanted spaces

select cst_firstname
from bronze.crm_cust_info
where cst_firstname <> trim(cst_firstname)


select cst_lastname
from bronze.crm_cust_info
where cst_lastname <> trim(cst_lastname)

select cst_marital_status
from bronze.crm_cust_info
where cst_marital_status <> trim(cst_marital_status)


select cst_gndr
from bronze.crm_cust_info
where cst_gndr <> trim(cst_gndr)

select 
    cst_id,
    cst_key,trim(cst_firstname) as cst_firstname,
    trim(cst_lastname) as cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
from bronze.crm_cust_info;



-- data standardization and consistency

select distinct(cst_marital_status)
from bronze.crm_cust_info;

select distinct(cst_gndr)
from bronze.crm_cust_info;



-- ==========================================================================================================================
-- crm_prd_info
-- ==========================================================================================================================
INSERT INTO silver.crm_prd_info
            (prd_id,
             cat_id,
             prd_key,
             prd_nm,
             prd_cost,
             prd_line,
             prd_start_dt,
             prd_end_dt)
SELECT prd_id,
       Replace(Substring(prd_key, 1, 5), '-', '_')  AS cat_id,
       Substring(prd_key, 7, Len(prd_key))          AS prd_key,
       prd_nm,
       COALESCE(prd_cost, 0)                        AS prd_cost,
       CASE Upper(Trim(prd_line))
         WHEN 'm' THEN 'Mountain'
         WHEN 'r' THEN 'Road'
         WHEN 's' THEN 'Other Sales'
         WHEN 't' THEN 'Touring'
         ELSE 'n/a'
       END                                          AS prd_line,
       Cast(prd_start_dt AS DATE)                   prd_start_dt,
       Cast(Lead(prd_start_dt)
              OVER(
                partition BY prd_key
                ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info; 

-- ---------------------------------------------------------------------------------------------------------------------

select *
from bronze.crm_prd_info;



-- check duplicates
select prd_id, count(*)
from silver.crm_prd_info
group by prd_id
having count(*)>1 or prd_id is null;


  -- unwanted spaces
select prd_nm
from silver.crm_prd_info
where prd_nm <> trim(prd_nm);



-- check for nulls or negatives
select prd_cost
from  silver.crm_prd_info
where prd_cost is null or prd_cost<0;


select distinct prd_line 
from silver.crm_prd_info;

select *,
cast(prd_start_dt as date) prd_start_dt,
cast(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
from silver.crm_prd_info
where prd_end_dt < prd_start_dt

select
prd_start_dt,
prd_end_dt
from silver.crm_prd_info
where prd_end_dt < prd_start_dt;


-- ==========================================================================================================================
-- crm_sales_details
-- ==========================================================================================================================


SELECT TOP (20) [sls_ord_num],
                [sls_prd_key],
                [sls_cust_id],
                [sls_order_dt],
                [sls_ship_dt],
                [sls_due_dt],
                [sls_sales],
                [sls_quantity],
                [sls_price]
FROM   [DataWarehouse].silver.[crm_sales_details]
where sls_ord_num <> trim([sls_ord_num]);



SELECT TOP (20) [sls_ord_num],
                [sls_prd_key],
                [sls_cust_id],
                [sls_order_dt],
                [sls_ship_dt],
                [sls_due_dt],
                [sls_sales],
                [sls_quantity],
                [sls_price] -- clear
FROM   [DataWarehouse].silver.[crm_sales_details]
where [sls_cust_id] not in (select cst_id from silver.crm_cust_info);



SELECT TOP (20) [sls_ord_num],
                [sls_prd_key],
                [sls_cust_id],
                [sls_order_dt],
                [sls_ship_dt],
                [sls_due_dt],
                [sls_sales],
                [sls_quantity],
                [sls_price] -- clear
FROM   [DataWarehouse].silver.[crm_sales_details]
where [sls_prd_key] not in (select [sls_prd_key] from silver.crm_cust_info);


select sls_ord_num,
count(*)
from silver.crm_sales_details
group by sls_ord_num
having count(*) > 1;


select nullif(sls_ship_dt,0) sls_ship_dt
from silver.crm_sales_details
where sls_ship_dt <= 0 or 
len(sls_ship_dt) <> 8
or  sls_ship_dt < 1900101 or sls_ship_dt > 20500101;



select nullif(sls_order_dt,0) sls_order_dt
from silver.crm_sales_details
where sls_order_dt < 1900101 or sls_order_dt > 20500101;

select nullif(sls_ship_dt,0) sls_ship_dt
from bronze.crm_sales_details
where sls_ship_dt < 1900101 or sls_ship_dt > 20500101;

select nullif(sls_due_dt,0) sls_due_dt
from bronze.crm_sales_details
where sls_due_dt < 1900101 or sls_due_dt > 20500101;

SELECT *
FROM   silver.crm_sales_details
WHERE  (sls_order_dt > sls_ship_dt)
       OR (sls_order_dt > sls_due_dt); -- check for invalid order dates


SELECT sls_sales as old_sales,
       sls_quantity,
       sls_price as old_price,

       case when sls_sales is null or sls_sales <= 0 or sls_sales <> sls_quantity * abs(sls_price) then sls_quantity * abs(sls_price)
       else sls_sales
       end as sls_sales,

       case when sls_price is null or sls_price <= 0 then sls_sales/nullif(sls_quantity,0)
       else sls_price
       end as sls_price

FROM   silver.crm_sales_details
WHERE  sls_sales <> sls_quantity * sls_price
       OR sls_sales IS NULL
       OR sls_quantity IS NULL
       OR sls_price IS NULL
       OR sls_sales <= 0
       OR sls_price <= 0
       order by sls_sales, sls_quantity, sls_price;

       -- ------------------------------------------------

SELECT sls_ord_num,
       sls_prd_key,
       sls_cust_id,
       CASE WHEN sls_order_dt <= 0
                 OR len(sls_order_dt) <> 8 THEN NULL 
                 ELSE CAST (CAST (sls_order_dt AS VARCHAR) AS DATE) 
                 END AS sls_order_dt,

       CASE WHEN sls_ship_dt <= 0
                 OR len(sls_ship_dt) <> 8 THEN NULL 
                 ELSE CAST (CAST (sls_ship_dt AS VARCHAR) AS DATE) 
                 END AS sls_ship_dt,

       CASE WHEN sls_due_dt <= 0
                 OR len(sls_due_dt) <> 8 THEN NULL 
                 ELSE CAST (CAST (sls_due_dt AS VARCHAR) AS DATE) 
                 END AS sls_due_dt,

       CASE WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales <> sls_quantity * abs(sls_price) THEN sls_quantity * abs(sls_price) 
                 ELSE sls_sales 
                 END AS sls_sales,

       sls_quantity,

       CASE WHEN sls_price IS NULL
                 OR sls_price <= 0 THEN sls_sales / NULLIF (sls_quantity, 0) 
                 ELSE sls_price 
                 END AS sls_price
FROM   [DataWarehouse].[bronze].[crm_sales_details];

       -- ------------------------------------------------



select * from silver.crm_sales_details;

-- ----------------------------------------------------------------------------------------------


-- ==========================================================================================================================
-- erp_cust_az12
-- ==========================================================================================================================


SELECT 
    CASE 
    WHEN cid LIKE 'nas%' THEN SUBSTRING(cid, 4, len(cid))
    ELSE cid 
    END AS cid,

    CASE 
    WHEN BDATE > GETDATE()  THEN NULL 
    ELSE bdate 
    END AS bdate,

   CASE 
    WHEN trim(upper(gen)) IN ('F', 'female') THEN 'Female' 
    WHEN trim(upper(gen)) IN ('m', 'male') THEN 'Male' 
    ELSE 'n/a' 
    END AS gen
FROM   bronze.erp_cust_az12;

select * from bronze.erp_cust_az12

select BDATE from bronze.erp_cust_az12
where BDATE < '1924-01-01' or BDATE > GETDATE();

select distinct gen,
case when trim(upper(gen)) in ('F', 'female') then 'Female'
when trim(upper(gen)) in ('m','male') then 'Male'
else null
end as gen
from bronze.erp_cust_az12
;



SELECT *
FROM   silver.crm_cust_info;

-- ----------------------------------------------------------------------------------------------

-- ==========================================================================================================================
-- erp_loc_a101
-- ==========================================================================================================================


select CID,cntry from bronze.erp_loc_a101;

select * from silver.crm_cust_info

select  
REPLACE(cid,'-','') as cid,
from bronze.erp_loc_a101;

select  
REPLACE(cid,'-','') as cid
from bronze.erp_loc_a101
where REPLACE(cid,'-','') not in (select cst_key from silver.crm_cust_info);

select distinct cntry cntry_o,
case when trim(cntry) = 'de' then 'Germany'
when trim(cntry) in ('US','usa') then 'United States'
when trim(cntry) = '' or trim(cntry) is null then 'n/a'
else trim(cntry)
end as cntry
from bronze.erp_loc_a101
order by cntry;



SELECT REPLACE(cid, '-', '') AS cid,
       CASE 
        WHEN trim(cntry) = 'de' THEN 'Germany' 
        WHEN trim(cntry) IN ('US', 'usa') THEN 'United States' 
        WHEN trim(cntry) = '' OR trim(cntry) IS NULL THEN 'n/a' 
        ELSE trim(cntry) 
        END AS cntry
FROM   bronze.erp_loc_a101;

-- ----------------------------------------------------

-- ==========================================================================================================================
-- erp_px_cat_g1v2
-- ==========================================================================================================================

select * from bronze.erp_px_cat_g1v2;

select * from silver.crm_prd_info;

select *
from bronze.erp_px_cat_g1v2
where cat <>trim(cat)
or SUBCAT <> TRIM(subcat)
or MAINTENANCE <> trim(MAINTENANCE)


select distinct MAINTENANCE
from bronze.erp_px_cat_g1v2;
