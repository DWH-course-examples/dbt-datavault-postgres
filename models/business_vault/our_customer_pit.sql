with all_history (
    select hc.customer_pk,
    sc.last_name,
    sc.first_name,
    scc.age,
    sc.effective_from as sc_effective_from,
                  coalesce(lead(sc.effective_from) OVER (PARTITION BY hc.customer_pk ORDER BY sc.effective_from), '9999-12-31') as sc_effective_to,
    scc.effective_from as scc_effective_from,
                  coalesce(lead(scc.effective_from) OVER (PARTITION BY hc.customer_pk ORDER BY scc.effective_from), '9999-12-31') as scc_effective_to
    from {{ref('hub_customer')}} hc
    LEFT JOIN {{ref('sat_customer')}} sc ON sc.customer_pk = hc.customer_pk
    LEFT JOIN {{ref('sat_customer_crm')}} scc ON scc.customer_pk = hc.customer_pk
)

SELECT customer_pk, last_name, first_name, age, sc_effective_from, scc_effective_from
from all_history
where 1=1