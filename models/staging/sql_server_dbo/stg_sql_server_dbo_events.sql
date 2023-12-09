
/*
    Staging Model: stg_sql_server_dbo_events

    This dbt model stages raw event data capturing significant user interactions on a eCommerce
    platform from the source SQL Serves table 'events'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
    materialized='view'
    , unique_key='id_event'
    , on_schema_change='fail'
  )
}}

with src_events as (
    select 
          event_id
        , page_url::varchar(500) as page_url
        , event_type::varchar(50) as event_type
        , user_id
        , decode(product_id, '', null, product_id) as id_product
        , session_id
        , decode(order_id, '', null, order_id) as id_order
        , created_at
        , _fivetran_synced
    from {{ source('sql_server_dbo', 'events') }}
    ),

stg_events as (
    select
          {{ dbt_utils.generate_surrogate_key(['event_id']) }} as id_event
        , page_url
        , event_type
        , {{ dbt_utils.generate_surrogate_key(['user_id']) }} as id_user
        , {{ dbt_utils.generate_surrogate_key(['id_product']) }} as id_product
        , session_id
        , {{ dbt_date.convert_timezone("created_at", "America/Los_Angeles", "UTC") }} as created_at_utc
        , {{ dbt_utils.generate_surrogate_key(['id_order']) }} as id_order
        , {{ dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} as date_load_utc
    from src_events
    )

select * from stg_events