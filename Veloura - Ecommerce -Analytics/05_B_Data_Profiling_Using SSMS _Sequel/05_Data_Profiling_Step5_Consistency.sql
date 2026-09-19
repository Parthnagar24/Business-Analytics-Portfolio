/* =========================================================================
   PHASE 5 - STEP 5: CONSISTENCY CHECKS
   Casing/typo issues, whitespace, phone format, and date format distribution
   ========================================================================= */


SELECT state, COUNT(*) AS row_count
FROM staging.customers
GROUP BY state
ORDER BY state;

SELECT order_status, COUNT(*) AS row_count
FROM staging.orders
GROUP BY order_status
ORDER BY order_status;

SELECT category, COUNT(*) AS row_count
FROM staging.products
GROUP BY category
ORDER BY category;

SELECT return_reason, COUNT(*) AS row_count
FROM staging.returns
GROUP BY return_reason
ORDER BY return_reason;

SELECT return_status, COUNT(*) AS row_count
FROM staging.returns
GROUP BY return_status
ORDER BY return_status;

SELECT promotion_type, COUNT(*) AS row_count
FROM staging.promotions
GROUP BY promotion_type
ORDER BY promotion_type;



SELECT customer_id, first_name,
       LEN(first_name) AS raw_length,
       LEN(LTRIM(RTRIM(first_name))) AS trimmed_length
FROM staging.customers
WHERE LEN(first_name) <> LEN(LTRIM(RTRIM(first_name)));

SELECT customer_id, last_name,
       LEN(last_name) AS raw_length,
       LEN(LTRIM(RTRIM(last_name))) AS trimmed_length
FROM staging.customers
WHERE LEN(last_name) <> LEN(LTRIM(RTRIM(last_name)));

-- Quick summary count instead of listing every row, if preferred:
SELECT COUNT(*) AS whitespace_issue_count
FROM staging.customers
WHERE LEN(first_name) <> LEN(LTRIM(RTRIM(first_name)))
   OR LEN(last_name) <> LEN(LTRIM(RTRIM(last_name)));



SELECT
    CASE
        WHEN phone_number LIKE '+91-%'      THEN 'plus91_dash'
        WHEN phone_number LIKE '+91%'       THEN 'plus91_noSpace'
        WHEN phone_number LIKE '0%' AND LEN(phone_number) = 11 THEN 'leading_zero'
        WHEN phone_number LIKE '_____-____' THEN 'dash_split'
        WHEN LEN(phone_number) = 10 AND phone_number NOT LIKE '%[^0-9]%' THEN 'plain_10digit'
        WHEN phone_number IS NULL THEN 'NULL'
        ELSE 'other_unrecognized'
    END AS phone_format,
    COUNT(*) AS row_count
FROM staging.customers
GROUP BY
    CASE
        WHEN phone_number LIKE '+91-%'      THEN 'plus91_dash'
        WHEN phone_number LIKE '+91%'       THEN 'plus91_noSpace'
        WHEN phone_number LIKE '0%' AND LEN(phone_number) = 11 THEN 'leading_zero'
        WHEN phone_number LIKE '_____-____' THEN 'dash_split'
        WHEN LEN(phone_number) = 10 AND phone_number NOT LIKE '%[^0-9]%' THEN 'plain_10digit'
        WHEN phone_number IS NULL THEN 'NULL'
        ELSE 'other_unrecognized'
    END
ORDER BY row_count DESC;


-- 5D. DATE FORMAT DISTRIBUTION
-- Classify every date-type column's raw text into its format pattern.
-- This quantifies exactly how many rows are in each of the 5 formats we
-- know exist, per column, so Phase 6 cleaning can handle each explicitly.

-- Reusable pattern logic (repeat this CASE block per date column):
--   ISO           : yyyy-mm-dd   -> '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
--   Slash ISO     : yyyy/mm/dd   -> '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
--   US slash      : mm/dd/yyyy   -> '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
--   Dash DMY      : dd-mm-yyyy   -> '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
--   Text month    : dd Mon yyyy  -> '[0-9][0-9] [A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9][0-9]'

SELECT
    CASE
        WHEN order_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' THEN 'ISO_yyyy-mm-dd'
        WHEN order_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]' THEN 'yyyy/mm/dd'
        WHEN order_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'mm/dd/yyyy'
        WHEN order_date LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]' THEN 'dd-mm-yyyy'
        WHEN order_date LIKE '[0-9][0-9] [A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9][0-9]' THEN 'dd Mon yyyy'
        ELSE 'UNRECOGNIZED_FORMAT'
    END AS date_format,
    COUNT(*) AS row_count
FROM staging.orders
GROUP BY
    CASE
        WHEN order_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' THEN 'ISO_yyyy-mm-dd'
        WHEN order_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]' THEN 'yyyy/mm/dd'
        WHEN order_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'mm/dd/yyyy'
        WHEN order_date LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]' THEN 'dd-mm-yyyy'
        WHEN order_date LIKE '[0-9][0-9] [A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9][0-9]' THEN 'dd Mon yyyy'
        ELSE 'UNRECOGNIZED_FORMAT'
    END
ORDER BY row_count DESC;

-- Repeat the SAME pattern for return_date (staging.returns):
SELECT
    CASE
        WHEN return_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' THEN 'ISO_yyyy-mm-dd'
        WHEN return_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]' THEN 'yyyy/mm/dd'
        WHEN return_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'mm/dd/yyyy'
        WHEN return_date LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]' THEN 'dd-mm-yyyy'
        WHEN return_date LIKE '[0-9][0-9] [A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9][0-9]' THEN 'dd Mon yyyy'
        ELSE 'UNRECOGNIZED_FORMAT'
    END AS date_format,
    COUNT(*) AS row_count
FROM staging.returns
GROUP BY
    CASE
        WHEN return_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' THEN 'ISO_yyyy-mm-dd'
        WHEN return_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]' THEN 'yyyy/mm/dd'
        WHEN return_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'mm/dd/yyyy'
        WHEN return_date LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]' THEN 'dd-mm-yyyy'
        WHEN return_date LIKE '[0-9][0-9] [A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9][0-9]' THEN 'dd Mon yyyy'
        ELSE 'UNRECOGNIZED_FORMAT'
    END
ORDER BY row_count DESC;

