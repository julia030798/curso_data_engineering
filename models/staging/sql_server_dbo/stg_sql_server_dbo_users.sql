
/*
    Staging Model: stg_sql_server_dbo_users

    This dbt model stages raw user data from the source SQL Server table 'users', containing 
    details about registered eCommerceplatform users.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
    materialized='view'
    , unique_key='id_user'
    , on_schema_change='fail'
  )
}}

with src_users as (
    select
          user_id
        , first_name::varchar(50) as first_name
        , last_name::varchar(50) as last_name
        , email::varchar(500) as email
        , phone_number::varchar(50) as phone_number
        , address_id
        , created_at
        , updated_at
        , _fivetran_synced
    from {{ source('sql_server_dbo', 'users') }}
    ),

stg_users as (
    select
           {{ dbt_utils.generate_surrogate_key(['user_id']) }} as id_user
         , first_name
         , last_name
         , email
         , phone_number
         , {{ dbt_utils.generate_surrogate_key(['address_id']) }} as id_address
        , {{ dbt_date.convert_timezone("created_at", "America/Los_Angeles", "UTC") }} as created_at_utc
        , {{ dbt_date.convert_timezone("updated_at", "America/Los_Angeles", "UTC") }} as updated_at_utc
        , {{ dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} AS date_load_utc
    from src_users
    )

select * from stg_users