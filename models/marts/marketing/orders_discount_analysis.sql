
{{
  config(
    materialized='table'
  )
}}

with int_orders as (
    select
          id_order
        , has_discount
        , order_total_usd
        , discount_percentage
    from {{ ref('int_orders') }} 
),

orders_discount_analysis as (
    select
          sum(order_total_usd) as total_sales
        , count(*) as total_orders
        , sum(case 
                when has_discount = 1 then order_total_usd 
                else 0 
              end) as discounted_sales
        , sum(case 
                when has_discount = 0 then order_total_usd 
                else 0 
              end) as undiscounted_sales
        , avg(order_total_usd) as avg_order_total_usd
        , avg(case 
                when has_discount = 1 then order_total_usd 
                else null 
              end) as avg_discounted_order_total_usd
        , avg(case 
                when has_discount = 0 then order_total_usd 
                else null 
              end) as avg_undiscounted_order_total_usd
        , sum(case 
                when has_discount = 1 then 1 
                else 0 
              end) as discounted_orders
        , sum(case 
                when has_discount = 0 then 1 
                else 0 
              end) as undiscounted_orders
    from int_orders
)

select * from orders_discount_analysis