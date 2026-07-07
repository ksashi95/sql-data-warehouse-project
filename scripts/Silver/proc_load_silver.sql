/*
===========================================================
** Stored Procedure – Load Silver Layer
===========================================================

This stored procedure loads data from the **Bronze** layer into the **Silver** layer by applying data cleansing, validation, standardization, and enrichment rules. It performs a full refresh of the Silver tables by truncating existing data and inserting transformed records from the Bronze layer.

--------------------------------
** Key Features
--------------------------------

* Full refresh loading using `TRUNCATE TABLE`.
* Cleans and standardizes raw CRM and ERP data.
* Removes duplicates and handles missing or invalid values.
* Converts and validates data types.
* Enriches data using business rules and calculated fields.
* Logs execution time for monitoring.
* Includes `TRY...CATCH` error handling for reliable ETL execution.

*/

EXEC silver.load_silver;

CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '>> Loading the Silver layer tables';


        PRINT '>> Loading CRM tables';

        /*
        ------------------------------------------------------------------------------------------------------------
         Cleaning bronze.crm_cust_info Table and INSERTING into silver.crm_cust_info
        ------------------------------------------------------------------------------------------------------------
        */
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.crm_cust_info'
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>> Inserted data into : silver.crm_cust_info'
        INSERT INTO silver.crm_cust_info ( 
                cst_id,
                cst_key,
                cst_firstname,
                cst_lastname,
                cst_marital_status,
                cst_gndr,
                cst_create_date)

        SELECT cst_id,
                cst_key,
                Trim(cst_firstname) AS cst_firstname, -- removing unwanted spaces to ensure data consistency and uniformity
                Trim(cst_lastname)  AS cst_lastname,

                CASE
                    WHEN cst_marital_status = 's' THEN 'Single'  -- data standardization & norrmalization
                    WHEN cst_marital_status = 'm' THEN 'Married'
                    ELSE 'n/a'                                   -- handling missing values by a default
                END                 AS cst_marital_status,

                CASE
                    WHEN cst_gndr = 'F' THEN 'Female'  -- data standardization & norrmalization
                    WHEN cst_gndr = 'm' THEN 'Male'    -- handling missing values by a default
                    ELSE 'n/a'
                END                 AS cst_gndr,

                cst_create_date
        FROM   (SELECT *,
                        Row_number()                -- removed duplicates in primary key
                            OVER (
                            partition BY cst_id
                            ORDER BY cst_create_date DESC) AS flag_last  
                FROM   bronze.crm_cust_info
                WHERE cst_id IS NOT NULL) t
        WHERE  flag_last = 1; 

        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_____________________________________'

        /*
        -----------------------------------------------------------------------------------------------------------
            Cleaning bronze.crm_prd_info Table and INSERTING into silver.crm_prd_info
        ------------------------------------------------------------------------------------------------------------
        */
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>> Inserted data into : silver.crm_prd_info';
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
                Replace(Substring(prd_key, 1, 5), '-', '_')  AS cat_id,    -- new columns created
                Substring(prd_key, 7, Len(prd_key))          AS prd_key,
                prd_nm,
                COALESCE(prd_cost, 0)                        AS prd_cost,  -- replaced null with 0
                CASE Upper(Trim(prd_line))                                 -- data standardization & norrmalization
                    WHEN 'm' THEN 'Mountain'
                    WHEN 'r' THEN 'Road'
                    WHEN 's' THEN 'Other Sales'
                    WHEN 't' THEN 'Touring'
                    ELSE 'n/a'
                END                                          AS prd_line,  -- map product line to descriptive values
                Cast(prd_start_dt AS DATE)                   prd_start_dt, -- data type casting
                Cast(Lead(prd_start_dt)                                    -- data enrichment and type casting                      
                        OVER(
                        partition BY prd_key
                        ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
        FROM bronze.crm_prd_info; 

        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_____________________________________'


        /*
        -----------------------------------------------------------------------------------------------------------
            Cleaning bronze.crm_sales_details Table and INSERTING into silver.crm_sales_details
        ------------------------------------------------------------------------------------------------------------
        */
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>> Inserted data into : silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details ( 
                sls_ord_num,
                sls_prd_key,
                sls_cust_id,
                sls_order_dt,
                sls_ship_dt,
                sls_due_dt,
                sls_sales,
                sls_quantity,
                sls_price
        )
        SELECT sls_ord_num,
                sls_prd_key,
                sls_cust_id,
                CASE WHEN sls_order_dt <= 0 OR len(sls_order_dt) <> 8 THEN NULL -- handling invalid data
                    ELSE CAST (CAST (sls_order_dt AS VARCHAR) AS DATE)  -- data type casting
                    END AS sls_order_dt,

                CASE WHEN sls_ship_dt <= 0 OR len(sls_ship_dt) <> 8 THEN NULL -- handling invalid data
                    ELSE CAST (CAST (sls_ship_dt AS VARCHAR) AS DATE)   -- data type casting
                    END AS sls_ship_dt,

                CASE WHEN sls_due_dt <= 0 OR len(sls_due_dt) <> 8 THEN NULL -- handling invalid data
                    ELSE CAST (CAST (sls_due_dt AS VARCHAR) AS DATE)   -- data type casting
                    END AS sls_due_dt,

                CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> sls_quantity * abs(sls_price) 
                        THEN sls_quantity * abs(sls_price) -- handling missing and invalid data to recalculate sales
                    ELSE sls_sales 
                    END AS sls_sales,

                sls_quantity,

                CASE WHEN sls_price IS NULL OR sls_price <= 0 
                        THEN sls_sales / NULLIF (sls_quantity, 0) 
                    ELSE sls_price -- handling missing and invalid data to derive price
                    END AS sls_price
        FROM [bronze].[crm_sales_details];

        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_____________________________________'


        /*
        -----------------------------------------------------------------------------------------------------------
            Cleaning bronze.crm_sales_details Table and INSERTING into silver.erp_cust_az12
        ------------------------------------------------------------------------------------------------------------
        */
        PRINT '>> Loading CRM tables'
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>> Inserted data into : silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12(
        CID,
        BDATE,
        GEN
        )
        SELECT 
            CASE 
            WHEN CID LIKE 'nas%' THEN SUBSTRING(CID, 4, len(CID)) -- removed prefix 'NAS'
            ELSE CID 
            END AS CID,

            CASE 
            WHEN BDATE > GETDATE()  THEN NULL  -- converted dates older than current date to NULL
            ELSE BDATE 
            END AS BDATE,

            CASE 
            WHEN trim(upper(GEN)) IN ('F', 'female') THEN 'Female' -- data standardization
            WHEN trim(upper(GEN)) IN ('m', 'male') THEN 'Male' 
            ELSE 'n/a' 
            END AS GEN
        FROM   bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_____________________________________'

        /*
        -----------------------------------------------------------------------------------------------------------
            Cleaning bronze.crm_sales_details Table and INSERTING into silver.erp_loc_a101
        ------------------------------------------------------------------------------------------------------------
        */
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>> Inserted data into : silver.erp_loc_a101';
        INSERT into silver.erp_loc_a101(
        CID,
        CNTRY)

        SELECT REPLACE(cid, '-', '') AS cid,    -- replaced '-' with empty string
                CASE 
                WHEN trim(cntry) = 'de' THEN 'Germany' 
                WHEN trim(cntry) IN ('US', 'usa') THEN 'United States' 
                WHEN trim(cntry) = '' OR trim(cntry) IS NULL THEN 'n/a' 
                ELSE trim(cntry) 
                END AS cntry -- data standardization
        FROM   bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_____________________________________'


        /*
        -----------------------------------------------------------------------------------------------------------
            Cleaning bronze.crm_sales_details Table and INSERTING into silver.erp_px_cat_g1v2
        ------------------------------------------------------------------------------------------------------------
        */
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>> Inserted data into : silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (
        ID, 
        CAT, 
        SUBCAT, 
        MAINTENANCE)

        SELECT ID,
                CAT,
                SUBCAT,
                MAINTENANCE
        FROM   bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');

        SET @batch_end_time = GETDATE();
        PRINT CONCAT('Loading Silver layer is completed',CHAR(13)+CHAR(10),'Total duration: ',DATEDIFF(SECOND,@batch_start_time,@batch_end_time),' seconds')

    END TRY

    BEGIN CATCH
        PRINT '===============================================';
        PRINT 'Error occured during loading Silver layer';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==============================================='
    END CATCH
END
GO
