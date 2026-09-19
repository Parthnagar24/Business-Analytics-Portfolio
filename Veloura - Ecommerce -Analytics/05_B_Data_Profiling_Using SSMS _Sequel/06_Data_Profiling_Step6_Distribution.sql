

-- 6A. ORDER_DETAILS: quantity, unit_price, total_price
SELECT
    COUNT(*) AS total_rows,
    AVG(TRY_CAST(quantity AS DECIMAL(10,2))) AS avg_quantity,
    MIN(TRY_CAST(quantity AS DECIMAL(10,2))) AS min_quantity,
    MAX(TRY_CAST(quantity AS DECIMAL(10,2))) AS max_quantity,
    AVG(TRY_CAST(unit_price AS DECIMAL(10,2))) AS avg_unit_price,
    MIN(TRY_CAST(unit_price AS DECIMAL(10,2))) AS min_unit_price,
    MAX(TRY_CAST(unit_price AS DECIMAL(10,2))) AS max_unit_price,
    AVG(TRY_CAST(total_price AS DECIMAL(10,2))) AS avg_total_price,
    MIN(TRY_CAST(total_price AS DECIMAL(10,2))) AS min_total_price,
    MAX(TRY_CAST(total_price AS DECIMAL(10,2))) AS max_total_price
FROM staging.order_details;

-- Median needs PERCENTILE_CONT separately (can't mix with plain aggregates as easily)
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TRY_CAST(total_price AS DECIMAL(10,2)))
        OVER () AS median_total_price
FROM staging.order_details
WHERE TRY_CAST(total_price AS DECIMAL(10,2)) IS NOT NULL;


-- 6B. ORDERS: discount_amount, shipping_charge, order_total_amount
SELECT
    COUNT(*) AS total_rows,
    AVG(TRY_CAST(order_total_amount AS DECIMAL(10,2))) AS avg_order_total,
    MIN(TRY_CAST(order_total_amount AS DECIMAL(10,2))) AS min_order_total,
    MAX(TRY_CAST(order_total_amount AS DECIMAL(10,2))) AS max_order_total,
    AVG(TRY_CAST(discount_amount AS DECIMAL(10,2))) AS avg_discount,
    MAX(TRY_CAST(discount_amount AS DECIMAL(10,2))) AS max_discount,
    AVG(TRY_CAST(shipping_charge AS DECIMAL(10,2))) AS avg_shipping
FROM staging.orders;

SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TRY_CAST(order_total_amount AS DECIMAL(10,2)))
        OVER () AS median_order_total
FROM staging.orders
WHERE TRY_CAST(order_total_amount AS DECIMAL(10,2)) IS NOT NULL;


-- 6C. PRODUCTS: cost_price, selling_price, stock_quantity (by category, since price ranges differ a lot)
SELECT
    category,
    COUNT(*) AS product_count,
    AVG(TRY_CAST(cost_price AS DECIMAL(10,2))) AS avg_cost_price,
    AVG(TRY_CAST(selling_price AS DECIMAL(10,2))) AS avg_selling_price,
    MIN(TRY_CAST(selling_price AS DECIMAL(10,2))) AS min_selling_price,
    MAX(TRY_CAST(selling_price AS DECIMAL(10,2))) AS max_selling_price
FROM staging.products
GROUP BY category
ORDER BY category;


-- 6D. REVIEWS: rating distribution (should be skewed toward 4-5, not flat)
SELECT
    TRY_CAST(rating AS INT) AS rating_value,
    COUNT(*) AS row_count
FROM staging.reviews
GROUP BY TRY_CAST(rating AS INT)
ORDER BY rating_value;


-- 6E. PROMOTIONS: discount_percentage spread
SELECT
    COUNT(*) AS total_rows,
    AVG(TRY_CAST(discount_percentage AS DECIMAL(5,2))) AS avg_discount_pct,
    MIN(TRY_CAST(discount_percentage AS DECIMAL(5,2))) AS min_discount_pct,
    MAX(TRY_CAST(discount_percentage AS DECIMAL(5,2))) AS max_discount_pct
FROM staging.promotions;


-- 6F. OUTLIER CHECK using IQR method (order_total_amount as example)
-- Any value beyond Q1 - 1.5*IQR or Q3 + 1.5*IQR is a statistical outlier.
WITH quartiles AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TRY_CAST(order_total_amount AS DECIMAL(10,2))) OVER () AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TRY_CAST(order_total_amount AS DECIMAL(10,2))) OVER () AS Q3
    FROM staging.orders
    WHERE TRY_CAST(order_total_amount AS DECIMAL(10,2)) IS NOT NULL
)
SELECT
    o.order_id,
    TRY_CAST(o.order_total_amount AS DECIMAL(10,2)) AS order_total,
    q.Q1, q.Q3, (q.Q3 - q.Q1) AS IQR
FROM staging.orders o
CROSS JOIN quartiles q
WHERE TRY_CAST(o.order_total_amount AS DECIMAL(10,2)) < q.Q1 - 1.5 * (q.Q3 - q.Q1)
   OR TRY_CAST(o.order_total_amount AS DECIMAL(10,2)) > q.Q3 + 1.5 * (q.Q3 - q.Q1);