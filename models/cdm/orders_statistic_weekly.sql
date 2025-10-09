WITH order_list as (
    SELECT 
        so.ORDER_PK,
        date_trunc('weel', so.order_date) as order_date,
        so.status,
        row_number() over (partition by so.ORDER_PK order by so.EFFECTIVE_FROM desc) as row_num
    FROM {{ ref('sat_order') }} AS so
)
select 
    ol.order_date,
    ol.status,
    count(ol.ORDER_PK) as count
from order_list ol
where ol.row_num = 1
group by ol.order_date, ol.status