{{ config(materialized='incremental') }}

{%- set src_pk      = "link_order_hash" -%}
{%- set src_fk      = ["customer_hash", "order_hash"] -%}
{%- set src_ldts    = "load_date" -%}
{%- set src_source  = "record_source" -%}
{%- set source_model = "v_stg_orders" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk,
                    src_ldts=src_ldts, src_source=src_source,
                    source_model=source_model) }}
