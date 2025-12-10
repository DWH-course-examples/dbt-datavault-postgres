{{ config(materialized='table') }}

SELECT 
    DATE_TRUNC('week', so.order_date) AS week_start,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT so.user_id) AS unique_customers
FROM {{ ref('stg_orders') }} so
WHERE so.order_date IS NOT NULL
GROUP BY DATE_TRUNC('week', so.order_date)
ORDER BY week_start DESC