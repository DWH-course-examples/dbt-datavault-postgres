{{ config(materialized='incremental') }}

{%- set src_pk       = "customer_hash" -%}
{%- set src_hashdiff = "customer_hashdiff" -%}
{%- set src_payload  = ["first_name", "last_name", "email"] -%}
{%- set src_eff      = "load_date" -%}
{%- set src_ldts     = "load_date" -%}
{%- set src_source   = "record_source" -%}
{%- set source_model = "v_stg_customers" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}
