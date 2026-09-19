/*
"Which promotions are profitable vs. losing money after discount?"
*/


WITH Baseline AS (
    -- average order value for orders placed WITHOUT any promotion
    -- this is the "what would revenue normally look like" yardstick
    SELECT AVG(o.order_total_amount) AS Baseline_AOV
    FROM clean.orders o
    WHERE o.promotion_id IS NULL
),
Promotion_Stats AS (
    -- per-promotion performance
    SELECT
        p.promotion_id,
        p.promotion_name,
        p.promotion_type,
        p.discount_percentage,
        COUNT(o.order_id)                     AS Orders_Count,
        SUM(o.order_total_amount)             AS Revenue_With_Promotion,
        AVG(o.order_total_amount)             AS Avg_Order_Value_With_Promotion,
        SUM(o.discount_amount)                AS Total_Discount_Given,
        AVG(o.discount_amount)                AS Avg_Discount_Per_Order
    FROM clean.promotions p
    INNER JOIN clean.orders o
        ON o.promotion_id = p.promotion_id
    GROUP BY
        p.promotion_id,
        p.promotion_name,
        p.promotion_type,
        p.discount_percentage
)
SELECT
    ps.promotion_id,
    ps.promotion_name,
    ps.promotion_type,
    ps.discount_percentage,
    ps.Orders_Count,
    ps.Revenue_With_Promotion,
    ps.Avg_Order_Value_With_Promotion,
    b.Baseline_AOV,
    (ps.Avg_Order_Value_With_Promotion - b.Baseline_AOV) AS Gain_Per_Order_Vs_Baseline,
    ps.Total_Discount_Given,
    ps.Avg_Discount_Per_Order,
    -- Net Profitability per order = extra value the promo generated MINUS what was given away in discount
    ((ps.Avg_Order_Value_With_Promotion - b.Baseline_AOV) - ps.Avg_Discount_Per_Order) AS Net_Profitability_Per_Order,
    CASE
        WHEN ((ps.Avg_Order_Value_With_Promotion - b.Baseline_AOV) - ps.Avg_Discount_Per_Order) > 0
            THEN 'Profitable'
        ELSE 'Loss-Making'
    END AS Verdict
FROM Promotion_Stats ps
CROSS JOIN Baseline b   -- Baseline is a single row, applies to every promotion the same way
ORDER BY Net_Profitability_Per_Order DESC;
 