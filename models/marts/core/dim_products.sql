
{{
  config(
    materialized='incremental'
    , unique_key = 'id_product'
  )
}}

with dim_products as (
    select *
    from {{ ref('stg_sql_server_dbo_products') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
)

select
      id_product
    , product_desc
    , date_load_utc
from dim_products