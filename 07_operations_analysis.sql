-- Average delivery time vs estimated delivery time — are estimates accurate

SELECT 
ROUND(AVG(order_delivered_customer_date::date - order_estimated_delivery_date::date), 1) AS avg_delay
FROM olist_orders;

-- States with best and worst on-time delivery rates

-- best
SELECT c.customer_state,
ROUND(AVG(o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date), 1) AS avg_diff
FROM olist_orders o 
JOIN olist_customers c 
ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
AND o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_delay ASC
LIMIT 10;

-- worst
SELECT c.customer_state,
ROUND(AVG(o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date), 1) AS avg_diff
FROM olist_orders o 
JOIN olist_customers c 
ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
AND o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_delay DESC
LIMIT 10;

-- Relationship between delay time and reviews

-- fast deliveries
SELECT c.customer_state,
ROUND(AVG(o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date), 1) AS avg_delay,
ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM olist_orders o 
JOIN olist_customers c 
ON o.customer_id = c.customer_id
JOIN olist_order_reviews r 
ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY c.customer_state
ORDER BY avg_delay ASC
LIMIT 10;

-- late deliveries
SELECT c.customer_state,
ROUND(AVG(o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date), 1) AS avg_delay,
ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM olist_orders o 
JOIN olist_customers c 
ON o.customer_id = c.customer_id
JOIN olist_order_reviews r 
ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY c.customer_state
ORDER BY avg_delay DESC
LIMIT 10;