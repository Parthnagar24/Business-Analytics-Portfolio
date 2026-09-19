
IF OBJECT_ID('clean.products', 'U') IS NOT NULL DROP TABLE clean.products;

SELECT
    TRY_CAST(product_id AS INT)                AS product_id,
    LTRIM(RTRIM(product_name))                 AS product_name,
    UPPER(LEFT(LTRIM(RTRIM(category)), 1)) + LOWER(SUBSTRING(LTRIM(RTRIM(category)), 2, LEN(category))) AS category,
    LTRIM(RTRIM(brand))                        AS brand,
    TRY_CAST(cost_price AS DECIMAL(10,2))      AS cost_price,
    TRY_CAST(selling_price AS DECIMAL(10,2))   AS selling_price,
    TRY_CAST(stock_quantity AS INT)            AS stock_quantity,
    CASE
        WHEN launch_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
            THEN CONVERT(date, launch_date, 23)
        WHEN launch_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
            THEN CONVERT(date, REPLACE(launch_date, '/', '-'), 23)
        WHEN launch_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
            THEN CONVERT(date, SUBSTRING(launch_date,7,4)+'-'+SUBSTRING(launch_date,1,2)+'-'+SUBSTRING(launch_date,4,2), 23)
        WHEN launch_date LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
            THEN CONVERT(date, SUBSTRING(launch_date,7,4)+'-'+SUBSTRING(launch_date,4,2)+'-'+SUBSTRING(launch_date,1,2), 23)
        WHEN launch_date LIKE '[0-9][0-9] [A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9][0-9]'
            THEN CONVERT(date, launch_date, 106)
        ELSE NULL
    END AS launch_date
INTO clean.products
FROM staging.products;
GO

ALTER TABLE clean.products ALTER COLUMN product_id INT NOT NULL;
ALTER TABLE clean.products ADD CONSTRAINT PK_clean_products PRIMARY KEY (product_id);
GO

SELECT COUNT(*) AS clean_product_count FROM clean.products;  -- expect 55
