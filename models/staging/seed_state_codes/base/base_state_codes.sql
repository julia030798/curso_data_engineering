
{{
  config(
    materialized='view'
  )
}}

with base_state_codes as (
    select 
          State
        , Code 
    from {{ ref('seed_state_codes') }}
)

select * from base_state_codes

