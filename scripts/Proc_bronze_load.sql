CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        ------------------------------------------------
        -- CRM TABLES
        ------------------------------------------------

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';


        ------------------------------------------------
        -- CRM CUSTOMER INFO
        ------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';

        INSERT INTO bronze.crm_cust_info
        SELECT *
        FROM dbo.cust_info;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> -------------';


        ------------------------------------------------
        -- CRM PRODUCT INFO
        ------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';

        INSERT INTO bronze.crm_prd_info
        SELECT *
        FROM dbo.prd_info;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> -------------';


        ------------------------------------------------
        -- CRM SALES DETAILS
        ------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';

        INSERT INTO bronze.crm_sales_details
        SELECT *
        FROM dbo.sales_details;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> -------------';


        ------------------------------------------------
        -- ERP TABLES
        ------------------------------------------------

        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';


        ------------------------------------------------
        -- ERP LOCATION
        ------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';

        INSERT INTO bronze.erp_loc_a101
        SELECT *
        FROM dbo.loc_a101;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> -------------';


        ------------------------------------------------
        -- ERP CUSTOMER AZ12
        ------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';

        INSERT INTO bronze.erp_cust_az12
        SELECT *
        FROM dbo.cust_az12;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> -------------';


        ------------------------------------------------
        -- ERP PRODUCT CATEGORY
        ------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

        INSERT INTO bronze.erp_px_cat_g1v2
        SELECT *
        FROM dbo.px_cat_g1v2;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> -------------';


        ------------------------------------------------
        -- COMPLETION
        ------------------------------------------------

        SET @batch_end_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';

        PRINT '   - Total Load Duration: '
            + CAST(
                DATEDIFF(
                    SECOND,
                    @batch_start_time,
                    @batch_end_time
                ) AS NVARCHAR
            )
            + ' seconds';

        PRINT '==========================================';

    END TRY

    BEGIN CATCH

        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: '
            + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: '
            + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';

    END CATCH
END;
