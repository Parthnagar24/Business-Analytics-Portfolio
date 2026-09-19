/*
Revenue Leakage (Combined) — "Total ₹ revenue leakage across returns + 
bad promotions + churn."
*/


 
-- ================================
-- PART 1: RETURNS LEAKAGE (category-wise + grand total)
-- ================================
WITH Returns_By_Category AS (
    SELECT
        p.category,
        SUM(r.return_amount) AS Revenue_Refunded
    FROM clean.order_details AS o
    INNER JOIN clean.products AS p
        ON p.product_id = o.product_id
    LEFT JOIN clean.returns AS r
        ON r.order_details_id = o.order_details_id
    GROUP BY p.category
)
SELECT
    category,
    Revenue_Refunded,
    SUM(Revenue_Refunded) OVER () AS Total_Returns_Leakage   -- grand total repeated on every row for easy reading
FROM Returns_By_Category
ORDER BY Revenue_Refunded DESC;
 
 
-- ================================
-- PART 2: PROMOTIONS LEAKAGE (loss-making promotions only)
-- ================================
WITH Baseline AS (
    SELECT AVG(o.order_total_amount) AS Baseline_AOV
    FROM clean.orders o
    WHERE o.promotion_id IS NULL
),
Promotion_Stats AS (
    SELECT
        p.promotion_id,
        p.promotion_name,
        p.promotion_type,
        COUNT(o.order_id) AS Orders_Count,
        AVG(o.order_total_amount) AS Avg_Order_Value_With_Promotion,
        AVG(o.discount_amount) AS Avg_Discount_Per_Order
    FROM clean.promotions p
    INNER JOIN clean.orders o
        ON o.promotion_id = p.promotion_id
    GROUP BY p.promotion_id, p.promotion_name, p.promotion_type
),
Promotion_Verdict AS (
    SELECT
        ps.*,
        ((ps.Avg_Order_Value_With_Promotion - b.Baseline_AOV) - ps.Avg_Discount_Per_Order) AS Net_Profitability_Per_Order
    FROM Promotion_Stats ps
    CROSS JOIN Baseline b
)
SELECT
    promotion_id,
    promotion_name,
    promotion_type,
    Orders_Count,
    Net_Profitability_Per_Order,
    (Net_Profitability_Per_Order * Orders_Count) AS Total_Loss_This_Promotion,
    SUM(Net_Profitability_Per_Order * Orders_Count) OVER () AS Total_Promotions_Leakage
FROM Promotion_Verdict
WHERE Net_Profitability_Per_Order < 0   -- loss-making only
ORDER BY Total_Loss_This_Promotion ASC;
 
 
-- ================================
-- PART 3: CHURN PROJECTED ANNUAL LOSS (high-value churned customers only)
-- ================================
WITH Customers_Details AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', COALESCE(c.last_name, '')) AS Customer_Name,
        SUM(o.order_total_amount) AS RCPC,
        COUNT(o.order_id) AS TOP_Count,
        MIN(o.order_date) AS First_Purchase,
        MAX(o.order_date) AS Last_Purchase
    FROM clean.customers AS c
    INNER JOIN clean.orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
Ranked_Customers AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY RCPC DESC) AS RCPC_Rank,
        DATEDIFF(DAY, Last_Purchase, CAST(GETDATE() AS DATE)) AS Inactive_Days
    FROM Customers_Details
),
Churned_High_Value AS (
    SELECT *
    FROM Ranked_Customers
    WHERE Inactive_Days >= 90
      AND RCPC_Rank = 1
      AND First_Purchase <> Last_Purchase        -- exclude one-time purchasers (can't derive a rate)
),
Annualized AS (
    SELECT
        customer_id,
        Customer_Name,
        RCPC,
        First_Purchase,
        Last_Purchase,
        (DATEDIFF(DAY, First_Purchase, Last_Purchase) / 365.0) AS Tenure_Years,
        (RCPC / (DATEDIFF(DAY, First_Purchase, Last_Purchase) / 365.0)) AS Annual_Run_Rate
    FROM Churned_High_Value
)
SELECT
    customer_id,
    Customer_Name,
    RCPC,
    Tenure_Years,
    Annual_Run_Rate,
    SUM(Annual_Run_Rate) OVER () AS Total_Projected_Annual_Churn_Loss
FROM Annualized
ORDER BY Annual_Run_Rate DESC;
 
 
