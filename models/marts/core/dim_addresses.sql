
{{ config(
    materialized='table'
    , unique_key = 'id_address'
    ) 
    }}


with stg_addresses as (
    select * 
    from {{ ref('stg_sql_server_dbo_addresses') }}
    ),

dim_addresses as (
    select
          id_address
        , address
        , zipcode
        , state
        , Code
        , country
        , date_load_utc
    from stg_addresses
)

select * from dim_addresses