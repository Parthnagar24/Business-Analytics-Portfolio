SELECT 'customers' AS tbl, COUNT(*) AS null_pk_count FROM clean.customers WHERE customer_id IS NULL
UNION ALL
SELECT 'products', COUNT(*) FROM clean.products WHERE product_id IS NULL
UNION ALL
SELECT 'promotions', COUNT(*) FROM clean.promotions WHERE promotion_id IS NULL
UNION ALL
SELECT 'orders', COUNT(*) FROM clean.orders WHERE order_id IS NULL
UNION ALL
SELECT 'order_details', COUNT(*) FROM clean.order_details WHERE order_details_id IS NULL
UNION ALL
SELECT 'returns', COUNT(*) FROM clean.returns WHERE return_id IS NULL
UNION ALL
SELECT 'reviews', COUNT(*) FROM clean.reviews WHERE review_id IS NULL;
GO
 
-- ---- CUSTOMERS ----
ALTER TABLE clean.customers ALTER COLUMN customer_id INT NOT NULL;
GO
ALTER TABLE clean.customers ADD CONSTRAINT PK_clean_customers PRIMARY KEY (customer_id);
GO
 
-- ---- PRODUCTS ----
ALTER TABLE clean.products ALTER COLUMN product_id INT NOT NULL;
GO
ALTER TABLE clean.products ADD CONSTRAINT PK_clean_products PRIMARY KEY (product_id);
GO
 
-- ---- PROMOTIONS ----
ALTER TABLE clean.promotions ALTER COLUMN promotion_id INT NOT NULL;
GO
ALTER TABLE clean.promotions ADD CONSTRAINT PK_clean_promotions PRIMARY KEY (promotion_id);
GO
 
-- ---- ORDERS ----
ALTER TABLE clean.orders ALTER COLUMN order_id INT NOT NULL;
GO
ALTER TABLE clean.orders ADD CONSTRAINT PK_clean_orders PRIMARY KEY (order_id);
GO
ALTER TABLE clean.orders ADD CONSTRAINT FK_orders_customers FOREIGN KEY (customer_id) REFERENCES clean.customers(customer_id);
GO
ALTER TABLE clean.orders ADD CONSTRAINT FK_orders_promotions FOREIGN KEY (promotion_id) REFERENCES clean.promotions(promotion_id);
GO
 
-- ---- ORDER_DETAILS ----
ALTER TABLE clean.order_details ALTER COLUMN order_details_id INT NOT NULL;
GO
ALTER TABLE clean.order_details ADD CONSTRAINT PK_clean_order_details PRIMARY KEY (order_details_id);
GO
ALTER TABLE clean.order_details ADD CONSTRAINT FK_od_orders FOREIGN KEY (order_id) REFERENCES clean.orders(order_id);
GO
ALTER TABLE clean.order_details ADD CONSTRAINT FK_od_products FOREIGN KEY (product_id) REFERENCES clean.products(product_id);
GO
 
-- ---- RETURNS ----
ALTER TABLE clean.returns ALTER COLUMN return_id INT NOT NULL;
GO
ALTER TABLE clean.returns ADD CONSTRAINT PK_clean_returns PRIMARY KEY (return_id);
GO
ALTER TABLE clean.returns ADD CONSTRAINT FK_returns_orderdetails FOREIGN KEY (order_details_id) REFERENCES clean.order_details(order_details_id);
GO
 
-- ---- REVIEWS ----
ALTER TABLE clean.reviews ALTER COLUMN review_id INT NOT NULL;
GO
ALTER TABLE clean.reviews ADD CONSTRAINT PK_clean_reviews PRIMARY KEY (review_id);
GO
ALTER TABLE clean.reviews ADD CONSTRAINT FK_reviews_orderdetails FOREIGN KEY (order_details_id) REFERENCES clean.order_details(order_details_id);
GO
 
-- ---- Final verification: list all PKs/FKs successfully created ----
SELECT
    tc.TABLE_NAME, tc.CONSTRAINT_NAME, tc.CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
WHERE tc.TABLE_SCHEMA = 'clean'
ORDER BY tc.TABLE_NAME, tc.CONSTRAINT_TYPE;
 
