SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM staging.customers
UNION ALL
SELECT 'products', COUNT(*) FROM staging.products
UNION ALL
SELECT 'promotions', COUNT(*) FROM staging.promotions
UNION ALL
SELECT 'orders', COUNT(*) FROM staging.orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM staging.order_details
UNION ALL
SELECT 'returns', COUNT(*) FROM staging.returns
UNION ALL
SELECT 'reviews', COUNT(*) FROM staging.reviews;
GO