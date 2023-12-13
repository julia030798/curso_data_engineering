
{{
  config(
    materialized='incremental'
    , unique_key = 'id_session'
    , on_schema_change='fail'
  )
}}

with dim_sessions as (
    select distinct
          id_user
        , id_session
        , date_load_utc
    from {{ ref('stg_sql_server_dbo_events') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
)

select 
      s.id_session
    , u.first_name
    , u.last_name
    , u.email
    , s.date_load_utc
from dim_sessions s
left join {{ ref('stg_sql_server_dbo_users') }} u
on s.id_user=u.id_user
