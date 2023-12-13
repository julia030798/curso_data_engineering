
{{
  config(
    materialized='incremental'
    , unique_key = 'id_page'
    , on_schema_change='fail'
  )
}}

with dim_page as (
    select distinct
        id_page
        , page_url
        date_load_utc
    from {{ ref('stg_sql_server_dbo_events') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
)

select *
from dim_page