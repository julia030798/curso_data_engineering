
{{
  config(
    materialized='incremental'
    , unique_key = 'id_promo'
    , on_schema_change='fail'
  )
}}

with dim_promos as (
    select *
    from {{ ref('stg_sql_server_dbo_promos') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
)

select
    id_promo,
    promo_desc,
    discount_usd,
    status,
    date_load_utc
from dim_promos
order by status