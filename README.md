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


**Note:** I built this project to learn and practice **SQL, data analysis, data warehousing, and ETL**. I followed the original SQL portfolio project by **Data With Baraa** as a guide, but I completed the implementation myself and learned a lot throughout the process. Huge thanks to **Data With Baraa** for creating such an awesome learning resource!


##### YouTube: [Data With Baraa - SQL Data Warehouse Portfolio Project](https://youtube.com/playlist?list=PLNcg_FV9n7qaUWeyUkPfiVtMbKlrfMqA8&si=2aHCvmFrloR-fEqO)
