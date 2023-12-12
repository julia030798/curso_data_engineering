
{{ config(
    materialized='incremental'
    , unique_key = 'id_address'
    ) 
    }}


with stg_addresses as (
    select * 
    from {{ ref('stg_sql_server_dbo_addresses') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }})

{% endif %}
    ),

dim_addresses as (
    select
          id_address
        , address
        , zipcode
        , Code
        , state
        , country
        , date_load_utc
    from stg_addresses
)

select * from dim_addresses