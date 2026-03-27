-- ===========================================================
-- Bronze Layer: Table Creation Script
-- Repository: sql-data-warehouse-project
-- Author: Marveen Renard Reyes
-- Date: 2026-03-27
-- ===========================================================
-- Purpose:
--   This script creates the Bronze layer tables in the data warehouse.
--   The Bronze layer stores raw, minimally processed data from
--   source systems (CRM and ERP). It acts as the foundational
--   layer for subsequent Silver (cleansed) and Gold (analytics-ready)
--   layers.
-- ===========================================================

-- =============================
-- CRM SOURCE TABLES
-- =============================

-- Drop and create bronze.crm_cust_info
DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(100),
    cst_lastname       VARCHAR(100),
    cst_marital_status VARCHAR(20),
    cst_gender         VARCHAR(10),
    cst_create_date    DATE
);

-- Drop and create bronze.crm_prd_info
DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
    prd_id        INT,
    prd_key       VARCHAR(50),
    prd_nm        VARCHAR(200),
    prd_cost      NUMERIC(10,2),
    prd_line      VARCHAR(10),
    prd_start_dt  DATE,
    prd_end_dt    DATE
);

-- Drop and create bronze.crm_sales_details
DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num    VARCHAR(50),
    sls_prd_key    VARCHAR(50),
    sls_cust_id    INT,
    sls_order_dt   INT,
    sls_ship_dt    INT,
    sls_due_dt     INT,
    sls_sales      INT,
    sls_quantity   INT,
    sls_price      INT
);

-- =============================
-- ERP SOURCE TABLES
-- =============================

-- Drop and create bronze.erp_cust_az12
DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
    CID   		   VARCHAR(50),
    BDATE          DATE,
    GEN    	       VARCHAR(50)
);

-- Drop and create bronze.erp_loc_a101
DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
    CID   		   VARCHAR(50),
    CNTRY    	   VARCHAR(50)
);

-- Drop and create bronze.erp_px_cat_g1v2
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    ID   		   VARCHAR(50),
    CAT            VARCHAR(50),
    SUBCAT    	   VARCHAR(50),
    MAINTENANCE    VARCHAR(50)
);

-- ===========================================================
-- End of Bronze Layer Table Creation Script
-- ===========================================================
