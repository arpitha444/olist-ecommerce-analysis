-- Best selling categories by volume 

SELECT p.product_category_name_english,
COUNT(oi.product_id) AS total_sales
FROM olist_order_items oi 
INNER JOIN olist_products p 
ON oi.product_id = p.product_id
INNER JOIN olist_orders o 
ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Best selling categories by revenue

SELECT p.product_category_name_english,
ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items oi 
INNER JOIN olist_products p 
ON oi.product_id = p.product_id
INNER JOIN olist_orders o 
ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Average freight cost as percentage of product price by category

SELECT p.product_category_name_english, 
ROUND(AVG(oi.freight_value)::numeric, 2) AS avg_freight,
ROUND((SUM(oi.freight_value) * 100 / SUM(oi.price))::numeric, 2) AS pct_of_price
FROM olist_order_items oi 
JOIN olist_products p 
ON oi.product_id = p.product_id
GROUP BY 1
ORDER BY 3 DESC;

-- Categories with highest return/cancellation rates

SELECT p.product_category_name_english, 
COUNT(CASE WHEN o.order_status = 'canceled' THEN 1 END) AS canceled_orders,
COUNT(o.order_id) AS total_orders,
ROUND((COUNT(CASE WHEN o.order_status = 'canceled' THEN 1 END) * 100.0 / COUNT(o.order_id))::numeric, 2) AS cancelation_rate
FROM olist_order_items oi 
INNER JOIN olist_products p
ON oi.product_id = p.product_id
INNER JOIN olist_orders o 
ON oi.order_id = o.order_id
GROUP BY 1
ORDER BY 4 DESC;


