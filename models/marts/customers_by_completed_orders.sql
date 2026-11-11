{# Витрина: клиенты по числу заказов с последним статусом completed. #}
{{ config(enabled=True) }}

with latest_customer as (
    select
        customer_pk,
        first_name,
        last_name,
        email,
        row_number() over (
            partition by customer_pk
            order by load_date desc
        ) as rn
    from {{ ref('sat_customer_details') }}
),
latest_order as (
    select
        order_pk,
        status,
        row_number() over (
            partition by order_pk
            order by load_date desc
        ) as rn
    from {{ ref('sat_order_details') }}
),
completed as (
    select
        l.customer_pk,
        count(distinct l.order_pk) as completed_orders
    from {{ ref('link_customer_order') }} as l
    inner join latest_order as o
        on o.order_pk = l.order_pk
        and o.rn = 1
        and o.status = 'completed'
    group by l.customer_pk
)

select
    c.email,
    c.first_name,
    c.last_name,
    coalesce(co.completed_orders, 0) as completed_orders
from {{ ref('hub_customer') }} as h
left join latest_customer as c
    on c.customer_pk = h.customer_pk
    and c.rn = 1
left join completed as co
    on co.customer_pk = h.customer_pk
order by 4 desc
