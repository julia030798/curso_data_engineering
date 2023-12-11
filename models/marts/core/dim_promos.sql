
{{
  config(
    materialized='incremental'
    , unique_key = 'id_promo'
  )
}}

with dim_promos as 
(
    select *
    from {{ ref('promos_snapshot') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
),

dim_promos as (
    select
        id_promo,
        promo_desc,
        discount_usd,
        status,
        date_load_utc
    from dim_promos
    where dbt_valid_to is null
    order by status
)

select * from dim_promos