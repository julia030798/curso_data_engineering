
{{
  config(
    materialized='incremental'
    , unique_key = 'id_tracking'
  )
}}

with stg_orders_addresses as (
    select 
          o.id_tracking
        , o.shipping_service
        , o.status
        , o.id_address
        , a.address
        , a.zipcode
        , a.state
        , a.country
        , o.date_load_utc
    from {{ ref('stg_sql_server_dbo_orders') }} o
    left join
    {{ ref('stg_sql_server_dbo_addresses') }} a
    on o.id_address=a.id_address

{% if is_incremental() %}

    where o.date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
),

dim_shipping as (
    select
          id_tracking
        , shipping_service
        , status
        , address
        , zipcode
        , state
        , country
        , date_load_utc
    from stg_orders_addresses
    where id_tracking is not null
)

select * 
from dim_shipping
order by status
