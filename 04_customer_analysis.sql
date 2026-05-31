-- Total orders per customer

SELECT c.customer_unique_id, 
COUNT(o.order_id) AS total_orders
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;

-- Customer distribution by state

SELECT customer_state, 
COUNT(customer_unique_id) AS total_customers
FROM olist_customers
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Average days between order and delivery by state

SELECT c.customer_state, 
DATE_TRUNC('hour', AVG(o.order_delivered_customer_date - o.order_purchase_timestamp)) AS avg_delivery_time
FROM olist_orders o 
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
GROUP BY c.customer_state
ORDER BY avg_delivery_time ASC;



