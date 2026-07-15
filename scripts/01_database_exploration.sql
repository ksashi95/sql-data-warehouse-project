/*
-- ------------------------------------------------------------------------
-- I.Database Structure Exploration 
-- ------------------------------------------------------------------------

Purpose: Explore tables, columns, and metadata to understand 
the database structure before analysis. 
Example: INFORMATION_SCHEMA.TABLES, INFORMATION_SCHEMA.COLUMNS.
*/

--  explore all objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES;


-- explore all columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';	
