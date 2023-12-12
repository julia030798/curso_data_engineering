
{{
  config(
    materialized='table'
  )
}}

with agg_users_sessions as (
    select
          e.id_session
        , u.id_user
        , u.first_name
        , u.last_name
        , u.email
        , u.phone_number
        , u.address
        , u.zipcode
        , u.state
        , u.country
        , u.created_at_utc
        , u.updated_at_utc
        , d.date as session_date
        , t.time_utc as session_time
        , min(d.date) as session_start_date
        , max(d.date) as session_end_date
        , min(t.time_utc) as session_start_time
        , max(t.time_utc) as session_end_time
        , max(t.time_utc) - min(t.time_utc) as duration
        , count(distinct et.page_url) as num_page_views
    from {{ ref('fct_events') }} e
    join {{ ref('dim_users') }} u 
    on e.id_user = u.id_user
    join {{ ref('dim_date') }} d 
    on e.id_date_created = d.id_date
    join {{ ref('dim_time_of_day') }} t 
    on e.id_time_created = t.id_time
    join {{ ref('dim_event_type') }} et 
    on e.id_event_type = et.id_event_type
    group by 1, 2, 3, 4
)

select * from agg_users_sessions

