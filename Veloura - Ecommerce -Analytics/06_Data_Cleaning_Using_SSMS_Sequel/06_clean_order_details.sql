IF OBJECT_ID('clean.order_details', 'U') IS NOT NULL DROP TABLE clean.order_details;

WITH fixed AS (
    SELECT
        TRY_CAST(od.order_details_id AS INT) AS order_details_id,
        TRY_CAST(od.order_id AS INT)         AS order_id,
        TRY_CAST(od.product_id AS INT)       AS product_id,
        CASE
            WHEN TRY_CAST(od.quantity AS INT) IS NULL OR TRY_CAST(od.quantity AS INT) <= 0 THEN 1
            ELSE TRY_CAST(od.quantity AS INT)
        END AS quantity_fixed,
        COALESCE(TRY_CAST(od.unit_price AS DECIMAL(10,2)), p.selling_price) AS unit_price_fixed
    FROM staging.order_details od
    LEFT JOIN clean.products p ON TRY_CAST(od.product_id AS INT) = p.product_id
)
SELECT
    order_details_id,
    order_id,
    product_id,
    quantity_fixed                              AS quantity,
    unit_price_fixed                            AS unit_price,
    CAST(quantity_fixed * unit_price_fixed AS DECIMAL(10,2)) AS total_price
INTO clean.order_details
FROM fixed;
GO

ALTER TABLE clean.order_details ALTER COLUMN order_details_id INT NOT NULL;
ALTER TABLE clean.order_details ADD CONSTRAINT PK_clean_order_details PRIMARY KEY (order_details_id);
ALTER TABLE clean.order_details ADD CONSTRAINT FK_od_orders FOREIGN KEY (order_id) REFERENCES clean.orders(order_id);
ALTER TABLE clean.order_details ADD CONSTRAINT FK_od_products FOREIGN KEY (product_id) REFERENCES clean.products(product_id);
GO

SELECT COUNT(*) AS clean_order_details_count FROM clean.order_details;  -- expect 100273
