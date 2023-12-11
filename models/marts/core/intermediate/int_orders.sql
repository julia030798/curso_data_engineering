
{{
  config(
    materialized='ephemeral'
  )
}}

with stg_orders_promos as (
    select
          o.id_order
        , o.order_cost_usd
        , o.shipping_cost_usd
        , o.order_total_usd
        , o.id_promo
        , p.discount_usd
        , p.status
    from {{ ref('stg_sql_server_dbo_orders') }} o
    left join
    {{ ref('stg_sql_server_dbo_promos') }} p
    on o.id_promo=p.id_promo
),

int_orders as (
    select
        id_order
        , order_cost_usd
        , shipping_cost_usd
        , case
            when status = 'active' then 1
            else 0
          end as has_discount
        , case
            when status = 'active' then (order_total_usd - discount_usd)
            else order_total_usd 
          end as order_total_usd
        , case
            when status = 'active' then round((discount_usd / order_total_usd) * 100, 1)
            else 0
          end as discount_percentage
    from stg_orders_promos
)
