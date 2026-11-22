{{ config(materialized='view') }}

with completed as (
    select distinct
        l.customer_hash,
        l.order_hash
    from {{ ref('link_order_customer') }} l
    inner join {{ ref('sat_order') }} s
        on l.order_hash = s.order_hash
    where s.status = 'completed'
),

customer_orders as (
    select
        customer_hash,
        count(distinct order_hash) as completed_cnt
    from completed
    group by customer_hash
),

customers_latest as (
    select customer_hash, first_name, last_name
    from (
        select
            customer_hash, first_name, last_name,
            row_number() over (
                partition by customer_hash
                order by load_date desc
            ) as rn
        from {{ ref('sat_customer') }}
    ) t
    where rn = 1
)

select
    h.customer_id,
    cl.first_name,
    cl.last_name,
    coalesce(co.completed_cnt, 0) as completed_cnt
from {{ ref('hub_customer') }} h
left join customer_orders co
    on h.customer_hash = co.customer_hash
inner join customers_latest cl
    on h.customer_hash = cl.customer_hash
order by completed_cnt desc

