
{{ config(
      materialized='incremental'
    , unique_key = 'id_event_type'
    ) 
}}

with stg_event_types AS (
    select distinct 
                  event_type_key
                , event_type
                , date_load_utc
    FROM {{ ref('stg_sql_server_dbo_events') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
)

select *
from stg_event_types