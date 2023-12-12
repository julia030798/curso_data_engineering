
{{
  config(
    materialized='table'
  )
}}

with ranked_products as (
    select
        a.state,
        d.date,
        d.month_desc,
        d.year_number,
        p.product_desc,
        sum(o.item_cost_usd) as total_price,
        sum(o.quantity) as units_sold,
        row_number() over(partition by a.state, d.date order by sum(o.quantity) desc) as product_rank
    from {{ ref('fct_order_items') }} o
    join {{ ref('dim_addresses') }} a 
    on o.id_address = a.id_address
    join {{ ref('dim_date') }} d 
    on o.id_date_created = d.id_date
    join {{ ref('dim_products') }} p 
    on o.id_product = p.id_product
    group by 1, 2, 3, 4, 5
)

select
    state,
    date,
    month_desc,
    year_number,
    product_desc as most_sold_product_desc,
    total_price as most_sold_product_price,
    units_sold
from ranked_products
where product_rank = 1
order by state, date