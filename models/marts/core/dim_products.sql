
{{
  config(
    materialized='table'
    , unique_key = 'id_product'
  )
}}

with dim_products as (
    select *
    from {{ ref('stg_sql_server_dbo_products') }}
)

select
      id_product
    , product_desc
    , date_load_utc
from dim_products