CREATE SCHEMA clean;
GO



SELECT
    c.customer_id AS old_id,
    COALESCE(email_map.canonical_id, phone_map.canonical_id, c.customer_id) AS canonical_id
INTO #customer_id_map
FROM staging.customers c
LEFT JOIN (
    SELECT email, MIN(TRY_CAST(customer_id AS INT)) AS canonical_id
    FROM staging.customers
    WHERE email IS NOT NULL
    GROUP BY email
    HAVING COUNT(*) > 1
) email_map ON c.email = email_map.email
LEFT JOIN (
    SELECT phone_number, MIN(TRY_CAST(customer_id AS INT)) AS canonical_id
    FROM staging.customers
    WHERE phone_number IS NOT NULL
    GROUP BY phone_number
    HAVING COUNT(*) > 1
) phone_map ON c.phone_number = phone_map.phone_number;

-- Persist this mapping as a real table (temp table #customer_id_map won't
-- survive across separate script executions in SSMS)
IF OBJECT_ID('clean.customer_id_map', 'U') IS NOT NULL DROP TABLE clean.customer_id_map;
SELECT * INTO clean.customer_id_map FROM #customer_id_map;
DROP TABLE #customer_id_map;
GO

-- Sanity check: how many customer_ids actually got remapped to a different canonical id?
SELECT COUNT(*) AS remapped_count
FROM clean.customer_id_map
WHERE old_id <> canonical_id;
