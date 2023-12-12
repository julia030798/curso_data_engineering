
{{
  config(
    materialized='incremental'
    , unique_key = 'id_event'
    , on_schema_change='fail'
  )
}}

with dim_events as (
    select *
    from {{ ref('stg_sql_server_dbo_events') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
)

select 
      id_event
    , event_type
from dim_events