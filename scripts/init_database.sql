/*
================================
Database Initialization
================================
Script purpose:
This script creates the **DataWarehouse** database and sets up the `Bronze`, `Silver`, and `Gold` schemas based on the Medallion Architecture, 
providing the foundation for the data warehouse.

*/

USE master;
GO
  
-- create a database named DataWarehouse
CREATE DATABASE DataWarehouse;

-- use the database DataWarehouse
USE DataWarehouse;

-- create Schemas
-- Uses the GO command to separate SQL batches, ensuring each schema is created successfully.
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

