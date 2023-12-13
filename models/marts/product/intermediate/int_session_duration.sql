
{{
  config(
    materialized='ephemeral'
  )
}}

with session_durations as (
    select
        s.id_session,
        min(t.time_utc) as session_start_time,
        max(t.time_utc) as session_end_time,
        datediff(minute, min(t.time_utc), max(t.time_utc)) as duration_minutes,
        datediff(hour, min(t.time_utc), max(t.time_utc)) as duration_hours
    from
        {{ ref('fct_page_logs') }} f
        join {{ ref('dim_sessions') }} s 
        on f.id_session = s.id_session
        join {{ ref('dim_time_of_day') }} t 
        on f.id_time_created = t.id_time
    group by 1
)

select * from session_durations
