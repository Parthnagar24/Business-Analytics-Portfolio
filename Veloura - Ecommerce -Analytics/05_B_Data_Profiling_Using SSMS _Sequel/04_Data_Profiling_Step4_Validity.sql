--STEP 4: VALIDITY



SELECT
quantity
FROM staging.order_details
WHERE quantity <=0
ORDER BY quantity           ---contains -1 and 0 total rows :1022

SELECT
rating
FROM staging.reviews
WHERE rating <=0 OR rating >5   ---contains -1 , 0 , 6 total rows :662

SELECT 
    CAST(CAST(cost_price AS DECIMAL(18,2)) AS INT) AS cost_price, 
    CAST(CAST(selling_price AS DECIMAL(18,2)) AS INT) AS selling_price 
FROM 
    staging.products 
WHERE 
    CAST(CAST(cost_price AS DECIMAL(18,2)) AS INT) <= 0 
    OR CAST(CAST(selling_price AS DECIMAL(18,2)) AS INT) <= 0;   --ALL GOOD

-- STEP 4 (continued): Future dates + logical date order, with proper date parsing

;WITH normalized_dates AS (
    SELECT
        r.return_id,
        o.order_id,
        COALESCE(
            TRY_CONVERT(date, o.order_date, 23),   -- yyyy-mm-dd
            TRY_CONVERT(date, o.order_date, 111),  -- yyyy/mm/dd
            TRY_CONVERT(date, o.order_date, 101),  -- mm/dd/yyyy
            TRY_CONVERT(date, o.order_date, 105),  -- dd-mm-yyyy
            TRY_CONVERT(date, o.order_date, 106)   -- dd Mon yyyy
        ) AS order_date_clean,
        COALESCE(
            TRY_CONVERT(date, r.return_date, 23),
            TRY_CONVERT(date, r.return_date, 111),
            TRY_CONVERT(date, r.return_date, 101),
            TRY_CONVERT(date, r.return_date, 105),
            TRY_CONVERT(date, r.return_date, 106)
        ) AS return_date_clean
    FROM staging.returns AS r
    INNER JOIN staging.order_details AS ord ON ord.order_details_id = r.order_details_id
    INNER JOIN staging.orders AS o ON o.order_id = ord.order_id
)
SELECT *
FROM normalized_dates
WHERE return_date_clean < order_date_clean   -- a return can't happen before the order existed
   OR order_date_clean IS NULL               -- format didn't match any known pattern (needs investigation)
   OR return_date_clean IS NULL;

-- Future date check (anything after our dataset's defined "today", 2026-09-15)
SELECT order_id, order_date,
    COALESCE(
        TRY_CONVERT(date, order_date, 23),
        TRY_CONVERT(date, order_date, 111),
        TRY_CONVERT(date, order_date, 101),
        TRY_CONVERT(date, order_date, 105),
        TRY_CONVERT(date, order_date, 106)
    ) AS order_date_clean
FROM staging.orders
WHERE COALESCE(
        TRY_CONVERT(date, order_date, 23),
        TRY_CONVERT(date, order_date, 111),
        TRY_CONVERT(date, order_date, 101),
        TRY_CONVERT(date, order_date, 105),
        TRY_CONVERT(date, order_date, 106)
      ) > '2026-09-15';


    -- Diagnostic: separate real violations from parsing failures
;WITH normalized_dates AS (
    SELECT
        r.return_id,
        o.order_id,
        o.order_date AS order_date_raw,
        r.return_date AS return_date_raw,
        COALESCE(
            TRY_CONVERT(date, o.order_date, 23),
            TRY_CONVERT(date, o.order_date, 111),
            TRY_CONVERT(date, o.order_date, 101),
            TRY_CONVERT(date, o.order_date, 105),
            TRY_CONVERT(date, o.order_date, 106)
        ) AS order_date_clean,
        COALESCE(
            TRY_CONVERT(date, r.return_date, 23),
            TRY_CONVERT(date, r.return_date, 111),
            TRY_CONVERT(date, r.return_date, 101),
            TRY_CONVERT(date, r.return_date, 105),
            TRY_CONVERT(date, r.return_date, 106)
        ) AS return_date_clean
    FROM staging.returns AS r
    INNER JOIN staging.order_details AS ord ON ord.order_details_id = r.order_details_id
    INNER JOIN staging.orders AS o ON o.order_id = ord.order_id
)
SELECT
    CASE
        WHEN order_date_clean IS NULL OR return_date_clean IS NULL THEN 'PARSE_FAILURE'
        ELSE 'REAL_VIOLATION'
    END AS issue_type,
    COUNT(*) AS row_count
FROM normalized_dates
WHERE return_date_clean < order_date_clean
   OR order_date_clean IS NULL
   OR return_date_clean IS NULL
GROUP BY CASE
    WHEN order_date_clean IS NULL OR return_date_clean IS NULL THEN 'PARSE_FAILURE'
    ELSE 'REAL_VIOLATION'
END;