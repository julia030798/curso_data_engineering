
{{
  config(
    materialized='table'
  )
}}

with agg_users_sessions as (
    select
        f.id_session,
        u.id_user,
        u.first_name,
        u.last_name,
        u.email,
        u.phone_number,
        u.address,
        u.zipcode,
        u.state,
        u.country,
        min(d.date) as session_start_date,
        max(d.date) as session_end_date,
        i.session_start_time,
        i.session_end_time,
        i.duration_minutes,
        i.duration_hours,
        count(distinct f.id_page) as num_page_views,
        sum(case when e.event_type = 'page_view' then 1 else 0 end) as event_page_view,
        sum(case when e.event_type = 'add_to_cart' then 1 else 0 end) as event_add_to_cart,
        sum(case when e.event_type = 'checkout' then 1 else 0 end) as event_checkout,
        sum(case when e.event_type = 'package_shipped' then 1 else 0 end) as event_package_shipped
    from
        {{ ref('fct_page_logs') }} f
        join {{ ref('dim_sessions') }} s 
        on f.id_session = s.id_session
        join {{ ref('dim_users') }} u 
        on f.id_user = u.id_user
        join {{ ref('dim_date') }} d
        on f.id_date_created= d.id_date
        left join {{ ref('dim_events') }} e 
        on f.id_event = e.id_event
        left join {{ ref('int_session_duration') }} i
        on f.id_session = i.id_session
    group by
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 16
)

select * from agg_users_sessions