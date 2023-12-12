
{{
  config(
    materialized='table'
  )
}}

with fct_order_items as 
(
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
        , item_cost_usd
        , percentage_of_order_cost
        , shipping_cost_item_usd
        , percentage_of_shipping_cost
        , product_profit
        , inventory
        , inventory_value
    from {{ ref("int_orders_pivoted_to_order_items") }}
)

select * 
from fct_order_items