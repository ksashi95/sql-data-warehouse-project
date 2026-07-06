/*
===============================================
** DDL Script – Bronze Layer Table Creation
===============================================

This script creates the raw tables for the Bronze layer of the data warehouse. Before creating each table, 
it checks whether the table already exists and drops it to ensure a clean and consistent deployment.

The tables are designed to store data from the CRM and ERP source systems without applying any transformations, 
preserving the original structure of the source files.

----------------------------------------------
*** Key Features:
----------------------------------------------

* Uses IF OBJECT_ID to check for existing tables.
* Drops existing tables before recreation to ensure repeatable deployments.
* Creates tables under the bronze schema.
* Defines the initial data structure required for raw data ingestion.
* Serves as the foundation for subsequent ETL processes into the Silver and Gold layers.  
=======================================================================================================
*/


-- create table customer info

-- <schema>.<sourcesystem>_<entity>

/* 
Drop the bronze.crm_cust_info table if it already exists

IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
*/

IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
cst_id INT,
cst_key	NVARCHAR(50),
cst_firstname NVARCHAR(50),	
cst_lastname NVARCHAR(50),	
cst_marital_status NVARCHAR(50),	
cst_gndr NVARCHAR(50),	
cst_create_date DATE
);


-- create table product info
IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
prd_id	INT,
prd_key	VARCHAR(50),
prd_nm	VARCHAR(50),
prd_cost INT,	
prd_line VARCHAR(50),	
prd_start_dt DATETIME,
prd_end_dt DATETIME
);


-- create table sales details
IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
sls_ord_num	NVARCHAR(50),
sls_prd_key	NVARCHAR(50),
sls_cust_id	INT,
sls_order_dt INT,	
sls_ship_dt	INT,
sls_due_dt	INT,
sls_sales	INT,
sls_quantity INT,	
sls_price INT
);




-- create table erp_loc_a101
IF OBJECT_ID ('bronze.erp_loc_a101','U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
CID	NVARCHAR(50),
CNTRY NVARCHAR(50)
);


-- create table erp_cust_az12
IF OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
CID	NVARCHAR(50),
BDATE DATE,
GEN NVARCHAR(50)
);


-- create table erp_px_cat_g1v2
IF OBJECT_ID ('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
ID	NVARCHAR(50),
CAT	NVARCHAR(50),
SUBCAT NVARCHAR(50),
MAINTENANCE NVARCHAR(50)
);
