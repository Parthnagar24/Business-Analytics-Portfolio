-- STEP 2 : Completeness

--customers
SELECT *
FROM staging.customers
WHERE
	customer_id IS NULL OR
	first_name IS NULL OR
	last_name IS NULL OR
	email IS NULL OR
	phone_number IS NULL OR
	date_of_birth IS NULL OR
	address IS NULL OR
	state IS NULL OR
	country IS NULL OR
	join_date IS NULL


--products
SELECT *
FROM staging.products
WHERE
	product_id IS NULL OR
	category IS NULL OR
	brand IS NULL OR
	product_name IS NULL OR
	launch_date IS NULL OR
	stock_quantity IS NULL OR
	cost_price IS NULL OR
	selling_price IS NULL


--orders
SELECT * 
FROM staging.orders
WHERE
shipping_address IS NULL OR
promotion_id IS NULL 

--order details

SELECT * FROM staging.order_details
WHERE unit_price IS NULL

--reviews

SELECT * FROM staging.reviews
WHERE review_text IS NULL


--returns

SELECT * FROM staging.returns

--promotions

SELECT * FROM staging.promotions