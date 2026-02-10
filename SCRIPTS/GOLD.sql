USE DATABASE MY_PROJECT;
USE SCHEMA GOLD;

-- =============================================================================
-- Create Dimension: GOLD.DIM_CUSTOMERS
-- =============================================================================
CREATE OR REPLACE VIEW MY_PROJECT.GOLD.DIM_CUSTOMERS AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key, -- Surrogate key
    ci.cst_id                               AS customer_id,
    ci.cst_key                              AS customer_number,
    ci.cst_firstname                        AS first_name,
    ci.cst_lastname                         AS last_name,
    la.cntry                                AS country,
    ci.cst_marital_status                   AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is primary source
        ELSE COALESCE(ca.gen, 'n/a')               -- Fallback to ERP
    END                                     AS gender,
    ca.bdate                                AS birthdate,
    ci.cst_create_date                      AS create_date
FROM MY_PROJECT.SILVER.CRM_CUST_INFO ci
LEFT JOIN MY_PROJECT.SILVER.ERP_CUST_AZ12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN MY_PROJECT.SILVER.ERP_LOC_A101 la
    ON ci.cst_key = la.cid;

-- =============================================================================
-- Create Dimension: GOLD.DIM_PRODUCTS
-- =============================================================================
CREATE OR REPLACE VIEW MY_PROJECT.GOLD.DIM_PRODUCTS AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM MY_PROJECT.SILVER.CRM_PRD_INFO pn
LEFT JOIN MY_PROJECT.SILVER.ERP_PX_CAT_G1V2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Current products only

-- =============================================================================
-- Create Fact Table: GOLD.FACT_SALES
-- =============================================================================
CREATE OR REPLACE VIEW MY_PROJECT.GOLD.FACT_SALES AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,   -- Linking to Gold Dim
    cu.customer_key AS customer_key,  -- Linking to Gold Dim
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM MY_PROJECT.SILVER.CRM_SALES_DETAILS sd
LEFT JOIN MY_PROJECT.GOLD.DIM_PRODUCTS pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN MY_PROJECT.GOLD.DIM_CUSTOMERS cu
    ON sd.sls_cust_id = cu.customer_id;


    SELECT 
    country, 
    SUM(sales_amount) as total_revenue,
    COUNT(DISTINCT order_number) as total_orders
FROM MY_PROJECT.GOLD.FACT_SALES f
JOIN MY_PROJECT.GOLD.DIM_CUSTOMERS c ON f.customer_key = c.customer_key
GROUP BY 1
ORDER BY total_revenue DESC;