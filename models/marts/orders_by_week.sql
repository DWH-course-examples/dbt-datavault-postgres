{# Витрина: число заказов по календарной неделе, по последней версии сателлита. #}
{{ config(enabled=True) }}

with latest_order as (
    select
        order_pk,
        order_date,
        row_number() over (
            partition by order_pk
            order by load_date desc
        ) as rn
    from {{ ref('sat_order_details') }}
)

select
    date_trunc('week', order_date::date)::date as week,
    count(*) as orders_count
from latest_order
where rn = 1
group by 1
