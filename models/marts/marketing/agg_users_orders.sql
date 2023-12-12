
{{
  config(
    materialized='table'
  )
}}

with agg_users_orders as (
    select
          u.id_user
        , u.first_name
        , u.last_name
        , u.email
        , u.phone_number
        , u.address
        , u.zipcode
        , u.state
        , a.Code
        , u.country
        , count(distinct oi.id_order) as total_orders
        , sum(oi.item_cost_usd) as total_spent
        , sum(oi.shipping_cost_item_usd) as total_shipping_cost
        , sum(dp.discount_usd) as total_discount
        , sum(oi.quantity) as total_products_purchased
        , count(distinct oi.id_product) as total_unique_products_purchased
    from {{ ref('dim_users') }} u
    left join {{ ref('fct_order_items') }} oi 
    on u.id_user = oi.id_user
    left join {{ ref('dim_promos') }} dp 
    on oi.id_promo = dp.id_promo
    left join {{ ref('dim_promos') }} a
    on oi.id_address=a.id_address
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
)

select * 
from agg_users_orders
