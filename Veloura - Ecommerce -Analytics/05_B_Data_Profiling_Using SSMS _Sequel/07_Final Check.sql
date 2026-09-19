--Final Check:

/* =========================================================================
   FUTURE DATE CHECKS - ALL DATE COLUMNS
   Uses the same COALESCE + TRY_CONVERT pattern from Step 4, since every
   date column is VARCHAR with 5 mixed formats. "Today" for this dataset
   is fixed at 2026-09-15 (the dataset's defined cutoff), not GETDATE().
   ========================================================================= */

DECLARE @dataset_cutoff DATE = '2026-09-15';

-- Customers: join_date
SELECT customer_id, join_date AS raw_value,
    COALESCE(
        TRY_CONVERT(date, join_date, 23), TRY_CONVERT(date, join_date, 111),
        TRY_CONVERT(date, join_date, 101), TRY_CONVERT(date, join_date, 105),
        TRY_CONVERT(date, join_date, 106)
    ) AS parsed_date
FROM staging.customers
WHERE COALESCE(
        TRY_CONVERT(date, join_date, 23), TRY_CONVERT(date, join_date, 111),
        TRY_CONVERT(date, join_date, 101), TRY_CONVERT(date, join_date, 105),
        TRY_CONVERT(date, join_date, 106)
      ) > @dataset_cutoff;

-- Products: launch_date
SELECT product_id, launch_date AS raw_value,
    COALESCE(
        TRY_CONVERT(date, launch_date, 23), TRY_CONVERT(date, launch_date, 111),
        TRY_CONVERT(date, launch_date, 101), TRY_CONVERT(date, launch_date, 105),
        TRY_CONVERT(date, launch_date, 106)
    ) AS parsed_date
FROM staging.products
WHERE COALESCE(
        TRY_CONVERT(date, launch_date, 23), TRY_CONVERT(date, launch_date, 111),
        TRY_CONVERT(date, launch_date, 101), TRY_CONVERT(date, launch_date, 105),
        TRY_CONVERT(date, launch_date, 106)
      ) > @dataset_cutoff;

-- Orders: order_date
SELECT order_id, order_date AS raw_value,
    COALESCE(
        TRY_CONVERT(date, order_date, 23), TRY_CONVERT(date, order_date, 111),
        TRY_CONVERT(date, order_date, 101), TRY_CONVERT(date, order_date, 105),
        TRY_CONVERT(date, order_date, 106)
    ) AS parsed_date
FROM staging.orders
WHERE COALESCE(
        TRY_CONVERT(date, order_date, 23), TRY_CONVERT(date, order_date, 111),
        TRY_CONVERT(date, order_date, 101), TRY_CONVERT(date, order_date, 105),
        TRY_CONVERT(date, order_date, 106)
      ) > @dataset_cutoff;

-- Returns: return_date
SELECT return_id, return_date AS raw_value,
    COALESCE(
        TRY_CONVERT(date, return_date, 23), TRY_CONVERT(date, return_date, 111),
        TRY_CONVERT(date, return_date, 101), TRY_CONVERT(date, return_date, 105),
        TRY_CONVERT(date, return_date, 106)
    ) AS parsed_date
FROM staging.returns
WHERE COALESCE(
        TRY_CONVERT(date, return_date, 23), TRY_CONVERT(date, return_date, 111),
        TRY_CONVERT(date, return_date, 101), TRY_CONVERT(date, return_date, 105),
        TRY_CONVERT(date, return_date, 106)
      ) > @dataset_cutoff;

-- Reviews: review_date
SELECT review_id, review_date AS raw_value,
    COALESCE(
        TRY_CONVERT(date, review_date, 23), TRY_CONVERT(date, review_date, 111),
        TRY_CONVERT(date, review_date, 101), TRY_CONVERT(date, review_date, 105),
        TRY_CONVERT(date, review_date, 106)
    ) AS parsed_date
FROM staging.reviews
WHERE COALESCE(
        TRY_CONVERT(date, review_date, 23), TRY_CONVERT(date, review_date, 111),
        TRY_CONVERT(date, review_date, 101), TRY_CONVERT(date, review_date, 105),
        TRY_CONVERT(date, review_date, 106)
      ) > @dataset_cutoff;

-- Promotions: start_date and end_date
SELECT promotion_id, start_date AS raw_value,
    COALESCE(
        TRY_CONVERT(date, start_date, 23), TRY_CONVERT(date, start_date, 111),
        TRY_CONVERT(date, start_date, 101), TRY_CONVERT(date, start_date, 105),
        TRY_CONVERT(date, start_date, 106)
    ) AS parsed_date
FROM staging.promotions
WHERE COALESCE(
        TRY_CONVERT(date, start_date, 23), TRY_CONVERT(date, start_date, 111),
        TRY_CONVERT(date, start_date, 101), TRY_CONVERT(date, start_date, 105),
        TRY_CONVERT(date, start_date, 106)
      ) > @dataset_cutoff
   OR COALESCE(
        TRY_CONVERT(date, end_date, 23), TRY_CONVERT(date, end_date, 111),
        TRY_CONVERT(date, end_date, 101), TRY_CONVERT(date, end_date, 105),
        TRY_CONVERT(date, end_date, 106)
      ) > @dataset_cutoff;


/* =========================================================================
   CASE-SENSITIVE RE-VERIFICATION OF CATEGORICAL VALUES
   SQL Server's default collation is case-INSENSITIVE, so a plain GROUP BY
   silently merges 'Clothing', 'CLOTHING', and 'clothing' into one row,
   hiding real casing differences. Forcing a case-sensitive collation
   (Latin1_General_100_CS_AS) exposes them properly.
   ========================================================================= */

SELECT state COLLATE Latin1_General_100_CS_AS AS state_exact, COUNT(*) AS row_count
FROM staging.customers
GROUP BY state COLLATE Latin1_General_100_CS_AS
ORDER BY state_exact;

SELECT order_status COLLATE Latin1_General_100_CS_AS AS order_status_exact, COUNT(*) AS row_count
FROM staging.orders
GROUP BY order_status COLLATE Latin1_General_100_CS_AS
ORDER BY order_status_exact;

SELECT category COLLATE Latin1_General_100_CS_AS AS category_exact, COUNT(*) AS row_count
FROM staging.products
GROUP BY category COLLATE Latin1_General_100_CS_AS
ORDER BY category_exact;

SELECT return_reason COLLATE Latin1_General_100_CS_AS AS return_reason_exact, COUNT(*) AS row_count
FROM staging.returns
GROUP BY return_reason COLLATE Latin1_General_100_CS_AS
ORDER BY return_reason_exact;

SELECT return_status COLLATE Latin1_General_100_CS_AS AS return_status_exact, COUNT(*) AS row_count
FROM staging.returns
GROUP BY return_status COLLATE Latin1_General_100_CS_AS
ORDER BY return_status_exact;

SELECT promotion_type COLLATE Latin1_General_100_CS_AS AS promotion_type_exact, COUNT(*) AS row_count
FROM staging.promotions
GROUP BY promotion_type COLLATE Latin1_General_100_CS_AS
ORDER BY promotion_type_exact;

-- Corrected phone format check (fixes the dash-split pattern length bug)
SELECT
    CASE
        WHEN phone_number LIKE '+91-%' THEN 'plus91_dash'
        WHEN phone_number LIKE '+91%' THEN 'plus91_noSpace'
        WHEN phone_number LIKE '0%' AND LEN(phone_number) = 11 THEN 'leading_zero'
        WHEN phone_number LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9]' THEN 'dash_split'
        WHEN LEN(phone_number) = 10 AND phone_number NOT LIKE '%[^0-9]%' THEN 'plain_10digit'
        WHEN phone_number IS NULL THEN 'NULL'
        ELSE 'other_unrecognized'
    END AS phone_format,
    COUNT(*) AS row_count
FROM staging.customers
GROUP BY
    CASE
        WHEN phone_number LIKE '+91-%' THEN 'plus91_dash'
        WHEN phone_number LIKE '+91%' THEN 'plus91_noSpace'
        WHEN phone_number LIKE '0%' AND LEN(phone_number) = 11 THEN 'leading_zero'
        WHEN phone_number LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9]' THEN 'dash_split'
        WHEN LEN(phone_number) = 10 AND phone_number NOT LIKE '%[^0-9]%' THEN 'plain_10digit'
        WHEN phone_number IS NULL THEN 'NULL'
        ELSE 'other_unrecognized'
    END
ORDER BY row_count DESC;