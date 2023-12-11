
{{ config(
    materialized='incremental',
    unique_key = 'id_budget'
    ) 
}}

with stg_budget as 
(
    select *
    from {{ ref('stg_google_sheets_budget') }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
),

fct_budget as (
    select
          id_budget
        , id_product
        , quantity
        , id_date_month
        , date_load_utc
    from stg_budget
)

select * from fct_budget

