{{
  config(
      materialized='incremental'
  )
}}

with stg_events as (
    select *
    from {{ ref('stg_sql_server_dbo_events') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
)

select 
    id_event
    , id_page
    , id_user
    , id_session
    , id_product
    , id_order
    , id_date_created
    , id_time_created
from stg_events