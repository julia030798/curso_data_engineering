
{{ 
    config(
        materialized='table'
        , unique_key = 'id_date'
        , sort='date_day'
        , dist='date_day'
        , pre_hook="alter session set timezone = 'Europe/Madrid'; alter session set week_start = 7;" 
        ) }}

with dim_date as (
  {{ dbt_date.get_date_dimension("2020-01-01", "2040-12-31") }}
),

dim_date_null as (
    select
          date_day
        , date_day as date
        , day_of_week
        , day_of_week_name as day_desc
        , day_of_month
        , day_of_year
        , week_of_year
        , month_of_year
        , month_name as month_desc
        , quarter_of_year
        , year_number
    from dim_date
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
        , null
        , null
        , null
)

select
      {{ dbt_utils.generate_surrogate_key(['date_day']) }} AS id_date
    , date
    , day_of_week
    , day_desc
    , day_of_month
    , day_of_year
    , week_of_year
    , month_of_year
    , month_desc
    , quarter_of_year
    , year_number
from dim_date_null
order by
    date_day desc