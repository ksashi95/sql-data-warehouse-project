# Data Warehouse and Analytics Project

## Modern Data Warehouse using SQL Server (Medallion Architecture)

This project demonstrates the implementation of a **Modern Data Warehouse** using **Microsoft SQL Server**, following the **Medallion Architecture**. The warehouse is organized into three logical layers - **Bronze**, **Silver**, and **Gold** - to efficiently manage the flow of data from raw ingestion to business-ready analytics.

### Database Initialization

This script performs the initial setup of the data warehouse by:

* Creating the **DataWarehouse** database.
* Creating three schemas that represent the Medallion Architecture:

  * **Bronze** - Stores raw data ingested directly from source systems with minimal or no transformations.
  * **Silver** - Stores cleansed, standardized, and transformed data ready for downstream processing.
  * **Gold** - Stores curated, business-level datasets designed for reporting, dashboards, and analytical workloads.

This layered architecture improves data quality, maintainability, scalability, and supports a clear separation between raw, processed, and presentation-ready data.
