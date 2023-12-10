
{{
  config(
    materialized='incremental'
  )
}}

with stg_orders_order_items as 
(
    select 
          o.id_order
        , o.id_product
        , o.id_user
        , o.id_address
        , o.id_promo
        , o.id_tracking
        , o.id_date_created
        , o.id_date_estimated_delivery
        , o.id_date_delivered
        , o.date_load_utc
        , i.quantity
        , p.price_usd::decimal(7,2) as item_cost_usd
        , ((p.price_usd / o.order_total_usd) * o.shipping_cost_usd)::decimal(7,2) AS shipping_cost_item_usd
        , p.inventory
    from {{ ref("stg_sql_server_dbo_orders") }} o
    left join
    {{ ref("stg_sql_server_dbo_order_items") }} i 
    on o.id_order=i.id_order
    left join
    {{ ref("stg_sql_server_dbo_products") }} p
    on o.id_product=p.id_product
{% if is_incremental() %}

	  where o.date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
),

fct_order_items as (
    select *
    from stg_orders_order_items
)

select * from fct_order_items