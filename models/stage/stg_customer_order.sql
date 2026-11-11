{# Соединение заказа с клиентом по user_id для расчёта ключа связи. #}
{{ config(enabled=True) }}

with stg_orders as (
    select order_key, order_pk, user_id
    from {{ ref('stg_orders') }}
),
stg_customers as (
    select id, customer_key, customer_pk
    from {{ ref('stg_customers') }}
)

select
    so.order_key,
    sc.customer_key,
    sc.customer_pk,
    so.order_pk
from stg_orders as so
inner join stg_customers as sc
    on sc.id = so.user_id