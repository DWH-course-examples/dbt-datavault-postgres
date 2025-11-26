with ord_stat as(
select 
	hc.customer_key  , count(distinct ho.order_key) as order_count  
from 
	{{ref('link_customer_order')}}  lco 
	inner join {{ref('hub_order')}} ho on ho.order_pk = lco.order_pk 
	inner join {{ref('sat_order')}} so on so.order_pk  = lco.order_pk 
	inner join {{ref('hub_customer')}} hc on hc.customer_pk =lco.customer_pk 
	where so.status ='completed'
	group by hc.customer_key
	)
select 
	hc.customer_key,
	coalesce(o.order_count,0) as order_count
from 
	{{ref('hub_customer')}} hc 
	left join ord_stat o on o.customer_key  = hc.customer_key 
order by 
	coalesce(o.order_count,0)  desc