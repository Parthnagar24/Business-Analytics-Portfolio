
IF OBJECT_ID('clean.promotions', 'U') IS NOT NULL DROP TABLE clean.promotions;

SELECT
    TRY_CAST(promotion_id AS INT)                  AS promotion_id,
    LTRIM(RTRIM(promotion_name))                   AS promotion_name,
    LTRIM(RTRIM(promotion_type))                   AS promotion_type,
    TRY_CAST(discount_percentage AS DECIMAL(5,2))  AS discount_percentage,
    TRY_CONVERT(date, start_date, 23)              AS start_date,
    TRY_CONVERT(date, end_date, 23)                AS end_date
INTO clean.promotions
FROM staging.promotions;
GO

ALTER TABLE clean.promotions ALTER COLUMN promotion_id INT NOT NULL;
ALTER TABLE clean.promotions ADD CONSTRAINT PK_clean_promotions PRIMARY KEY (promotion_id);
GO

SELECT COUNT(*) AS clean_promotion_count FROM clean.promotions;  -- expect 100
