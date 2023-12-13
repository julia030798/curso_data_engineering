
{{
  config(
    materialized='ephemeral'
  )
}}

with stg_orders_order_items_products as (
    select 
          o.id_order
        , o.id_user
        , o.id_address
        , o.id_promo
        , o.id_tracking
        , o.id_date_created
        , o.id_time_created
        , o.id_date_estimated_delivery
        , o.id_time_estimated_delivery
        , o.id_date_delivered
        , o.id_time_delivered
        , o.date_load_utc
        , o.order_total_usd
        , o.shipping_cost_usd
        , i.quantity
        , p.id_product
        , p.price_usd
        , p.inventory
    from {{ ref("stg_sql_server_dbo_orders") }} o
    left join {{ ref("stg_sql_server_dbo_order_items") }} i on o.id_order = i.id_order
    left join {{ ref("stg_sql_server_dbo_products") }} p on i.id_product = p.id_product
),

-- Calculate metrics
int_orders_pivoted as (
    select
          id_order
        , id_user
        , id_address
        , id_promo
        , id_tracking
        , id_date_created
        , id_time_created
        , id_date_estimated_delivery
        , id_time_estimated_delivery
        , id_date_delivered
        , id_time_delivered
        , date_load_utc
        , id_product
        , quantity
        , price_usd::decimal(7,2) as item_cost_usd
        , ((item_cost_usd / order_total_usd) * 100)::decimal(7,2) as percentage_of_order_cost
        , ((price_usd / order_total_usd) * shipping_cost_usd)::decimal(7,2) AS shipping_cost_item_usd
        , ((shipping_cost_item_usd / shipping_cost_usd) * 100)::decimal(7,2) as percentage_of_shipping_cost
        , inventory
        , inventory * price_usd::decimal(7,2) as inventory_value
        , date_load_utc
    from stg_orders_order_items_products
)

select * from int_orders_pivoted
