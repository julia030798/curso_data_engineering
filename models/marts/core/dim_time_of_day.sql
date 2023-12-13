
{{ 
    config(
          materialized='table'
        , unique_key = 'id_time'
        ) }}

with dim_time as 
(
      {{ dbt_utils.date_spine(
      datepart="second"
    , start_date="'00:00:00'::time"
    , end_date="'23:59:59'::time"
   )
}}
),

dim_time_null as (
    select
          date_second
        , date_second as time_utc
        , extract(hour from date_second) as hour_of_day
        , extract(minute from date_second) as minute_of_hour
        , extract(second from date_second) as second_of_minute
        -- Day periods
        , case 
            when date_second < '12:00:00' then 'am'
            else 'pm' end as period_of_day
        , case 
            when date_second::time between '06:00:00' and '08:29:59' then 'Morning'
            when date_second::time between '08:30:00' and '11:59:59' then 'Midday'
            when date_second::time between '12:00:00' and '17:59:59' then 'Afternoon'
            when date_second::time between '18:00:00' and '22:29:59' then 'Evening'
            else 'Night'
          end as daytime_name
        -- Indicator of day or night
        , case 
            when date_second::time between '07:00:00' and '19:59:59' then 'Day'
            else 'Night'
          end as day_night
    from dim_time
    union all
    select
          null
        , null 
        , null
        , null
        , null
        , null
        , null
        , null
)

select 
    {{ dbt_utils.generate_surrogate_key(['date_second']) }} as id_time
    , time_utc
    , hour_of_day
    , minute_of_hour
    , second_of_minute
    , period_of_day
    , daytime_name
    , day_night
from dim_time_null
where id_time is not null
