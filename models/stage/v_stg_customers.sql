with source as (
    select * from {{ ref('source_customers') }}
),

renamed as (
    select
        md5(cast(id as varchar))                         as customer_hash,
        md5(cast(id as varchar) || '|' ||
            coalesce(first_name, '') || '|' ||
            coalesce(last_name, '')  || '|' ||
            coalesce(email, ''))                         as customer_hashdiff,
        cast(id as integer)                              as customer_id,
        first_name,
        last_name,
        email,
        'customers_csv'                                  as record_source,
        current_timestamp                                as load_date
    from source
)

select * from renamed
