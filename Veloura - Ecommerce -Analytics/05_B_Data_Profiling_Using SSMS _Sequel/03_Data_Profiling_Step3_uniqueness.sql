--STEP 3 : UNIQUENESS

SELECT
customer_id,
COUNT(*) AS count_of_id
FROM staging.customers
GROUP BY customer_id
HAVING COUNT(*) >1                 --0

SELECT
email,
COUNT(*) AS count_of_id
FROM staging.customers
GROUP BY email
HAVING COUNT(*) >1            -- null : 221  duplicate : 55

SELECT
phone_number,
COUNT(*) AS count_of_id
FROM staging.customers
GROUP BY phone_number
HAVING COUNT(*) >1          --null 168  duplicate 53


SELECT
product_id,
COUNT(*) AS count_of_id
FROM staging.products
GROUP BY product_id
HAVING COUNT(*) >1          -- 0

SELECT
promotion_id,
COUNT(*) AS count_of_id
FROM staging.promotions
GROUP BY promotion_id 
HAVING COUNT(*) >1         --0

SELECT
order_id,
COUNT(*) AS count_of_id
FROM staging.orders
GROUP BY order_id
HAVING COUNT(*) >1        -- 0

SELECT
order_details_id,
COUNT(*) AS count_of_id
FROM staging.order_details
GROUP BY order_details_id
HAVING COUNT(*) >1            --0

SELECT
return_id,
COUNT(*) AS count_of_id
FROM staging.returns
GROUP BY return_id
HAVING COUNT(*) >1        -- 0

SELECT
order_details_id,
COUNT(*) AS count_of_id
FROM staging.returns
GROUP BY order_details_id 
HAVING COUNT(*) >1            --0

SELECT
review_id,
COUNT(*) AS count_of_id
FROM staging.reviews
GROUP BY review_id
HAVING COUNT(*) >1        -- 0

SELECT
order_details_id,
COUNT(*) AS count_of_id
FROM staging.reviews
GROUP BY order_details_id 
HAVING COUNT(*) >1         --0