IF OBJECT_ID('clean.reviews', 'U') IS NOT NULL DROP TABLE clean.reviews;

SELECT
    TRY_CAST(review_id AS INT)          AS review_id,
    TRY_CAST(order_details_id AS INT)   AS order_details_id,
    CASE
        WHEN TRY_CAST(rating AS INT) BETWEEN 1 AND 5 THEN TRY_CAST(rating AS INT)
        ELSE NULL
    END                                  AS rating,
    NULLIF(LTRIM(RTRIM(review_text)), '') AS review_text,
    TRY_CONVERT(date, review_date, 23)  AS review_date
INTO clean.reviews
FROM staging.reviews;
GO

ALTER TABLE clean.reviews ALTER COLUMN review_id INT NOT NULL;
ALTER TABLE clean.reviews ADD CONSTRAINT PK_clean_reviews PRIMARY KEY (review_id);
ALTER TABLE clean.reviews ADD CONSTRAINT FK_reviews_orderdetails FOREIGN KEY (order_details_id) REFERENCES clean.order_details(order_details_id);
GO

SELECT COUNT(*) AS clean_reviews_count,
       SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS ratings_nulled_as_invalid
FROM clean.reviews;  -- expect 33137 rows, ~662 nulled


SELECT * FROM CLEAN.CUSTOMERS