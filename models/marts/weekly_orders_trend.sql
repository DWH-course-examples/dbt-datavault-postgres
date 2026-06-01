{{ config(
    materialized='table',
    alias='weekly_orders_trend'
) }}

WITH weekly_orders AS (
  SELECT
    DATE_TRUNC('week', order_date) AS week_start,
    COUNT(*) AS weekly_order_count,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_orders,
    LAG(COUNT(*)) OVER (ORDER BY DATE_TRUNC('week', order_date)) AS prev_week_count
  FROM {{ ref('stg_orders') }}
  GROUP BY 1
)

SELECT
  week_start,
  weekly_order_count,
  completed_orders,
  prev_week_count,
  CASE
    WHEN prev_week_count IS NULL THEN NULL
    ELSE ROUND(
      (weekly_order_count - prev_week_count) * 100.0 / prev_week_count,
      2
    )
  END AS week_over_week_growth_pct
FROM weekly_orders
ORDER BY week_start DESC