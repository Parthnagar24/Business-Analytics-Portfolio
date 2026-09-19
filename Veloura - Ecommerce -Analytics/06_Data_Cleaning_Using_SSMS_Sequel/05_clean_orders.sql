
IF OBJECT_ID('clean.orders', 'U') IS NOT NULL DROP TABLE clean.orders;

SELECT
    TRY_CAST(o.order_id AS INT)                          AS order_id,
    COALESCE(m.canonical_id, TRY_CAST(o.customer_id AS INT)) AS customer_id,
    TRY_CAST(o.promotion_id AS INT)                      AS promotion_id,  -- NULL is valid (70% of orders)
    CASE
        WHEN o.order_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
            THEN CONVERT(date, o.order_date, 23)
        WHEN o.order_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
            THEN CONVERT(date, REPLACE(o.order_date, '/', '-'), 23)
        WHEN o.order_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
            THEN CONVERT(date, SUBSTRING(o.order_date,7,4)+'-'+SUBSTRING(o.order_date,1,2)+'-'+SUBSTRING(o.order_date,4,2), 23)
        WHEN o.order_date LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
            THEN CONVERT(date, SUBSTRING(o.order_date,7,4)+'-'+SUBSTRING(o.order_date,4,2)+'-'+SUBSTRING(o.order_date,1,2), 23)
        WHEN o.order_date LIKE '[0-9][0-9] [A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9][0-9]'
            THEN CONVERT(date, o.order_date, 106)
        ELSE NULL
    END AS order_date,
    CASE
        WHEN UPPER(LTRIM(RTRIM(o.order_status))) = 'DELIVERED' THEN 'Delivered'
        WHEN UPPER(LTRIM(RTRIM(o.order_status))) = 'CANCELLED' THEN 'Cancelled'
        ELSE LTRIM(RTRIM(o.order_status))
    END AS order_status,
    COALESCE(NULLIF(LTRIM(RTRIM(o.shipping_address)), ''), c.address) AS shipping_address,
    COALESCE(NULLIF(LTRIM(RTRIM(o.billing_address)), ''), c.address)  AS billing_address,
    TRY_CAST(o.discount_amount AS DECIMAL(10,2))         AS discount_amount,
    TRY_CAST(o.shipping_charge AS DECIMAL(10,2))         AS shipping_charge,
    TRY_CAST(o.order_total_amount AS DECIMAL(10,2))      AS order_total_amount  -- reconciled in Script 6
INTO clean.orders
FROM staging.orders o
LEFT JOIN clean.customer_id_map m ON TRY_CAST(o.customer_id AS INT) = m.old_id
LEFT JOIN clean.customers c ON COALESCE(m.canonical_id, TRY_CAST(o.customer_id AS INT)) = c.customer_id;
GO

ALTER TABLE clean.orders ALTER COLUMN order_id INT NOT NULL;
ALTER TABLE clean.orders ADD CONSTRAINT PK_clean_orders PRIMARY KEY (order_id);
ALTER TABLE clean.orders ADD CONSTRAINT FK_orders_customers FOREIGN KEY (customer_id) REFERENCES clean.customers(customer_id);
ALTER TABLE clean.orders ADD CONSTRAINT FK_orders_promotions FOREIGN KEY (promotion_id) REFERENCES clean.promotions(promotion_id);
GO

SELECT COUNT(*) AS clean_order_count FROM clean.orders;  -- expect 52855
