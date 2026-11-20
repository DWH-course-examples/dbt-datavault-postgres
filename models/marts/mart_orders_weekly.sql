{{ config(materialized='view') }}

with ranked_orders as (

    select
        order_pk,
        order_date,
        row_number() over (
            partition by order_pk
            order by
                load_date desc,
                effective_from desc,
                order_hashdiff desc
        ) as rn
    from {{ ref('sat_order') }}

),

latest_orders as (

    select
        order_pk,
        order_date
    from ranked_orders
    where rn = 1

)

select
    date_trunc('week', order_date)::date as week_start,
    count(*) as orders_count
from latest_orders
where order_date is not null
group by 1
