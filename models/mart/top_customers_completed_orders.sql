{{ config(materialized='table') }}

WITH completed_orders AS (
    SELECT 
        user_id,
        COUNT(*) AS completed_order_count
    FROM {{ ref('stg_orders') }} so
    WHERE LOWER(so.status) = 'завершен'
    GROUP BY user_id
),
customer_info AS (
    SELECT 
        sc.id,
        sc.first_name,
        sc.last_name,
        sc.email
    FROM {{ ref('stg_customers') }} sc
)

SELECT 
    ci.*,
    COALESCE(co.completed_order_count, 0) AS completed_orders_count
FROM customer_info ci
LEFT JOIN completed_orders co ON ci.id = co.user_id
ORDER BY COALESCE(co.completed_order_count, 0) DESC