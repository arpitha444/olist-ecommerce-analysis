CREATE TABLE olist_customers (customer_id VARCHAR,
                              customer_unique_id VARCHAR,
                              customer_zip_code_prefix INTEGER,
                              customer_city VARCHAR,
                              customer_state VARCHAR);

COPY olist_customers FROM 'C:/Users/user/olist_customers_dataset.csv' DELIMITER ',' CSV HEADER

CREATE TABLE olist_order_items (order_id VARCHAR,
                                order_item_id INTEGER,
                                product_id VARCHAR,
                                seller_id VARCHAR,
                                shipping_limit_date TIMESTAMP,
                                price FLOAT,
                                freight_value FLOAT);

COPY olist_order_items FROM 'C:/Users/user/olist_order_items_cleaned.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE olist_order_payments (order_id VARCHAR,
                                   payment_sequential INTEGER,
                                   payment_type VARCHAR,
                                   payment_installments INTEGER,
                                   payment_value FLOAT);

COPY olist_order_payments FROM 'C:/Users/user/olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE olist_order_reviews (review_id VARCHAR,
                                  order_id VARCHAR, 
                                  review_score INTEGER,
                                  review_comment_title VARCHAR,
                                  review_comment_message VARCHAR,
                                  review_creation_date TIMESTAMP,
                                  review_answer_timestamp TIMESTAMP);

COPY olist_order_reviews FROM 'C:/Users/user/olist_order_reviews_cleaned.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE olist_orders (order_id VARCHAR,
                           customer_id VARCHAR,
                           order_status VARCHAR,
                           order_purchase_timestamp TIMESTAMP,
                           order_approved_at TIMESTAMP,
                           order_delivered_carrier_date TIMESTAMP,
                           order_delivered_customer_date TIMESTAMP,
                           order_estimated_delivery_date TIMESTAMP);

COPY olist_orders FROM 'C:/Users/user/olist_orders_cleaned.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE olist_products (product_id VARCHAR, 
                             product_category_name VARCHAR,
                             product_name_length INTEGER,
                             product_description_length INTEGER,
                             product_photos_qty INTEGER,
                             product_weight_g FLOAT,
                             product_length_cm FLOAT,
                             product_height_cm FLOAT,
                             product_width_cm FLOAT,
                             product_category_name_english VARCHAR);

COPY olist_products FROM 'C:/Users/user/olist_products_cleaned.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE olist_sellers (seller_id VARCHAR,
                            seller_zip_code_prefix INTEGER,
                            seller_city VARCHAR,
                            seller_state VARCHAR);

COPY olist_sellers FROM 'C:/Users/user/olist_sellers_dataset.csv' DELIMITER ',' CSV HEADER;