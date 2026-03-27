-- ===========================================================
-- Bronze Layer: Load Procedure Script
-- Repository: sql-data-warehouse-project
-- Author: Marveen Renard Reyes
-- Date: 2026-03-27
-- ===========================================================
-- Purpose:
--   This procedure loads raw CSV data into the Bronze layer tables
--   in the data warehouse. The Bronze layer stores minimally processed
--   data directly from source systems (CRM and ERP).
--
-- How it works:
--   1. Uses a single try/catch block to capture any errors during execution.
--   2. Tracks start and end timestamps per table to measure load duration.
--   3. For each table:
--        - Truncates the table (removes existing data).
--        - Loads data from a CSV file using the COPY command.
--        - Counts the number of rows inserted.
--        - Calculates and displays load duration in seconds.
--        - Displays a notice with the source system (CRM/ERP), table name,
--          row count, and duration.
--   4. After all tables are loaded, displays a summary notice with total
--      Bronze layer load duration.
--   5. If any error occurs, displays a notice with the error message.
-- ===========================================================

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    row_count INT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    duration INTERVAL;
    bronze_start_time TIMESTAMP;
    bronze_end_time TIMESTAMP;
    bronze_duration INTERVAL;
BEGIN

    -- Single try/catch block for the entire procedure
    BEGIN
        bronze_start_time := clock_timestamp();  -- start timestamp for entire Bronze layer

        -- =============================
        -- CRM SOURCE TABLES
        -- =============================

        -- Load crm_cust_info
        start_time := clock_timestamp();  -- start timestamp for this table
        TRUNCATE TABLE bronze.crm_cust_info;
        COPY bronze.crm_cust_info(
            cst_id, cst_key, cst_firstname, cst_lastname,
            cst_marital_status, cst_gender, cst_create_date
        )
        FROM 'C:/IBS 6/IBS6 Project/Baraa SQL Warehouse Proj/sql-data-warehouse-project-main/datasets/source_crm/cust_info.csv'
        DELIMITER ',' CSV HEADER NULL '';
        SELECT COUNT(*) INTO row_count FROM bronze.crm_cust_info;
        end_time := clock_timestamp();  -- end timestamp for this table
        duration := end_time - start_time;
        RAISE NOTICE '=== CRM: bronze.crm_cust_info finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);

        -- Load crm_prd_info
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.crm_prd_info;
        COPY bronze.crm_prd_info(
            prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
        )
        FROM 'C:/IBS 6/IBS6 Project/Baraa SQL Warehouse Proj/sql-data-warehouse-project-main/datasets/source_crm/prd_info.csv'
        DELIMITER ',' CSV HEADER NULL '';
        SELECT COUNT(*) INTO row_count FROM bronze.crm_prd_info;
        end_time := clock_timestamp();
        duration := end_time - start_time;
        RAISE NOTICE '=== CRM: bronze.crm_prd_info finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);

        -- Load crm_sales_details
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.crm_sales_details;
        COPY bronze.crm_sales_details(
            sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt,
            sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
        )
        FROM 'C:/IBS 6/IBS6 Project/Baraa SQL Warehouse Proj/sql-data-warehouse-project-main/datasets/source_crm/sales_details.csv'
        DELIMITER ',' CSV HEADER NULL '';
        SELECT COUNT(*) INTO row_count FROM bronze.crm_sales_details;
        end_time := clock_timestamp();
        duration := end_time - start_time;
        RAISE NOTICE '=== CRM: bronze.crm_sales_details finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);

        -- =============================
        -- ERP SOURCE TABLES
        -- =============================

        -- Load erp_cust_az12
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.erp_cust_az12;
        COPY bronze.erp_cust_az12(CID, BDATE, GEN)
        FROM 'C:/IBS 6/IBS6 Project/Baraa SQL Warehouse Proj/sql-data-warehouse-project-main/datasets/source_erp/cust_az12.csv'
        DELIMITER ',' CSV HEADER NULL '';
        SELECT COUNT(*) INTO row_count FROM bronze.erp_cust_az12;
        end_time := clock_timestamp();
        duration := end_time - start_time;
        RAISE NOTICE '=== ERP: bronze.erp_cust_az12 finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);

        -- Load erp_loc_a101
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.erp_loc_a101;
        COPY bronze.erp_loc_a101(CID, CNTRY)
        FROM 'C:/IBS 6/IBS6 Project/Baraa SQL Warehouse Proj/sql-data-warehouse-project-main/datasets/source_erp/loc_a101.csv'
        DELIMITER ',' CSV HEADER NULL '';
        SELECT COUNT(*) INTO row_count FROM bronze.erp_loc_a101;
        end_time := clock_timestamp();
        duration := end_time - start_time;
        RAISE NOTICE '=== ERP: bronze.erp_loc_a101 finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);

        -- Load erp_px_cat_g1v2
        start_time := clock_timestamp();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        COPY bronze.erp_px_cat_g1v2(ID, CAT, SUBCAT, MAINTENANCE)
        FROM 'C:/IBS 6/IBS6 Project/Baraa SQL Warehouse Proj/sql-data-warehouse-project-main/datasets/source_erp/px_cat_g1v2.csv'
        DELIMITER ',' CSV HEADER NULL '';
        SELECT COUNT(*) INTO row_count FROM bronze.erp_px_cat_g1v2;
        end_time := clock_timestamp();
        duration := end_time - start_time;
        RAISE NOTICE '=== ERP: bronze.erp_px_cat_g1v2 finished (% rows) in % seconds ===', row_count, EXTRACT(EPOCH FROM duration);

        -- Bronze layer summary
        bronze_end_time := clock_timestamp();
        bronze_duration := bronze_end_time - bronze_start_time;
        RAISE NOTICE '=== All bronze tables finished loading successfully ===';
        RAISE NOTICE '=== Bronze Layer finished in % seconds ===', EXTRACT(EPOCH FROM bronze_duration);

    EXCEPTION
        WHEN OTHERS THEN
            -- Catch all errors during procedure execution
            RAISE NOTICE '*** ERROR during bronze.load_bronze execution: %', SQLERRM;

    END; -- big try/catch block

END;
$$;
