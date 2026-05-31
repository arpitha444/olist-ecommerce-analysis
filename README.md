# E-commerce platform Olist Sales Analysis using SQL, Power BI and Python

Analyzed 100,000+ orders from Olist, a Brazilian e-commerce platform, to uncover revenue trends, customer behavior, and seller performance patterns. The goal was to derive actionable business insights that could help form informed decisions around customer retention, seller quality, best selling categories and logistics optimization.

## Dataset Used

Brazilian E-Commerce Public Dataset by Olist: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Schema Diagram

<p align="center">
  <img src="images and gifs/schema.png" alt="Database Schema Diagram" width="80%">
</p>

## Key Findings

- São Paulo dominates both revenue and orders by a disproportionate amount, generating 5M+ alone which is 3x more than the second highest state Rio de Janeiro
- November 2017 had the highest amount of sales, possibly an effect of Black Friday Sale.
- 97% of orders were successfully delivered and less than 3% were shipped/cancelled indicating high logistics efficiency 
- 96.98% are one time customers with only 3.02% being repeat customers which suggests a major customer retention problem
- Top 20% of sellers contribute significantly to the revenue with 82.57% of the revenue share being theirs indicating critical reliance on high performance vendors
- Credit card is the most used payment type with 78.34% transactions done through it, boleto is a distant second at 17.92%
- Actual Delivery time is consistently faster than Estimated Delivery time by 10 days on average indicating solid delivery network

## Tools Used

PostgreSQL, Power BI, Python, pandas, uxwing(for icons)

## Key SQL Queries

### Total revenue by month and year with MoM growth using LAG
```sql
WITH SalesPerMonth AS (
    SELECT 
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS yr_month,
    SUM(oi.price) AS total_sales
    FROM olist_orders AS o
    LEFT JOIN olist_order_items AS oi ON o.order_id = oi.order_id 
    WHERE order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
    GROUP BY 1
)

SELECT yr_month, ROUND(total_sales::numeric, 2),
ROUND(LAG(total_sales) OVER (ORDER BY yr_month)::numeric, 2) AS prev_month_sales,
ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY yr_month)) /
        LAG(total_sales) OVER (ORDER BY yr_month) * 100)::numeric, 2) || '%' AS mom_growth
FROM SalesPerMonth
WHERE yr_month > '2016-12' AND yr_month < '2018-09' 
ORDER BY yr_month;
```
#### Query Results
```sql
 yr_month |   round   | prev_month_sales | mom_growth
----------+-----------+------------------+------------
 2017-01  | 116513.65 |                  |
 2017-02  | 243894.82 |        116513.65 | 109.33%
 2017-03  | 367651.62 |        243894.82 | 50.74%
 2017-04  | 351962.91 |        367651.62 | -4.27%
 2017-05  | 500932.96 |        351962.91 | 42.33%
 2017-06  | 429014.83 |        500932.96 | -14.36%
 2017-07  | 490447.63 |        429014.83 | 14.32%
 2017-08  | 564583.93 |        490447.63 | 15.12%
 2017-09  | 617724.25 |        564583.93 | 9.41%
 2017-10  | 657968.38 |        617724.25 | 6.51%
 2017-11  | 999580.34 |        657968.38 | 51.92%
 2017-12  | 740399.37 |        999580.34 | -25.93%
 2018-01  | 938585.01 |        740399.37 | 26.77%
 2018-02  | 837347.85 |        938585.01 | -10.79%
 2018-03  | 972446.78 |        837347.85 | 16.13%
 2018-04  | 992061.19 |        972446.78 | 2.02%
 2018-05  | 986044.85 |        992061.19 | -0.61%
 2018-06  | 862907.33 |        986044.85 | -12.49%
 2018-07  | 874692.94 |        862907.33 | 1.37%
 2018-08  | 846153.30 |        874692.94 | -3.26%
(20 rows)
```
### Number of repeat vs one-time buyers using CASE
```sql
WITH customer_order_count AS (
   SELECT c.customer_unique_id, COUNT(o.order_id) AS total_orders
   FROM olist_orders o
   JOIN olist_customers c ON o.customer_id = c.customer_id
   GROUP BY c.customer_unique_id
)

SELECT SUM(CASE WHEN total_orders = 1 THEN 1 END) AS one_time_buyers,
SUM(CASE WHEN total_orders > 1 THEN 1 END) AS repeat_buyers
FROM customer_order_count;
```
#### Query Results
```sql
 one_time_buyers | repeat_buyers
-----------------+---------------
           93099 |          2997
(1 row)
```
### Customer segmentation by order frequency using Subquery
```sql
SELECT CASE 
    WHEN total_orders = 1 THEN 'One time customers'
    WHEN total_orders BETWEEN 2 AND 3 THEN 'Occasional customers'
    WHEN total_orders > 3 THEN 'Loyal customers'
END AS customer_segment,
COUNT(*) AS total_customers,
ROUND((COUNT(*) * 100 / SUM(COUNT(*)) OVER ()), 2) || '%' AS customer_percent
FROM (
    SELECT c.customer_unique_id, COUNT(o.order_id) AS total_orders
    FROM olist_orders o 
    JOIN olist_customers c 
    ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
GROUP BY customer_segment
ORDER BY total_customers; 
```
#### Query Results
```sql
   customer_segment   | total_customers | customer_percent
----------------------+-----------------+------------------
 Loyal customers      |              49 | 0.05%
 Occasional customers |            2948 | 3.07%
 One time customers   |           93099 | 96.88%
(3 rows)
```
### What percentage of revenue comes from top 20% of sellers using CTE (Pareto Analysis)
```sql
WITH total_sales AS (
    SELECT oi.seller_id, 
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
    FROM olist_orders AS o 
    INNER JOIN olist_order_items AS oi 
    ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
    GROUP BY oi.seller_id
),

classified_sellers AS( 
    SELECT *,
    NTILE(5) OVER (ORDER BY total_revenue DESC) AS revenue_bucket
    FROM total_sales
)

SELECT 
CASE WHEN revenue_bucket = 1 THEN 'Top 20%' 
ELSE 'Bottom 80%' END AS seller_group,
ROUND(SUM(total_revenue)::numeric, 2) AS total_revenue,
ROUND((SUM(total_revenue) * 100 / SUM(SUM(total_revenue)) OVER ())::numeric, 2) || '%' AS revenue_share_pct
FROM classified_sellers
GROUP BY 1
ORDER BY total_revenue DESC;
```
#### Query Results
```sql
 seller_group | total_revenue | revenue_share_pct
--------------+---------------+-------------------
 Top 20%      |   11091827.42 | 82.57%
 Bottom 80%   |    2341046.95 | 17.43%
(2 rows)
```
### Correlation between late delivery and low review scores
```sql
WITH order_types AS (
    SELECT order_id, CASE 
    WHEN order_delivered_customer_date < order_estimated_delivery_date THEN 'On Time'
    ELSE 'Late' END AS delivery_type
    FROM olist_orders 
    WHERE order_status NOT IN ('unavailable', 'invoiced', 'created', 'canceled')
), 

reviews AS (
    SELECT ot.order_id, ot.delivery_type, r.review_score
    FROM order_types ot
    JOIN olist_order_reviews r
    ON ot.order_id = r.order_id
)

SELECT delivery_type, 
ROUND(AVG(review_score)::numeric, 2) AS avg_review
FROM reviews
GROUP BY delivery_type
ORDER BY avg_review DESC;
```
#### Query Results
```sql
 delivery_type | avg_review
---------------+------------
 On Time       |       4.29
 Late          |       2.46
(2 rows)
```