IF OBJECT_ID('clean.customers', 'U') IS NOT NULL DROP TABLE clean.customers;

WITH deduped AS (
    -- keep only rows that ARE the canonical id (drops the duplicate rows entirely)
    SELECT c.*
    FROM staging.customers c
    INNER JOIN clean.customer_id_map m ON TRY_CAST(c.customer_id AS INT) = m.old_id
    WHERE m.canonical_id = m.old_id
),
address_backfill AS (
    -- most recent shipping_address per customer, from their own orders
    SELECT customer_id, shipping_address,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM staging.orders
    WHERE shipping_address IS NOT NULL
)
SELECT
    TRY_CAST(d.customer_id AS INT)                                   AS customer_id,
    LTRIM(RTRIM(d.first_name))                                       AS first_name,
    LTRIM(RTRIM(d.last_name))                                        AS last_name,
    NULLIF(LTRIM(RTRIM(d.email)), '')                                AS email,
    NULLIF(LTRIM(RTRIM(d.phone_number)), '')                         AS phone_number,
    TRY_CONVERT(date, d.date_of_birth, 23)                           AS date_of_birth,
    COALESCE(NULLIF(LTRIM(RTRIM(d.address)), ''), ab.shipping_address) AS address,
    -- standardize state casing to sentence case (e.g. ASSAM/assam -> Assam)
    UPPER(LEFT(LTRIM(RTRIM(d.state)), 1)) + LOWER(SUBSTRING(LTRIM(RTRIM(d.state)), 2, LEN(d.state))) AS state,
    LTRIM(RTRIM(d.country))                                          AS country,
    -- unambiguous join_date parsing across all 5 known formats
    CASE
        WHEN d.join_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
            THEN CONVERT(date, d.join_date, 23)
        WHEN d.join_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
            THEN CONVERT(date, REPLACE(d.join_date, '/', '-'), 23)
        WHEN d.join_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
            THEN CONVERT(date, SUBSTRING(d.join_date,7,4)+'-'+SUBSTRING(d.join_date,1,2)+'-'+SUBSTRING(d.join_date,4,2), 23)
        WHEN d.join_date LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
            THEN CONVERT(date, SUBSTRING(d.join_date,7,4)+'-'+SUBSTRING(d.join_date,4,2)+'-'+SUBSTRING(d.join_date,1,2), 23)
        WHEN d.join_date LIKE '[0-9][0-9] [A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9][0-9]'
            THEN CONVERT(date, d.join_date, 106)
        ELSE NULL
    END AS join_date
INTO clean.customers
FROM deduped d
LEFT JOIN address_backfill ab ON TRY_CAST(d.customer_id AS INT) = ab.customer_id AND ab.rn = 1;
GO

-- Enforce primary key now that types are correct
ALTER TABLE clean.customers ALTER COLUMN customer_id INT NOT NULL;
ALTER TABLE clean.customers ADD CONSTRAINT PK_clean_customers PRIMARY KEY (customer_id);
GO

SELECT COUNT(*) AS clean_customer_count FROM clean.customers;  -- expect ~5500 (duplicates dropped)
