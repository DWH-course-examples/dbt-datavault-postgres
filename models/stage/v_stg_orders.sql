with source as (
    select * from {{ ref('source_orders') }}
),

renamed as (
    select
        md5(cast(id as varchar))                         as order_hash,
        md5(cast(user_id as varchar))                    as customer_hash,
        md5(cast(id as varchar) || '|' ||
            cast(user_id as varchar))                    as link_order_hash,
        md5(coalesce(cast(order_date as varchar), '') || '|' ||
            coalesce(status, ''))                        as order_hashdiff,
        cast(id as integer)                              as order_id,
        cast(user_id as integer)                         as customer_id,
        order_date,
        status,
        'orders_csv'                                     as record_source,
        current_timestamp                                as load_date
    from source
)

select * from renamed
