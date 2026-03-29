-- ======================================================
-- Silver Layer ETL Script (Cleaned)
-- Purpose: Transform and load data from Bronze to Silver schema
-- ======================================================
-- Description:
-- This script moves raw data from Bronze tables into Silver tables, 
-- applying cleaning, standardization, and deduplication to make the data 
-- analysis-ready. It handles CRM and ERP datasets.
--
-- Key Transformations:
-- CRM Customer: trim names, standardize gender/marital status, deduplicate by cst_id
-- CRM Product: clean product keys, default missing costs, standardize product lines, calculate end dates
-- CRM Sales: convert integer dates to DATE, fix missing/inconsistent sales and price
-- ERP Customer: clean CID, fix invalid birthdates, standardize gender
-- ERP Location: clean CID, standardize country names, handle missing values
-- ERP Product Category: load as-is from Bronze
--
-- How It Works:
-- - Truncates Silver tables before insert
-- - Uses SQL functions like TRIM, UPPER, COALESCE, CASE, LEAD, ROW_NUMBER
-- - Ensures cleaned, deduplicated, and standardized data
--
-- Notes:
-- - Bronze tables must be preloaded
-- - Safe to rerun as Silver tables are truncated first
-- - Invalid dates or missing values are handled automatically
-- ======================================================
CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    row_count INT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    duration INTERVAL;
    silver_start_time TIMESTAMP;
    silver_end_time TIMESTAMP;
    silver_duration INTERVAL;
BEGIN

		-- Single try/catch block for the entire procedure
	    BEGIN
		silver_start_time := clock_timestamp();  -- start timestamp for entire Bronze layer
	
		
	-- ======================================================
	-- Load CRM Customer Data (bronze → silver)
	-- Removes duplicates, trims names, standardizes marital status and gender
	-- ======================================================
		start_time := clock_timestamp();  -- start timestamp for this table
		TRUNCATE TABLE silver.crm_cust_info;
		
		INSERT INTO silver.crm_cust_info (
		    cst_id,
		    cst_key,
		    cst_firstname,
		    cst_lastname,
		    cst_marital_status,
		    cst_gender,
		    cst_create_date
		)
		SELECT 
		    cst_id,
		    cst_key,
		    trim(cst_firstname) AS cst_firstname,
		    trim(cst_lastname) AS cst_lastname,
		    CASE 
		        WHEN upper(trim(cst_marital_status)) = 'S' THEN 'Single'
		        WHEN upper(trim(cst_marital_status)) = 'M' THEN 'Married'
		        ELSE 'Unknown'
		    END AS cst_marital_status,
		    CASE 
		        WHEN upper(trim(cst_gender)) = 'M' THEN 'Male'
		        WHEN upper(trim(cst_gender)) = 'F' THEN 'Female'
		        ELSE 'Unknown'
		    END AS cst_gender,
		    cst_create_date
		FROM (
		    SELECT *,
		           ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		    FROM bronze.crm_cust_info
		    WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1;
		
		SELECT COUNT(*) INTO row_count FROM silver.crm_cust_info;
		end_time := clock_timestamp();  -- end timestamp for this table
	        duration := end_time - start_time;
	        RAISE NOTICE '=== CRM: silver.crm_cust_info finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);
		
		-- ======================================================
		-- Load CRM Product Data (bronze → silver)
		-- Cleans product keys, sets default cost, and standardizes product lines
		-- ======================================================
		start_time := clock_timestamp();  -- start timestamp for this table
	
		TRUNCATE TABLE silver.crm_prd_info;
		
		INSERT INTO silver.crm_prd_info(
		    prd_id,
		    cat_id,
		    prd_key,
		    prd_nm,
		    prd_cost,
		    prd_line,
		    prd_start_dt,
		    prd_end_dt
		)
		SELECT 
		    prd_id,
		    replace(substring(prd_key, 1, 5), '-', '_') AS cat_id,
		    substring(prd_key, 7, length(prd_key)) AS prd_key,
		    prd_nm,
		    coalesce(prd_cost, 0) AS prd_cost,
		    CASE UPPER(TRIM(prd_line))
		        WHEN 'M' THEN 'Mountain'
		        WHEN 'R' THEN 'Road'
		        WHEN 'S' THEN 'Other Sales'
		        WHEN 'T' THEN 'Touring'
		        ELSE 'N/A'
		    END AS prd_line,
		    cast(prd_start_dt AS date) AS prd_start_dt,
		    cast(lead(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS date) AS prd_end_dt
		FROM bronze.crm_prd_info;
	
		SELECT COUNT(*) INTO row_count FROM silver.crm_prd_info;
		end_time := clock_timestamp();  -- end timestamp for this table
	    duration := end_time - start_time;
	    RAISE NOTICE '=== CRM: silver.crm_prd_info finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);
		
		
		-- ======================================================
		-- Load CRM Sales Details (bronze → silver)
		-- Converts integers to proper dates, calculates missing sales/price
		-- ======================================================
		start_time := clock_timestamp();  -- start timestamp for this table
		TRUNCATE TABLE silver.crm_sales_details;
		
		INSERT INTO silver.crm_sales_details(
		    sls_ord_num,
		    sls_prd_key,
		    sls_cust_id,
		    sls_order_dt,
		    sls_ship_dt,
		    sls_due_dt,
		    sls_sales,
		    sls_quantity,
		    sls_price
		)
		SELECT 
		    sls_ord_num,
		    sls_prd_key,
		    sls_cust_id,
		    CASE 
		        WHEN sls_order_dt = 0 OR length(sls_order_dt::text) != 8 THEN NULL
		        ELSE to_date(sls_order_dt::text, 'YYYYMMDD')
		    END AS sls_order_dt,
		    CASE 
		        WHEN sls_ship_dt = 0 OR length(sls_ship_dt::text) != 8 THEN NULL
		        ELSE to_date(sls_ship_dt::text, 'YYYYMMDD')
		    END AS sls_ship_dt,
		    CASE 
		        WHEN sls_due_dt = 0 OR length(sls_due_dt::text) != 8 THEN NULL
		        ELSE to_date(sls_due_dt::text, 'YYYYMMDD')
		    END AS sls_due_dt,
		    CASE 
		        WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != abs(sls_price) * sls_quantity
		        THEN sls_quantity * abs(sls_price)
		        ELSE sls_sales
		    END AS sls_sales,
		    sls_quantity,
		    CASE 
		        WHEN sls_price IS NULL OR sls_price <= 0
		        THEN sls_sales / nullif(sls_quantity, 0)
		        ELSE sls_price
		    END AS sls_price
		FROM bronze.crm_sales_details;
	
		SELECT COUNT(*) INTO row_count FROM silver.crm_sales_details;
		end_time := clock_timestamp();  -- end timestamp for this table
	    duration := end_time - start_time;
	    RAISE NOTICE '=== CRM: silver.crm_sales_details finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);
		
		
		-- ======================================================
		-- Load ERP Customer Data (bronze → silver)
		-- Cleans CID, removes future dates, standardizes gender
		-- ======================================================
		start_time := clock_timestamp();  -- start timestamp for this table
	
		TRUNCATE TABLE silver.erp_cust_az12;
		
		INSERT INTO silver.erp_cust_az12 (
		    cid,
		    bdate,
		    gen
		)
		SELECT 
		    CASE 
		        WHEN cid LIKE 'NAS%' THEN substring(cid, 4, length(cid))
		        ELSE cid
		    END AS cid,
		    CASE 
		        WHEN bdate > now() THEN NULL
		        ELSE bdate
		    END AS bdate,
		    CASE 
		        WHEN upper(trim(gen)) IN ('F', 'FEMALE') THEN 'Female'
		        WHEN upper(trim(gen)) IN ('M', 'MALE') THEN 'Male'
		        ELSE 'N/A'
		    END AS gen
		FROM bronze.erp_cust_az12;
	
		SELECT COUNT(*) INTO row_count FROM silver.erp_cust_az12;
		end_time := clock_timestamp();  -- end timestamp for this table
	    duration := end_time - start_time;
	    RAISE NOTICE '=== ERP: silver.erp_cust_az12 finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);
		
		-- ======================================================
		-- Load ERP Location Data (bronze → silver)
		-- Cleans CID, standardizes country names
		-- ======================================================
		start_time := clock_timestamp();  -- start timestamp for this table
		TRUNCATE TABLE silver.erp_loc_a101;
		
		INSERT INTO silver.erp_loc_a101 (
		    cid,
		    cntry
		)
		SELECT
		    replace(cid, '-', '') AS cid,
		    CASE 
		        WHEN trim(upper(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
		        WHEN trim(upper(cntry)) = 'DE' THEN 'Germany'
		        WHEN cntry IS NULL OR trim(cntry) = '' THEN 'N/A'
		        ELSE trim(cntry)
		    END AS cntry
		FROM bronze.erp_loc_a101;
	
		SELECT COUNT(*) INTO row_count FROM silver.erp_loc_a101;
		end_time := clock_timestamp();  -- end timestamp for this table
	    duration := end_time - start_time;
	    RAISE NOTICE '=== ERP: silver.erp_loc_a101 finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);
		
		
		-- ======================================================
		-- Load ERP Product Category Data (bronze → silver)
		-- Direct load from Bronze, no transformations needed
		-- ======================================================
		start_time := clock_timestamp();  -- start timestamp for this table
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		
		INSERT INTO silver.erp_px_cat_g1v2 (
		    id,
		    cat,
		    subcat,
		    maintenance
		)
		SELECT
		    id,
		    cat,
		    subcat,
		    maintenance
		FROM bronze.erp_px_cat_g1v2;
	
		SELECT COUNT(*) INTO row_count FROM silver.erp_px_cat_g1v2;
		end_time := clock_timestamp();  -- end timestamp for this table
	    duration := end_time - start_time;
	    RAISE NOTICE '=== ERP: silver.erp_px_cat_g1v2 finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);
	
		-- Bronze layer summary
	        silver_end_time := clock_timestamp();
	        silver_duration := silver_end_time - silver_start_time;
	        RAISE NOTICE '=== All silver tables finished loading successfully ===';
	        RAISE NOTICE '=== Silver Layer finished in % seconds ===', EXTRACT(EPOCH FROM silver_duration);
	
	    EXCEPTION
	        WHEN OTHERS THEN
	            -- Catch all errors during procedure execution
	            RAISE NOTICE '*** ERROR during silver.load_silver execution: %', SQLERRM;
	
	    END; -- big try/catch block


END;
$$;
