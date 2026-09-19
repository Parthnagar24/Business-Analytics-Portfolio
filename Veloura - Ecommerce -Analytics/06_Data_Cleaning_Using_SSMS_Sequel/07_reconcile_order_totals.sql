-- Check how many orders currently disagree, before fixing
WITH recomputed AS (
    SELECT
        o.order_id,
        o.order_total_amount AS current_total,
        (SUM(od.total_price) - o.discount_amount + o.shipping_charge) AS correct_total
    FROM clean.orders o
    INNER JOIN clean.order_details od ON o.order_id = od.order_id
    GROUP BY o.order_id, o.order_total_amount, o.discount_amount, o.shipping_charge
)
SELECT COUNT(*) AS mismatched_orders_before_fix
FROM recomputed
WHERE ABS(current_total - correct_total) > 0.01;  -- allow tiny rounding tolerance

-- Apply the fix
WITH recomputed AS (
    SELECT
        o.order_id,
        (SUM(od.total_price) - o.discount_amount + o.shipping_charge) AS correct_total
    FROM clean.orders o
    INNER JOIN clean.order_details od ON o.order_id = od.order_id
    GROUP BY o.order_id, o.discount_amount, o.shipping_charge
)
UPDATE o
SET o.order_total_amount = r.correct_total
FROM clean.orders o
INNER JOIN recomputed r ON o.order_id = r.order_id
WHERE ABS(o.order_total_amount - r.correct_total) > 0.01;
GO

-- Verify: should now return 0
WITH recomputed AS (
    SELECT
        o.order_id,
        o.order_total_amount AS current_total,
        (SUM(od.total_price) - o.discount_amount + o.shipping_charge) AS correct_total
    FROM clean.orders o
    INNER JOIN clean.order_details od ON o.order_id = od.order_id
    GROUP BY o.order_id, o.order_total_amount, o.discount_amount, o.shipping_charge
)
SELECT COUNT(*) AS mismatched_orders_after_fix
FROM recomputed
WHERE ABS(current_total - correct_total) > 0.01;
