
/*
    Staging Model: stg_sql_server_dbo_addresses

    This dbt model stages raw address data about users from the source SQL Serves table 
    'addresses'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
      materialized='view'
    , unique_key='id_address'
    , on_schema_change='fail'
  )
}}

with stg_addresses as (
    select 
          a.id_address
        , a.address
        , a.zipcode
        , a.state
        , s.Code
        , a.country
        , a.date_load_utc
    from {{ ref('base_sql_server_dbo_addresses') }} a 
    left join {{ ref('base_state_codes') }} s
    on a.state=s.state
    )

select * from stg_addresses

