
/*
    Staging Model: stg_sql_server_dbo_addresses

    This dbt model stages raw address data about users from the source SQL Serves table 
    'addresses'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
    materialized='view',
    unique_key='id_address',
    on_schema_change='fail'
  )
}}

with src_addresses as (
    select *
    from {{ source('sql_server_dbo', 'addresses') }}
    ),

stg_addresses as (
    select 
        {{ dbt_utils.generate_surrogate_key(['address_id']) }} as id_address,
        address,
        zipcode::int as zipcode,
        state,
        country,
        {{ dbt_date.convert_timezone("_fivetran_synced", source_tz="UTC") }} as date_load_utc
    from srg_addresses
    )

select * from stg_addresses

