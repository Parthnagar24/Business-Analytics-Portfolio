-- ================================
-- PART B: PRODUCT-LEVEL ANALYSIS (ranked within each category)
-- ================================
 
WITH Product_Made_Refund_History AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(o.quantity * o.unit_price) AS Revenue_made,
        SUM(o.quantity) AS Quantity_Sold,
        SUM(r.return_amount) AS Revenue_Refunded,
        SUM(CASE WHEN r.return_id IS NOT NULL THEN o.quantity ELSE 0 END) AS Quantity_Returned
    FROM clean.order_details AS o
    INNER JOIN clean.products AS p
        ON p.product_id = o.product_id
    LEFT JOIN clean.returns AS r
        ON r.order_details_id = o.order_details_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
CTE_RANKING AS (
    SELECT
        *,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY Revenue_Refunded DESC) AS Rank_Refund_Wise,
        (CAST(Quantity_Returned AS DECIMAL(10,2)) / Quantity_Sold) * 100 AS Return_Rate,
        (CAST(Revenue_Refunded AS DECIMAL(12,2)) / Revenue_made) * 100 AS Loss_Percentage,
        (Revenue_made - Revenue_Refunded) AS Net_Revenue
    FROM Product_Made_Refund_History
)
SELECT *
FROM CTE_RANKING
-- WHERE Rank_Refund_Wise <= 2      -- uncomment to get top-2 loss-driving products per category
ORDER BY category, Rank_Refund_Wise;