----- script purpose: DDL Script: Create Gold Views as business ready dataset

--- dimention customer table
IF OBJECT_ID('gold.dimension_customer', 'V') IS NOT NULL
    DROP VIEW gold.dimension_customer;
GO

create view gold.dimension_customer as

select row_number() over (order by cst_id) as customer_key,

ci.cst_id as customer_id, ci.cst_key as customer_number,
ci.cst_firstname as customer_firstname, ci.cst_lastname as customer_lastname,
ci.cst_marital_status as Marital_status, ci.cst_gndr as gender, ci.cst_create_date as creation_date, 
case when ci.cst_gndr!='n/a' then ci.cst_gndr
		  else coalesce(csn.gen, 'n/a')
	end as newgen,
la.cntry as country
from 
silver.crm_cust_info ci left join silver.erp_cust_az12 csn on ci.cst_key = csn.cid
left join  silver.erp_loc_a101 la on ci.cst_key = la.cid;

go
--- create product dimension table
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
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
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Filter out all historical data


go


--- create fact tables;
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO


CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dimension_customer cu
    ON sd.sls_cust_id = cu.customer_id;

go
