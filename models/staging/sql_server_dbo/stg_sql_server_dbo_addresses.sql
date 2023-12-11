
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

with src_addresses as (
    select *
    from {{ source('sql_server_dbo', 'addresses') }}
    ),

stg_addresses as (
    select 
          {{ dbt_utils.generate_surrogate_key(['address_id']) }} as id_address
        , address::varchar(50) as address
        , zipcode::int as zipcode
        , state::varchar(50) as state
        , country::varchar(50) as country
        , {{ dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} as date_load_utc
    from src_addresses
    )

select * from stg_addresses

