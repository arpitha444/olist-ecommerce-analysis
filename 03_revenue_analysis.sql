-- Revenue by product category — top 10 and bottom 10

-- top 10
SELECT p.product_category_name_english, 
       ROUND(SUM(oi.price)::numeric, 2) AS aggregated_price
FROM olist_order_items AS oi
JOIN olist_products AS p ON oi.product_id = p.product_id
JOIN olist_orders AS o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
GROUP BY p.product_category_name_english
ORDER BY SUM(oi.price) DESC
LIMIT 10; 

-- bottom 10
SELECT p.product_category_name_english, 
       ROUND(SUM(oi.price)::numeric, 2) AS aggregated_price
FROM olist_order_items AS oi
JOIN olist_products AS p ON oi.product_id = p.product_id
JOIN olist_orders AS o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
GROUP BY p.product_category_name_english
ORDER BY SUM(oi.price) ASC
LIMIT 10; 

-- Average order value over time

WITH AvgOrderVal AS (
    SELECT TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS months,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_order_value
    FROM olist_orders AS o
    LEFT JOIN olist_order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
    GROUP BY 1
)

SELECT months, avg_order_value 
FROM AvgOrderVal
WHERE months > '2016-12' AND months < '2018-09'
ORDER BY months;

-- Revenue contribution by payment type 103886

SELECT payment_type, ROUND(SUM(payment_value)::numeric, 2)
FROM olist_order_payments
WHERE payment_type != 'not_defined'
GROUP BY payment_type
ORDER BY SUM(payment_value) DESC;

-- Top 10 sellers by total revenue

SELECT oi.seller_id, ROUND(SUM(oi.price)::numeric, 2) AS sales
FROM olist_order_items AS oi
INNER JOIN olist_orders AS o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
GROUP BY oi.seller_id
ORDER BY sales DESC
LIMIT 10;

-- Average freight value vs average product price over time

SELECT TO_CHAR(shipping_limit_date, 'YYYY-MM') AS months,
ROUND(AVG(price)::numeric, 2) AS avg_price, 
ROUND(AVG(freight_value)::numeric, 2) AS avg_freight
FROM olist_order_items
WHERE TO_CHAR(shipping_limit_date, 'YYYY-MM') > '2016-12' 
AND TO_CHAR(shipping_limit_date, 'YYYY-MM') < '2018-09'
GROUP BY months; 

-- Cumulative revenue over time

WITH monthly_sales AS (
    SELECT TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS months,
    SUM(oi.price) AS total_sales
    FROM olist_orders o 
    LEFT JOIN olist_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
    GROUP BY 1
)

SELECT months,
ROUND(total_sales::numeric, 2) AS monthly_sales,
ROUND(SUM(total_sales) OVER (ORDER BY months)::numeric, 2) AS cumulative_sales
FROM monthly_sales
WHERE months > '2016-12' AND months < '2018-09'
ORDER BY months;

-- Average payment value done through and not through installments

SELECT 
ROUND(AVG(CASE WHEN payment_installments > 1 THEN payment_value END)::numeric, 2) AS with_installments,
ROUND(AVG(CASE WHEN payment_installments = 1 THEN payment_value END)::numeric, 2) AS wo_installments
FROM olist_order_payments;