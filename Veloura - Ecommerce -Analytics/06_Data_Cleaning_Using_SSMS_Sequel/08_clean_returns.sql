IF OBJECT_ID('clean.returns', 'U') IS NOT NULL DROP TABLE clean.returns;

WITH parsed AS (
    SELECT
        TRY_CAST(r.return_id AS INT)           AS return_id,
        TRY_CAST(r.order_details_id AS INT)    AS order_details_id,
        UPPER(LEFT(LTRIM(RTRIM(r.return_reason)), 1)) + LOWER(SUBSTRING(LTRIM(RTRIM(r.return_reason)), 2, LEN(r.return_reason))) AS return_reason,
        TRY_CAST(r.return_amount AS DECIMAL(10,2)) AS return_amount,
        LTRIM(RTRIM(r.return_status))          AS return_status,
        CASE
            WHEN r.return_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
                THEN CONVERT(date, r.return_date, 23)
            WHEN r.return_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
                THEN CONVERT(date, REPLACE(r.return_date, '/', '-'), 23)
            WHEN r.return_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
                THEN CONVERT(date, SUBSTRING(r.return_date,7,4)+'-'+SUBSTRING(r.return_date,1,2)+'-'+SUBSTRING(r.return_date,4,2), 23)
            WHEN r.return_date LIKE '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
                THEN CONVERT(date, SUBSTRING(r.return_date,7,4)+'-'+SUBSTRING(r.return_date,4,2)+'-'+SUBSTRING(r.return_date,1,2), 23)
            WHEN r.return_date LIKE '[0-9][0-9] [A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9][0-9]'
                THEN CONVERT(date, r.return_date, 106)
            ELSE NULL
        END AS return_date
    FROM staging.returns r
)
SELECT
    p.*,
    o.order_date,
    CASE WHEN p.return_date < o.order_date THEN 1 ELSE 0 END AS data_quality_flag
INTO clean.returns
FROM parsed p
LEFT JOIN clean.order_details od ON p.order_details_id = od.order_details_id
LEFT JOIN clean.orders o ON od.order_id = o.order_id;

-- drop the helper order_date column, it was only needed to compute the flag
ALTER TABLE clean.returns DROP COLUMN order_date;
GO

ALTER TABLE clean.returns ALTER COLUMN return_id INT NOT NULL;
ALTER TABLE clean.returns ADD CONSTRAINT PK_clean_returns PRIMARY KEY (return_id);
ALTER TABLE clean.returns ADD CONSTRAINT FK_returns_orderdetails FOREIGN KEY (order_details_id) REFERENCES clean.order_details(order_details_id);
GO

SELECT COUNT(*) AS clean_returns_count, SUM(CAST(data_quality_flag AS INT)) AS flagged_illogical_dates
FROM clean.returns;  -- expect 10941 rows, ~45 flagged
