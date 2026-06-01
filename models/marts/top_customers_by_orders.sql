{{ config(
    materialized='table',
    alias='top_customers_by_orders'
) }}

WITH completed_orders_per_customer AS (
  SELECT
    id AS id_from_orders,  -- явный алиас
    COUNT(*) AS completed_order_count
  FROM {{ ref('stg_orders') }}
  WHERE status = 'completed'
  GROUP BY 1
),

customer_info AS (
  SELECT
    c.id AS id,
    c.first_name,
    c.last_name,
    c.email,
    COALESCE(coc.completed_order_count, 0) AS completed_order_count
  FROM {{ ref('source_customers') }} c
  LEFT JOIN completed_orders_per_customer coc
    ON c.id = coc.id_from_orders  -- используем алиас из CTE
)

SELECT
  id,
  first_name,
  last_name,
  email,
  completed_order_count,
  RANK() OVER (ORDER BY completed_order_count DESC) AS customer_rank
FROM customer_info
ORDER BY completed_order_count DESC, id
