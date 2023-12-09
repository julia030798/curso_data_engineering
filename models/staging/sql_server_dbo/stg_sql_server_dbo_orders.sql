
/*
    Staging Model: stg_sql_server_dbo_orders

    This dbt model stages raw order data about users from the source SQL Server table 'orders'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.

*/

{{
  config(
    materialized='view'
    , unique_key='id_order'
    , on_schema_change='fail'
  )
}}

with src_orders as (
    select
          order_id
        , decode (shipping_service, '', 'pending', shipping_service) as shipping_service
        , shipping_cost::float as shipping_cost_usd
        , user_id,
        , created_at
        , order_cost::float as order_cost_usd
        , status::varchar(50) as status
        , order_total::float as order_total_usd
        , address_id
        , estimated_delivery_at
        , delivered_at 
        , decode (tracking_id, '', 'pending', tracking_id) as id_tracking
        , decode (promo_id, '', 'No Promo', promo_id) AS id_promo
        , _fivetran_synced
    FROM {{ source('sql_server_dbo', 'orders') }}
    )

stg_orders as (
    select
          {{ dbt_utils.generate_surrogate_key(['order_id']) }} as id_order
        , shipping_service
        , shipping_cost_usd
        , {{ dbt_utils.generate_surrogate_key(['user_id']) }} as id_user
        , {{dbt_date.convert_timezone("created_at", "America/Los_Angeles", "UTC") }} as created_at_utc
        , order_cost_usd
        , status
        , order_total_usd
        , {{ dbt_utils.generate_surrogate_key(['address_id']) }} as id_address
        , {{dbt_date.convert_timezone("estimated_delivery_at", "America/Los_Angeles", "UTC") }} as estimated_delivery_at_utc
        , {{dbt_date.convert_timezone("delivered_at", "America/Los_Angeles", "UTC") }} as delivered_at_utc
        , {{dbt_utils.generate_surrogate_key(['tracking_id']) }} as id_tracking
        , {{dbt_utils.generate_surrogate_key(['promo_id']) }} as id_promo
        , {{dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} as date_load_utc
    from src_orders
    )

select * from stg_orders