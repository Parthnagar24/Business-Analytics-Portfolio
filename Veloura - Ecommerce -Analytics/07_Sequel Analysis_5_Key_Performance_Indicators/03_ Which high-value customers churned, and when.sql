/*
=====================================================================
PHASE 7 — ANALYSIS
Question 3: Which high-value customers churned, and when?
Churn definition: no purchase in the last 90 days (from dataset's last known order date)
High-value definition: top 20% of customers by total revenue contributed (NTILE 1 of 5)
=====================================================================
*/

WITH Customers_Details AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', COALESCE(c.last_name, '')) AS Customer_Name,
        SUM(o.order_total_amount) AS RCPC,          -- Revenue Contributed Per Customer
        COUNT(o.order_id)         AS TOP_Count,     -- Total Orders Purchased
        MIN(o.order_date)         AS First_Purchase,
        MAX(o.order_date)         AS Last_Purchase
    FROM clean.customers AS c
    INNER JOIN clean.orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
),
Ranked_Customers AS (
    SELECT
        *,
        CAST(GETDATE() AS DATE) AS Reference_Date,
        NTILE(5) OVER (ORDER BY RCPC DESC)                       AS RCPC_Rank,   -- 1 = top 20% by revenue
        DATEDIFF(DAY, Last_Purchase, CAST(GETDATE() AS DATE))    AS Inactive_Days
    FROM Customers_Details
)
SELECT
    customer_id,
    Customer_Name,
    RCPC,
    TOP_Count,
    First_Purchase,
    Last_Purchase,
    Inactive_Days,
    RCPC_Rank
FROM Ranked_Customers
WHERE Inactive_Days >= 90        -- churned
  AND RCPC_Rank = 1              -- high-value only (top 20%)
