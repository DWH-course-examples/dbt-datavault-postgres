{{ 
    config(
    materialized='table',
    schema='analytics',
    tags=['analytics', 'orders']
) 
}}

with orders as (
    SELECT 
        ho.order_pk
    FROM 
        {{ ref('hub_order') }} ho
    JOIN (
        SELECT 
            so.order_pk,
            MAX(so.effective_from) AS latest_date
        FROM 
            {{ ref('sat_order') }} so 
        GROUP BY 
            so.order_pk
    ) latest 
        ON ho.order_pk = latest.order_pk
    JOIN 
      {{ ref('sat_order') }} so 
        ON so.order_pk = latest.order_pk 
           AND so.effective_from = latest.latest_date
    where 
        so.status ='completed'
),

customers as (
    SELECT 
        hc.customer_pk,
        concat(sc.first_name, ' ',sc.last_name) as customer_name
    FROM 
        {{ ref('hub_customer') }} hc
    JOIN (
        SELECT 
            sc.customer_pk,
            MAX(sc.effective_from) AS latest_date
        FROM 
            {{ ref('sat_customer') }} sc 
        GROUP BY 
            sc.customer_pk
    ) latest 
        ON hc.customer_pk = latest.customer_pk
    JOIN 
      {{ ref('sat_customer') }} sc  
        ON sc.customer_pk = latest.customer_pk 
           AND sc.effective_from = latest.latest_date
),

customers_crm as(
    SELECT 
        hc.customer_pk,
        concat(sc.country, ' ',sc.age) as customer_name
    FROM 
        {{ ref('hub_customer') }} hc
    JOIN (
        SELECT 
            sc.customer_pk,
            MAX(sc.effective_from) AS latest_date
        FROM 
            {{ ref('sat_customer_crm') }} sc 
        GROUP BY 
            sc.customer_pk
    ) latest 
        ON hc.customer_pk = latest.customer_pk
    JOIN 
      {{ ref('sat_customer_crm') }} sc  
        ON sc.customer_pk = latest.customer_pk 
           AND sc.effective_from = latest.latest_date
)

select 
    cust.customer_name,
    count(o.order_pk) as count_orders
from
    orders o
join 
    {{ ref('link_customer_order') }} lco 
    on o.order_pk = lco.order_pk
join (
        select
            customer_name,
            customer_pk
        from
            customers c
        union all
        select
            customer_name,
            customer_pk
        from
            customers_crm cc
    ) cust
    on lco.customer_pk = cust.customer_pk
group by cust.customer_name
order by count_orders desc