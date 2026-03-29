-- ===========================================================
-- silver Layer: Table Creation Script
-- Repository: sql-data-warehouse-project
-- Author: Marveen Renard Reyes
-- Date: 2026-03-27
-- ===========================================================
-- Purpose:
--   This script creates the silver layer tables in the data warehouse.
--   The silver layer stores raw, minimally processed data from
--   source systems (CRM and ERP). It acts as the foundational
--   layer for subsequent Silver (cleansed) and Gold (analytics-ready)
--   layers.
-- ===========================================================

-- =============================
-- CRM SOURCE TABLES
-- =============================

-- Drop and create silver.crm_cust_info
DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(100),
    cst_lastname       VARCHAR(100),
    cst_marital_status VARCHAR(20),
    cst_gender         VARCHAR(10),
    cst_create_date    DATE,
	dwh_create_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drop and create silver.crm_prd_info
DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id        INT,
	cat_id        VARCHAR(50),
    prd_key       VARCHAR(50),
    prd_nm        VARCHAR(200),
    prd_cost      NUMERIC(10,2),
    prd_line      VARCHAR(50),
    prd_start_dt  DATE,
    prd_end_dt    DATE,
	dwh_create_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drop and create silver.crm_sales_details
DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num    VARCHAR(50),
    sls_prd_key    VARCHAR(50),
    sls_cust_id    INT,
    sls_order_dt   DATE,
    sls_ship_dt    DATE,
    sls_due_dt     DATE,
    sls_sales      INT,
    sls_quantity   INT,
    sls_price      INT,
	dwh_create_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================
-- ERP SOURCE TABLES
-- =============================

-- Drop and create silver.erp_cust_az12
DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
    CID   		   VARCHAR(50),
    BDATE          DATE,
    GEN    	       VARCHAR(50),
	dwh_create_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drop and create silver.erp_loc_a101
DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    CID   		   VARCHAR(50),
    CNTRY    	   VARCHAR(50),
	dwh_create_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drop and create silver.erp_px_cat_g1v2
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
    ID   		   VARCHAR(50),
    CAT            VARCHAR(50),
    SUBCAT    	   VARCHAR(50),
    MAINTENANCE    VARCHAR(50),
	dwh_create_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================================
-- End of silver Layer Table Creation Script
-- ===========================================================
