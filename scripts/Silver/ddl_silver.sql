/*
===============================================
** DDL Script – Silver Layer Table Creation
===============================================


This script creates the tables for the Silver layer of the data warehouse. Before creating each table, it checks whether the table already exists and drops it to ensure a clean and repeatable deployment.

The Silver layer stores cleansed, standardized, and transformed data that has been processed from the Bronze layer. In addition to preserving the business data, each table includes a dwh_create_date column to capture the timestamp when a record is loaded into the data warehouse, providing basic audit and data lineage capabilities.

----------------------------------------------
** Key Features
----------------------------------------------
* Uses IF OBJECT_ID to safely recreate existing tables.
* Creates tables under the silver schema.
* Supports cleansed and standardized data for downstream processing.
* Converts raw source data into appropriate SQL data types.
* Adds a dwh_create_date audit column with a default value of GETDATE() to record data load timestamps.
* Provides the trusted data foundation for the Gold layer and analytical reporting.
=======================================================================================================================
*/

IF OBJECT_ID ('silver.crm_cust_info','U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info(
cst_id INT,
cst_key	NVARCHAR(50),
cst_firstname NVARCHAR(50),	
cst_lastname NVARCHAR(50),	
cst_marital_status NVARCHAR(50),	
cst_gndr NVARCHAR(50),	
cst_create_date DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);


-- create table product info
IF OBJECT_ID ('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
prd_id INT,
cat_id NVARCHAR(50),
prd_key	NVARCHAR(50),
prd_nm	NVARCHAR(50),
prd_cost INT,	
prd_line VARCHAR(50),	
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);


-- create table sales details
IF OBJECT_ID ('silver.crm_sales_details','U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
sls_ord_num	NVARCHAR(50),
sls_prd_key	NVARCHAR(50),
sls_cust_id	INT,
sls_order_dt DATE,	
sls_ship_dt	DATE,
sls_due_dt	DATE,
sls_sales	INT,
sls_quantity INT,	
sls_price INT,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);


-- create table erp_cust_az12
IF OBJECT_ID ('silver.erp_cust_az12','U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12(
CID	NVARCHAR(50),
BDATE DATE,
GEN NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);



-- create table erp_loc_a101
IF OBJECT_ID ('silver.erp_loc_a101','U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101(
CID	NVARCHAR(50),
CNTRY NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);



-- create table erp_px_cat_g1v2
IF OBJECT_ID ('silver.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2(
ID	NVARCHAR(50),
CAT	NVARCHAR(50),
SUBCAT NVARCHAR(50),
MAINTENANCE NVARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);


