
{{
  config(
    materialized='incremental'
    , on_schema_change='fail'
  )
}}

with fct_order_items as 
(
    select *
    from {{ ref("int_orders_pivoted_to_order_items") }}
{% if is_incremental() %}

	  where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
)

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
    , inventory
    , inventory_value
from fct_order_items