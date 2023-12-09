
/*
    Staging Model: stg_sql_server_dbo_order_items

    This dbt model stages detailed information about the products in each order from the source 
    SQL Server table 'order_items'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
    materialized='view'
    , unique_key='id_order_item'
    , on_schema_change='fail'
  )
}}

with src_order_items as (
    select
          order_id
        , product_id
        , quantity::int as quantity
        , _fivetran_synced
    from {{ source('sql_server_dbo', 'order_items') }}
    ),

stg_order_items as (
    select
          {{ dbt_utils.generate_surrogate_key(['order_id', 'product_id']) }} AS id_order_item
        , {{ dbt_utils.generate_surrogate_key(['order_id']) }} AS id_order
        , {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS id_product
        , quantity
        , {{ dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} AS date_load_utc
    from src_order_items
    )

select * from stg_order_items