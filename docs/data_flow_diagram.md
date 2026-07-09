### Data Flow Diagram


                                    
```text                                    
                                    
                                    SOURCE SYSTEMS
┌──────────────────────────────┐      ┌──────────────────────────────┐
│          CRM System          │      │          ERP System          │
├──────────────────────────────┤      ├──────────────────────────────┤
│ crm_cust_info                │      │ erp_cust_az12               │
│ crm_prd_info                 │      │ erp_loc_a101                │
│ crm_sales_details            │      │ erp_px_cat_g1v2             │
└──────────────┬───────────────┘      └──────────────┬───────────────┘
               │                                     │
               └─────────────── Extract & Load ──────┘
                               │
                               ▼

══════════════════════════════════════════════════════════════════════════
                           🥉 BRONZE LAYER (Raw Data)
══════════════════════════════════════════════════════════════════════════

bronze.crm_cust_info
bronze.crm_prd_info
bronze.crm_sales_details
bronze.erp_loc_a101
bronze.erp_cust_az12
bronze.erp_px_cat_g1v2

                               │
                  Clean • Validate • Standardize
                  Remove Duplicates • Data Quality
                               │
                               ▼

══════════════════════════════════════════════════════════════════════════
                         🥈 SILVER LAYER (Clean Data)
══════════════════════════════════════════════════════════════════════════

silver.crm_cust_info
silver.crm_prd_info
silver.crm_sales_details
silver.erp_loc_a101
silver.erp_cust_az12
silver.erp_px_cat_g1v2

        │                         │                        │
        │                         │                        │
        │                         │                        │
        ▼                         ▼                        ▼

gold.dim_customers      gold.dim_products        gold.fact_sales
      ▲                       ▲                        ▲
      │                       │                        │
      │                       │                        │
┌───────────────┐      ┌───────────────┐      ┌────────────────────┐
│crm_cust_info  │      │crm_prd_info   │      │crm_sales_details   │
│erp_cust_az12  │      │erp_px_cat_g1v2│      └────────────────────┘
│erp_loc_a101   │      └───────────────┘
└───────────────┘

══════════════════════════════════════════════════════════════════════════
                     🥇 GOLD LAYER (Business Ready)
══════════════════════════════════════════════════════════════════════════

                    FactSales
                         │
          ┌──────────────┴──────────────┐
          │                             │
     DimCustomers                  DimProducts
          │                             │
          └──────────────┬──────────────┘
                         │
                         ▼
                  Power BI Dashboard
               Reports • KPIs • Analytics
```
