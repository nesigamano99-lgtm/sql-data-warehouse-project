
--- check nulls and duplicates
select cst_id, count(*) from bronze.crm_cust_info group by cst_id having count(*)>1 or cst_id is null;

select prd_id, count(*) from bronze.crm_prd_info group by prd_id having count(*)>1 or prd_id is null;

select sls_cust_id, count(*) from bronze.crm_sales_details group by sls_cust_id having count(*)>1 or sls_cust_id is null;

select * from bronze.crm_sales_details;


--- check unwanted spaces

select cst_firstname from bronze.crm_cust_info where cst_firstname != trim(cst_firstname) ;

select prd_nm from bronze.crm_prd_info where prd_nm != trim(prd_nm);

--- check cardinality

select distinct cst_marital_status from bronze.crm_cust_info;

select distinct cst_gndr from bronze.crm_cust_info;

select distinct sls_quantity from bronze.crm_sales_details;



-- cust info Data transformation and loading in silver table

insert into silver.crm_cust_info(
cst_id, cst_key, cst_firstname,cst_lastname, cst_marital_status, cst_gndr, cst_create_date)

select cst_id, cst_key, TRIM(cst_firstname) as cst_firstname, TRIM(cst_lastname) as cst_lastname,
case when Upper(cst_marital_status) ='M' then 'Married'
     when Upper(cst_marital_status) = 'S' then 'Single'
     else 'n/a'          -- normalize gender to readable format
End cst_marital_status,
case when Upper(cst_gndr) ='F' then 'Female'
     when Upper(cst_gndr) = 'M' then 'Male'
     else 'n/a'         -- normalize marital status to readable format
End cst_gndr,
cst_create_date
from
-- select most recent record per customer
(select *, ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as f from bronze.crm_cust_info)t where f=1;

--- id substring check 
select * from bronze.erp_px_cat_g1v2;

-- check for invalid date orders

select * from silver.crm_prd_info where prd_end_dt < prd_start_dt;

--- prd info Data transformation and loading into silver
insert into silver.crm_prd_info(prd_id, cat_id,prd_key,prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
select prd_id,  replace(substring(prd_key,1,5),'-', '_') as cat_id,
substring(prd_key,7, len(prd_key)) as prd_key,
prd_nm, isnull(prd_cost,0) as prd_cost,
case upper(trim(prd_line)) when 'M' then 'Mountain'
    when 'R' then 'Road'
    when 'S' then 'Other Sales'
    when 'T' then 'Touring'
    else 'n/a'
end prd_line,
prd_start_dt, lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) as prd_end_dt from bronze.crm_prd_info;
