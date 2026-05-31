-- Top 10 sellers by revenue

SELECT oi.seller_id, 
ROUND(SUM(oi.price)::numeric, 2) AS total_sales
FROM olist_orders AS o 
INNER JOIN olist_order_items AS oi 
ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
GROUP BY oi.seller_id
ORDER BY total_sales DESC
LIMIT 10 ;

-- Sellers with high revenue but low review scores

WITH sales AS (
    SELECT oi.seller_id, 
    SUM(oi.price) AS total_revenue,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
    FROM olist_orders o 
    INNER JOIN olist_order_items oi ON o.order_id = oi.order_id
    INNER JOIN olist_order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
    GROUP BY oi.seller_id
)

SELECT seller_id,
ROUND(total_revenue::numeric, 2) AS total_revenue, 
avg_review_score
FROM sales
WHERE avg_review_score < 3
ORDER BY total_revenue DESC
LIMIT 10;

-- Average freight cost per seller

SELECT oi.seller_id,
ROUND(AVG(oi.freight_value)::numeric, 2) AS avg_freight_cost,
ROUND(AVG(oi.price)::numeric, 2) AS avg_price,
ROUND((AVG(oi.freight_value) * 100/AVG(oi.price))::numeric, 2) AS freight_pct
FROM olist_order_items oi 
JOIN olist_orders o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
GROUP BY oi.seller_id
ORDER BY freight_pct DESC;

-- Average revenue of seller by state

SELECT s.seller_state, 
ROUND(AVG(price)::numeric, 2) AS avg_sales,
ROUND(SUM(price)::numeric, 2) AS total_sales 
FROM olist_order_items oi 
INNER JOIN olist_orders o ON oi.order_id = o.order_id
INNER JOIN olist_sellers s ON oi.seller_id = s.seller_id
WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
GROUP BY  s.seller_state
ORDER BY total_sales DESC;




