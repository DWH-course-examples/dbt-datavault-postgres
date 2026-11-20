{{ config(materialized='view') }}

with ranked_orders as (

    select
        order_pk,
        status,
        row_number() over (
            partition by order_pk
            order by
                load_date desc,
                effective_from desc,
                order_hashdiff desc
        ) as rn
    from {{ ref('sat_order') }}

),

completed_orders as (

    select order_pk
    from ranked_orders
    where rn = 1
      and status = 'completed'

),

customer_order_pairs as (

    select distinct
        customer_pk,
        order_pk
    from {{ ref('link_customer_order') }}

),

completed_counts as (

    select
        l.customer_pk,
        count(*) as completed_orders_count
    from customer_order_pairs l
    inner join completed_orders o
        on o.order_pk = l.order_pk
    group by l.customer_pk

),

ranked_customers as (

    select
        customer_pk,
        first_name,
        last_name,
        row_number() over (
            partition by customer_pk
            order by
                load_date desc,
                effective_from desc,
                customer_hashdiff desc
        ) as rn
    from {{ ref('sat_customer') }}

)

select
    h.customer_pk,
    h.customer_key,
    c.first_name,
    c.last_name,
    coalesce(cc.completed_orders_count, 0) as completed_orders_count
from {{ ref('hub_customer') }} h
left join ranked_customers c
    on c.customer_pk = h.customer_pk
   and c.rn = 1
left join completed_counts cc
    on cc.customer_pk = h.customer_pk
