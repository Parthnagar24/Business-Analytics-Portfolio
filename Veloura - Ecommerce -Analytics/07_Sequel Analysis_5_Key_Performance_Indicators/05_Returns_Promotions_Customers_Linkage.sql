

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
 
    -- distinct counts, since joining order_details multiplies rows per order
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    COUNT(DISTINCT CASE WHEN o.promotion_id IS NOT NULL THEN o.order_id END) AS Orders_With_Promotion,
    COUNT(DISTINCT r.return_id) AS Total_Returns_Made,
 
    -- conditional aggregates instead of WHERE, so non-returned rows aren't dropped
    SUM(CASE WHEN r.return_id IS NOT NULL THEN r.return_amount ELSE 0 END) AS Revenue_Refunded,
    SUM(ord.unit_price * ord.quantity) AS Revenue_Contributed
 
FROM clean.orders AS o
INNER JOIN clean.order_details AS ord
    ON ord.order_id = o.order_id
LEFT JOIN clean.returns AS r
    ON r.order_details_id = ord.order_details_id
LEFT JOIN clean.promotions AS p              -- LEFT JOIN: promo is optional per order
    ON p.promotion_id = o.promotion_id
INNER JOIN clean.customers AS c
    ON c.customer_id = o.customer_id
 
GROUP BY
    c.customer_id, c.first_name, c.last_name
ORDER BY Revenue_Refunded DESC;



WITH Line_Level AS (
    SELECT
        ord.order_details_id,
        ord.quantity,
        CASE WHEN o.promotion_id IS NOT NULL THEN 'Promoted' ELSE 'Non-Promoted' END AS Order_Type,
        CASE WHEN r.return_id IS NOT NULL THEN ord.quantity ELSE 0 END AS Quantity_Returned
    FROM clean.order_details AS ord
    INNER JOIN clean.orders AS o
        ON o.order_id = ord.order_id
    LEFT JOIN clean.returns AS r
        ON r.order_details_id = ord.order_details_id
)
SELECT
    Order_Type,
    SUM(quantity) AS Quantity_Sold,
    SUM(Quantity_Returned) AS Quantity_Returned,
    (CAST(SUM(Quantity_Returned) AS DECIMAL(10,2)) / SUM(quantity)) * 100 AS Return_Rate_Percent
FROM Line_Level
GROUP BY Order_Type;
 
 
-- ================================
-- ANGLE 3: RETURNS -> CHURN
-- Compare churn rate between customers who have ever had a
-- return vs customers who never had one
-- ================================
 
WITH Customer_Return_Flag AS (
    SELECT
        c.customer_id,
        MAX(o.order_date) AS Last_Purchase,
        CASE WHEN COUNT(r.return_id) > 0 THEN 'Has_Returned' ELSE 'Never_Returned' END AS Return_History
    FROM clean.customers AS c
    INNER JOIN clean.orders AS o
        ON o.customer_id = c.customer_id
    INNER JOIN clean.order_details AS ord
        ON ord.order_id = o.order_id
    LEFT JOIN clean.returns AS r
        ON r.order_details_id = ord.order_details_id
    GROUP BY c.customer_id
),
Churn_Flagged AS (
    SELECT
        *,
        DATEDIFF(DAY, Last_Purchase, CAST(GETDATE() AS DATE)) AS Inactive_Days,
        CASE
            WHEN DATEDIFF(DAY, Last_Purchase, CAST(GETDATE() AS DATE)) >= 90 THEN 'Churned'
            ELSE 'Active'
        END AS Churn_Status
    FROM Customer_Return_Flag
)
SELECT
    Return_History,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned_Customers,
    (CAST(SUM(CASE WHEN Churn_Status = 'Churned' THEN 1 ELSE 0 END) AS DECIMAL(10,2)) / COUNT(*)) * 100 AS Churn_Rate_Percent
FROM Churn_Flagged
GROUP BY Return_History;
 