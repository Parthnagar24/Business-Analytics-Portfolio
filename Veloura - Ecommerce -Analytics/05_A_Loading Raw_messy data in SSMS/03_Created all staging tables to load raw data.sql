CREATE TABLE staging.customers (
    customer_id     VARCHAR(50),
    first_name      VARCHAR(255),
    last_name       VARCHAR(255),
    email           VARCHAR(255),
    phone_number    VARCHAR(50),
    date_of_birth   VARCHAR(50),
    address         VARCHAR(500),
    state           VARCHAR(100),
    country         VARCHAR(100),
    join_date       VARCHAR(50)
);
GO


CREATE TABLE staging.products (
    product_id      VARCHAR(50),
    product_name    VARCHAR(255),
    category        VARCHAR(100),
    brand           VARCHAR(255),
    cost_price      VARCHAR(50),
    selling_price   VARCHAR(50),
    stock_quantity  VARCHAR(50),
    launch_date     VARCHAR(50)
);
GO
 
CREATE TABLE staging.promotions (
    promotion_id        VARCHAR(50),
    promotion_name      VARCHAR(255),
    promotion_type      VARCHAR(100),
    discount_percentage VARCHAR(50),
    start_date          VARCHAR(50),
    end_date            VARCHAR(50)
);
GO
 
CREATE TABLE staging.orders (
    order_id            VARCHAR(50),
    customer_id         VARCHAR(50),
    promotion_id        VARCHAR(50),
    order_date          VARCHAR(50),
    order_status        VARCHAR(50),
    shipping_address    VARCHAR(500),
    billing_address     VARCHAR(500),
    discount_amount     VARCHAR(50),
    shipping_charge     VARCHAR(50),
    order_total_amount  VARCHAR(50)
);
GO
 
CREATE TABLE staging.order_details (
    order_details_id  VARCHAR(50),
    order_id          VARCHAR(50),
    product_id        VARCHAR(50),
    quantity          VARCHAR(50),
    unit_price        VARCHAR(50),
    total_price       VARCHAR(50)
);
GO
 
CREATE TABLE staging.returns (
    return_id           VARCHAR(50),
    order_details_id    VARCHAR(50),
    return_reason        VARCHAR(500),
    return_amount        VARCHAR(50),
    return_status        VARCHAR(50),
    return_date          VARCHAR(50)
);
GO
 
CREATE TABLE staging.reviews (
    review_id           VARCHAR(50),
    order_details_id    VARCHAR(50),
    rating               VARCHAR(50),
    review_text          VARCHAR(MAX),
    review_date          VARCHAR(50)
);
GO