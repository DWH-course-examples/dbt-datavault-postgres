{# Хаб клиентов: одна строка на бизнес-ключ id. #}
{{ config(enabled=True) }}

{% set source_model = 'stg_customers' %}
{% set src_pk = 'CUSTOMER_PK' %}
{% set src_nk = 'CUSTOMER_KEY' %}
{% set src_ldts = 'LOAD_DATE' %}
{% set src_source = 'RECORD_SOURCE' %}

{{ automate_dv.hub(
    src_pk=src_pk,
    src_nk=src_nk,
    src_ldts=src_ldts,
    src_source=src_source,
    source_model=source_model
) }}