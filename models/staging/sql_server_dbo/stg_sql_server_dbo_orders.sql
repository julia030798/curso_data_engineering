
/*
    Staging Model: stg_sql_server_dbo_orders

    This dbt model stages raw order data about users from the source SQL Server table 'orders'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.

*/

{{
  config(
    materialized='incremental'
    , unique_key='id_order'
    , on_schema_change='fail'
  )
}}

with src_orders as (
    select
          order_id
        , decode (shipping_service, '', 'pending', shipping_service) as shipping_service
        , shipping_cost::float as shipping_cost_usd
        , user_id
        , created_at::date as created_date_utc
        , created_at::time as created_time_utc
        , order_cost::float as order_cost_usd
        , status::varchar(50) as status
        , order_total::float as order_total_usd
        , address_id
        , estimated_delivery_at::date as estimated_delivery_date_utc
        , estimated_delivery_at::time as estimated_delivery_time_utc
        , delivered_at::date as delivered_date_utc
        , delivered_at::time as delivered_time_utc
        , decode (tracking_id, '', 'pending', tracking_id) as id_tracking
        , decode (promo_id, '', 'no promo', promo_id) AS id_promo
        , {{ dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} as date_load_utc
    from {{ source('sql_server_dbo', 'orders') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
    ),

stg_orders as (
    select
          {{ dbt_utils.generate_surrogate_key(['order_id']) }} as id_order
        , shipping_service
        , shipping_cost_usd
        , {{ dbt_utils.generate_surrogate_key(['user_id']) }} as id_user
        , {{ dbt_utils.generate_surrogate_key(['created_date_utc']) }} as id_date_created
        , {{ dbt_utils.generate_surrogate_key(['created_time_utc']) }} as id_time_created
        , order_cost_usd
        , status
        , order_total_usd
        , {{ dbt_utils.generate_surrogate_key(['address_id']) }} as id_address
        , {{ dbt_utils.generate_surrogate_key(['estimated_delivery_date_utc']) }} as id_date_estimated_delivery
        , {{ dbt_utils.generate_surrogate_key(['estimated_delivery_time_utc']) }} as id_time_estimated_delivery
        , {{ dbt_utils.generate_surrogate_key(['delivered_date_utc']) }} as id_date_delivered
        , {{ dbt_utils.generate_surrogate_key(['delivered_time_utc']) }} as id_time_delivered
        , case
            when id_tracking = 'pending' then null
            else {{dbt_utils.generate_surrogate_key(['id_tracking']) }} 
          end as id_tracking
        , {{ dbt_utils.generate_surrogate_key(['id_promo']) }} as id_promo
        , date_load_utc
    from src_orders
    )

select * from stg_orders