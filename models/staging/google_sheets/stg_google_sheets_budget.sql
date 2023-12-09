
/*
    Staging Model: stg_google_sheets_budget

    This dbt model stages raw budget data assigned to products in a specific month from 
    the source Google Sheets table 'budget'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
    materialized='view',
    unique_key='id_budget',
    on_schema_change='fail'
  )
}}

with src_budget as (
    select * 
    from {{ source('google_sheets', 'budget') }}
    ),

stg_budget as (
    select
        {{ dbt_utils.generate_surrogate_key(['product_id', 'month']) }} as id_budget,
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} as id_product,
        quantity::int as quantity,
        {{ dbt_utils.generate_surrogate_key(['month']) }} as id_date,
        _fivetran_synced as date_load,
    from src_budget
    )

select * from stg_budget