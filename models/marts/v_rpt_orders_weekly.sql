{{ config(materialized='view') }}

with orders as (
    select
        o.order_id,
        s.order_date,
        s.status,
        s.load_date
    from {{ ref('hub_order') }} o
    inner join {{ ref('sat_order') }} s
        on o.order_hash = s.order_hash
),

dedup as (
    select
        order_id,
        order_date,
        status,
        row_number() over (
            partition by order_id
            order by load_date desc
        ) as rn
    from orders
)

select
    date_trunc('week', order_date)::date as order_week,
    count(*)                             as orders_cnt
from dedup
where rn = 1
group by 1
order by 1
