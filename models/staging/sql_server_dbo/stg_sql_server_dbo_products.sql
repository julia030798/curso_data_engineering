
/*
    Staging Model: stg_sql_server_dbo_products

    This dbt model stages raw product data available from the source SQL Server table 'products'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
    materialized='view'
    , unique_key='id_product'
    , on_schema_change='fail'
  )
}}

with src_products as (
    select 
        product_id
        , name::varchar(50) as product_desc
        , price::float as price_usd
        , inventory::integer as inventory
        , _fivetran_synced
    from {{ source('sql_server_dbo', 'products') }}
    ),

stg_products as (
    select
          {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS id_product
        , name
        , price_usd
        , inventory
        , {{ dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} AS date_load_utc
    from src_products
    )

select * from stg_products