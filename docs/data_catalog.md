## Gold Layer Data Catalogue

#### Overview
The data catalogue provides a comprehensive overview of the Gold layer tables and their columns. 
It documents each column's name, data type, and business definition, enabling users to understand the structure, meaning, 
and intended use of the data for reporting and analytics.

-----------------------------------------------------------------------------------

##### 1. 'gold.dfact_sales'

Stores transactional sales records, including order details, quantities, prices, and sales amounts. 
Linked to customer and product dimensions to enable analytical reporting and business intelligence.

| Column        | Data Type | Description                                                                         |
| ------------- | --------- | ----------------------------------------------------------------------------------- |
| order_number  | nvarchar  | Unique identifier assigned to each sales order.                                     |
| product_key   | bigint    | Surrogate key linking the sales record to the `gold.dim_products` dimension table.  |
| customer_key  | bigint    | Surrogate key linking the sales record to the `gold.dim_customers` dimension table. |
| order_date    | date      | Date when the sales order was placed.                                               |
| shipping_date | date      | Date when the order was shipped to the customer.                                    |
| due_date      | date      | Expected or scheduled delivery date for the order.                                  |
| sales_amount  | int       | Total sales amount for the order line.                                              |
| quantity      | int       | Number of units sold in the order line.                                             |
| price         | int       | Unit selling price of the product.                                                  |

-----------------------------------------------------------------------------------
##### 2. 'gold.dim_customers'

Stores customer master data by consolidating customer information from CRM and ERP systems. 
Used to analyze sales and customer-related metrics across various business dimensions.

| Column Name     | Data Type | Description                                                                                        |
| --------------- | --------- | -------------------------------------------------------------------------------------------------- |
| customer_key    | bigint    | Surrogate key generated for the customer dimension. Used as the primary key in the data warehouse. |
| customer_id     | int       | Unique customer identifier from the source CRM system.                                             |
| customer_number | nvarchar  | Alphanumeric business identifier assigned to each customer.                                        |
| first_name      | nvarchar  | Customer's first name.                                                                             |
| last_name       | nvarchar  | Customer's last name.                                                                              |
| country         | nvarchar  | Country where the customer resides.                                                                |
| marital_status  | nvarchar  | Customer's marital status (e.g., Single, Married).                                                 |
| gender          | nvarchar  | Customer's gender.                                                                                 |
| birthdate       | date      | Customer's date of birth.                                                                          |
| create_date     | date      | Date when the customer record was originally created in the source system.                         |

-----------------------------------------------------------------------------------
##### 3. 'gold.dim_products'

Stores product master data enriched with category and product attributes from CRM and ERP systems. 
Used to support product-based analysis and reporting.

| Column Name    | Data Type | Description                                                                                       |
| -------------- | --------- | ------------------------------------------------------------------------------------------------- |
| product_key    | bigint    | Surrogate key generated for the product dimension. Used as the primary key in the data warehouse. |
| product_id     | int       | Unique product identifier from the source CRM system.                                             |
| product_number | nvarchar  | Alphanumeric business identifier assigned to each product.                                        |
| product_name   | nvarchar  | Name of the product.                                                                              |
| category_id    | nvarchar  | Unique identifier for the product category.                                                       |
| category       | nvarchar  | High-level classification of the product.                                                         |
| subcategory    | nvarchar  | More specific classification within the product category.                                         |
| maintenance    | nvarchar  | Indicates whether the product requires maintenance (Yes,No).                                      |
| cost           | int       | Standard or unit cost of the product.                                                             |
| product_line   | varchar   | Product line to which the product belongs (e.g., Road, Mountain).                        |
| start_date     | date      | Date when the product became available for sale or use.                                           |

