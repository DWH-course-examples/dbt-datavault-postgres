{{
    config(
        materialized='view',
        schema='analytics',
        tags=['weekly_reports']
    )
}}

with cte as (
	SELECT 
	    ho.order_pk,
	    so.order_hashdiff, 
        date_trunc('week', so.order_date) as week_start
	FROM 
	    {{ ref('hub_order') }}  ho
	JOIN (
	    SELECT 
	        so.order_pk,
	        MAX(so.effective_from) AS latest_date
	    FROM 
	        {{ ref('sat_order') }}  so 
	    GROUP BY 
	        so.order_pk
	) latest 
		ON ho.order_pk = latest.order_pk
	JOIN 
	  {{ ref('sat_order') }}  so 
	  	ON so.order_pk = latest.order_pk 
	       AND so.effective_from = latest.latest_date
)
select
    week_start,
    count(*) as count_orders
from 
    cte
group by week_start
order by week_start