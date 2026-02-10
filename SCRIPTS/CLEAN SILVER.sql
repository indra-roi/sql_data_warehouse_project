CREATE OR REPLACE PROCEDURE MY_PROJECT.SILVER.LOAD_SILVER()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    v_start_time TIMESTAMP_NTZ;
    v_end_time TIMESTAMP_NTZ;
BEGIN
    v_start_time := CURRENT_TIMESTAMP();

    -------------------------------------------------------
    -- 1. CRM_CUST_INFO (Deduplication & Formatting)
    -------------------------------------------------------
    TRUNCATE TABLE MY_PROJECT.SILVER.CRM_CUST_INFO;
    INSERT INTO MY_PROJECT.SILVER.CRM_CUST_INFO (
        CST_ID, CST_KEY, CST_FIRSTNAME, CST_LASTNAME, 
        CST_MARITAL_STATUS, CST_GNDR, CST_CREATE_DATE
    )
    SELECT
        CST_ID, CST_KEY, TRIM(CST_FIRSTNAME), TRIM(CST_LASTNAME),
        CASE WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'S' THEN 'Single'
             WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'M' THEN 'Married'
             ELSE 'n/a' END,
        CASE WHEN UPPER(TRIM(CST_GNDR)) = 'F' THEN 'Female'
             WHEN UPPER(TRIM(CST_GNDR)) = 'M' THEN 'Male'
             ELSE 'n/a' END,
        CST_CREATE_DATE
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY CST_ID ORDER BY CST_CREATE_DATE DESC) as flag_last
        FROM MY_PROJECT.BRONZE.CRM_CUST_INFO
        WHERE CST_ID IS NOT NULL
    ) t WHERE flag_last = 1;

    -------------------------------------------------------
    -- 2. CRM_PRD_INFO (Fixed Date Math for Snowflake)
    -------------------------------------------------------
    TRUNCATE TABLE MY_PROJECT.SILVER.CRM_PRD_INFO;
    INSERT INTO MY_PROJECT.SILVER.CRM_PRD_INFO (
        PRD_ID, CAT_ID, PRD_KEY, PRD_NM, PRD_COST, PRD_LINE, PRD_START_DT, PRD_END_DT
    )
    SELECT
        PRD_ID,
        REPLACE(SUBSTRING(PRD_KEY, 1, 5), '-', '_'),
        SUBSTRING(PRD_KEY, 7, LEN(PRD_KEY)),
        PRD_NM, IFNULL(PRD_COST, 0),
        CASE WHEN UPPER(TRIM(PRD_LINE)) = 'M' THEN 'Mountain'
             WHEN UPPER(TRIM(PRD_LINE)) = 'R' THEN 'Road'
             WHEN UPPER(TRIM(PRD_LINE)) = 'S' THEN 'Other Sales'
             WHEN UPPER(TRIM(PRD_LINE)) = 'T' THEN 'Touring'
             ELSE 'n/a' END,
        PRD_START_DT::DATE,
        -- Corrected: Using DATEADD instead of minus sign
        DATEADD(day, -1, LEAD(PRD_START_DT) OVER (PARTITION BY PRD_KEY ORDER BY PRD_START_DT))
    FROM MY_PROJECT.BRONZE.CRM_PRD_INFO;

    -------------------------------------------------------
    -- 3. CRM_SALES_DETAILS (Safe Date Parsing)
    -------------------------------------------------------
    TRUNCATE TABLE MY_PROJECT.SILVER.CRM_SALES_DETAILS;
    INSERT INTO MY_PROJECT.SILVER.CRM_SALES_DETAILS (
        SLS_ORD_NUM, SLS_PRD_KEY, SLS_CUST_ID, SLS_ORDER_DT, 
        SLS_SHIP_DT, SLS_DUE_DT, SLS_SALES, SLS_QUANTITY, SLS_PRICE
    )
    SELECT 
        SLS_ORD_NUM, SLS_PRD_KEY, SLS_CUST_ID,
        -- TRY_TO_DATE is safer; it returns NULL instead of crashing if data is bad
        TRY_TO_DATE(NULLIF(SLS_ORDER_DT, 0)::VARCHAR, 'YYYYMMDD'),
        TRY_TO_DATE(NULLIF(SLS_SHIP_DT, 0)::VARCHAR, 'YYYYMMDD'),
        TRY_TO_DATE(NULLIF(SLS_DUE_DT, 0)::VARCHAR, 'YYYYMMDD'),
        CASE WHEN SLS_SALES IS NULL OR SLS_SALES <= 0 OR SLS_SALES != SLS_QUANTITY * ABS(SLS_PRICE) 
             THEN SLS_QUANTITY * ABS(SLS_PRICE) ELSE SLS_SALES END,
        SLS_QUANTITY,
        CASE WHEN SLS_PRICE IS NULL OR SLS_PRICE <= 0 
             THEN SLS_SALES / NULLIF(SLS_QUANTITY, 0) ELSE SLS_PRICE END
    FROM MY_PROJECT.BRONZE.CRM_SALES_DETAILS;

    -------------------------------------------------------
    -- 4. ERP_LOC_A101 (Standardization)
    -------------------------------------------------------
    TRUNCATE TABLE MY_PROJECT.SILVER.ERP_LOC_A101;
    INSERT INTO MY_PROJECT.SILVER.ERP_LOC_A101 (CID, CNTRY)
    SELECT REPLACE(CID, '-', ''),
        CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
             WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
             WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
             ELSE TRIM(CNTRY) END
    FROM MY_PROJECT.BRONZE.ERP_LOC_A101;

    v_end_time := CURRENT_TIMESTAMP();
    RETURN 'Silver Layer Load Completed Successfully.';

EXCEPTION
    WHEN OTHER THEN
        RETURN 'Error: ' || sqlerrm;
END;
$$;
CALL MY_PROJECT.SILVER.LOAD_SILVER();