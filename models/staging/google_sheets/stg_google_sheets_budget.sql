
/*
    Staging Model: stg_google_sheets_budget

    This dbt model stages raw budget data assigned to products in a specific month from 
    the source Google Sheets table 'budget'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
      materialized='view'
    , unique_key='id_budget'
    , on_schema_change='fail'
  )
}}

with src_budget as (
    select 
          _row
        , product_id
        , quantity::int as quantity
        , month::date as date_month
        , _fivetran_synced
    from {{ source('google_sheets', 'budget') }}
    ),

stg_budget as (
    select
          {{ dbt_utils.generate_surrogate_key(['product_id', 'date_month']) }} as id_budget
        , {{ dbt_utils.generate_surrogate_key(['product_id']) }} as id_product
        , quantity
        , {{ dbt_utils.generate_surrogate_key(['date_month']) }} as id_date_month
        , {{ dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} as date_load_utc
    from src_budget
    )

select 
      id_budget
    , id_product
    , quantity
    , id_date_month
    , date_load_utc
from stg_budget