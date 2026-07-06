/*
===========================================================
** Stored Procedure – Load Bronze Layer
===========================================================

This stored procedure automates the ingestion of raw CRM and ERP data into the Bronze layer of the data warehouse. 
It performs a full reload by truncating each Bronze table and importing the latest data from CSV source files using BULK INSERT.

The procedure groups the loading process by source system (CRM and ERP), records execution time for each table, and logs the overall batch duration. 
It also includes structured error handling with a TRY...CATCH block to capture and report any issues encountered during execution.

--------------------------------
** Process Overview
--------------------------------
1. Starts the batch execution and records the start time.
2. Loads CRM source tables:
  * bronze.crm_cust_info
  bronze.crm_prd_info
  bronze.crm_sales_details
3. Loads ERP source tables:
  * bronze.erp_px_cat_g1v2
  * bronze.erp_loc_a101
  * bronze.erp_cust_az12
4. For each table:
  * Truncates existing records.
  * Imports data from the corresponding CSV file using BULK INSERT.
  * Measures and logs the table load duration.
5. Records the total execution time for the Bronze layer load.
6. Handles and reports any errors encountered during execution.

*/


CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '===============================================';
        PRINT 'Loading the bronze layer';
        PRINT '===============================================';

        PRINT '-----------------------------------------------';
        PRINT 'Loading CRM tables';
        PRINT '-----------------------------------------------';


        SET @start_time = GETDATE();
        -- Remove all existing records from the table
        PRINT '>>Truncating table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info

        -- Load data from the source CSV file into the Bronze table
        PRINT '>>Inserting Data into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\ashik\Downloads\DataWithBaraa\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,          -- Skip the header row
            FIELDTERMINATOR = ',', -- Columns are comma-separated
            TABLOCK                -- Improve bulk insert performance
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_______________'

        -- SELECT * FROM bronze.crm_cust_info;
        -- SELECT COUNT(*) FROM bronze.crm_cust_info;


        SET @start_time = GETDATE();
        PRINT '>>Truncating table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info

        PRINT '>>Inserting Data into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\ashik\Downloads\DataWithBaraa\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_______________'
        -- SELECT * FROM bronze.crm_prd_info;

        SET @start_time = GETDATE();

        PRINT '>>Truncating table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details

        PRINT '>>Inserting Data into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\ashik\Downloads\DataWithBaraa\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_______________'

        -- SELECT * FROM bronze.crm_sales_details;

        PRINT '-----------------------------------------------';
        PRINT 'Loading ERP tables';
        PRINT '-----------------------------------------------';


        SET @start_time = GETDATE();
        PRINT '>>Truncating table: bronze.erp_PX_CAT_G1V2';
        TRUNCATE TABLE bronze.erp_PX_CAT_G1V2

        PRINT '>>Inserting Data into: bronze.erp_PX_CAT_G1V2';
        BULK INSERT bronze.erp_PX_CAT_G1V2
        FROM 'C:\Users\ashik\Downloads\DataWithBaraa\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_______________'

        -- SELECT * FROM bronze.erp_PX_CAT_G1V2;


        SET @start_time = GETDATE();
        PRINT '>>Truncating table: bronze.erp_LOC_A101';
        TRUNCATE TABLE bronze.erp_LOC_A101

        PRINT '>>Inserting Data into: bronze.erp_LOC_A101';
        BULK INSERT bronze.erp_LOC_A101
        FROM 'C:\Users\ashik\Downloads\DataWithBaraa\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_______________'
        -- SELECT * FROM bronze.erp_LOC_A101;


        SET @start_time = GETDATE();
        PRINT '>>Truncating table: bronze.erp_CUST_AZ12';
        TRUNCATE TABLE bronze.erp_CUST_AZ12

        PRINT '>>Inserting Data into: bronze.erp_CUST_AZ12';
        BULK INSERT bronze.erp_CUST_AZ12
        FROM 'C:\Users\ashik\Downloads\DataWithBaraa\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT CONCAT('Load duration: ',DATEDIFF(SECOND,@start_time,@end_time),' seconds');
        PRINT '_______________'
        -- SELECT * FROM bronze.erp_CUST_AZ12;

        SET @batch_end_time = GETDATE();
        PRINT '_______________'
        PRINT CONCAT('Loading broze layer is completed',CHAR(13)+CHAR(10),'Total duration: ',DATEDIFF(SECOND,@batch_start_time,@batch_end_time),' seconds')
        PRINT '_______________'

    END TRY
    BEGIN CATCH
        PRINT '==============================================='
        PRINT 'Error occured during loading bronze layer'
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==============================================='
    END CATCH
END
GO

EXEC bronze.load_bronze;
