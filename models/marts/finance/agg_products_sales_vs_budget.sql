
{{
  config(
    materialized='table'
  )
}}

with product_sales_month as (
    select
        oi.id_product,
        d.year_number as year_sale,
        d.month_of_year as month_sale,
        sum(oi.item_cost_usd) as total_sales_product_month_usd,
        sum(oi.shipping_cost_item_usd) as total_shipping_cost_product_month_usd,
        count(distinct oi.id_order) as total_orders
    from {{ ref('fct_order_items') }} oi
    join {{ ref('dim_date') }} d on oi.id_date_created = d.id_date
    group by 1, 2, 3
),

product_budget as (
    select
        b.id_product,
        d.year_number as year,
        d.month_of_year as month,
        sum(b.quantity) as budget
    from {{ ref('fct_budget') }} b
    join {{ ref('dim_date') }} d on b.id_date_month = d.id_date
    group by 1, 2, 3
)

select
    pb.id_product,
    dp.product_desc,
    pb.year,
    pb.month,
    pb.budget,
    psm.total_sales_product_month_usd,
    psm.total_shipping_cost_product_month_usd,
    psm.total_orders,
    case when psm.total_sales_product_month_usd > pb.budget then true else false end as over_budget
from product_budget pb
left join {{ ref('dim_products') }} dp 
on pb.id_product = dp.id_product
left join product_sales_month psm 
on pb.id_product = psm.id_product and pb.year = psm.year_sale and pb.month = psm.month_sale
order by pb.year, pb.month, pb.id_product