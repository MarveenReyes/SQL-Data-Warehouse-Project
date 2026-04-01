-- ======================================================
-- Gold Layer Views (Analytics-Ready Schema)
-- Purpose: The Gold Layer provides analytics-ready dimensional tables 
--          by combining and enriching data from the Silver Layer.
--          It delivers a business-friendly star schema optimized for 
--          reporting, dashboards, and analytical queries.
-- ======================================================


-- ======================================================
-- DIMENSION: Customers
-- Combines CRM and ERP customer attributes, resolves gender inconsistencies,
-- and enriches with demographic/location data.
-- ======================================================
CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id          AS customer_id,
    ci.cst_key         AS customer_number,
    ci.cst_firstname   AS first_name,
    ci.cst_lastname    AS last_name,
    la.cntry           AS country,
    ci.cst_marital_status AS marital_status,

    -- Gender resolved using CRM first; fallback to ERP if missing
    CASE 
        WHEN ci.cst_gender != 'Unknown' THEN ci.cst_gender
        ELSE COALESCE(ca.gen, 'N/A')
    END AS gender,

    ca.bdate           AS birth_date,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la 
    ON ci.cst_key = la.cid;



-- ======================================================
-- DIMENSION: Products
-- Builds a product dimension enriched with ERP category data.
-- Excludes historical versions by keeping only current product records.
-- ======================================================
CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS sub_category,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn 
LEFT JOIN silver.erp_px_cat_g1v2 pc 
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;   -- keep only active products



-- ======================================================
-- FACT: Sales
-- Creates a sales fact table linking orders to customers and products.
-- Provides cleaned dates, normalized revenue, and foreign keys to dimensions.
-- ======================================================
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS ship_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
