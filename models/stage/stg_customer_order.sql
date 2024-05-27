with stg_orders as (
    select ORDER_KEY, ORDER_PK, user_id from {{ref('stg_orders')}}
),

stg_customers as (
    select id, CUSTOMER_KEY, CUSTOMER_PK from {{ref('stg_customers')}}
)

select  ORDER_KEY, CUSTOMER_KEY, CUSTOMER_PK, ORDER_PK from stg_orders so
JOIN stg_customers sc ON sc.id = so.user_id
