
{{
  config(
    materialized='table'
    , unique_key = 'id_user'
  )
}}

with stg_users_addresses as 
(
    select 
          u.id_user
        , u.first_name
        , u.last_name
        , u.email
        , u.phone_number
        , u.id_address
        , a.address
        , a.zipcode
        , a.state
        , a.country
        , u.created_at_utc
        , u.updated_at_utc
        , u.date_load_utc 
    from {{ ref('stg_sql_server_dbo_users') }} u
    left join
    {{ ref('stg_sql_server_dbo_addresses') }} a
    on u.id_address=a.id_address
),

dim_users as (
    select 
          id_user
        , first_name
        , last_name
        , email
        , phone_number
        , address
        , zipcode
        , state
        , country
        , created_at_utc
        , updated_at_utc
        , date_load_utc 
    from stg_users_addresses
)

select * from dim_users
