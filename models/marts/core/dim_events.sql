
{{
  config(
      materialized='incremental'
    , unique_key = 'id_event'
  )
}}

with stg_events as (
    select 
          e.id_event
        , e.event_type
        , e.page_url
        , e.id_user
        , e.id_product
        , e.id_order
        , e.created_at_utc
        , e.date_load_utc
        , u.first_name
        , u.email
        , p.product_desc
    from {{ ref('stg_sql_server_dbo_events') }} e
    left join
    {{ ref('stg_sql_server_dbo_users') }} u
    on e.id_user=u.id_user
    left join
    {{ ref('stg_sql_server_dbo_products') }} p
    on e.id_product=p.id_product
{% if is_incremental() %}

	  where e.date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}
),

dim_events as (
    select
          id_event
        , event_type
        , page_url
        , first_name
        , email
        , product_desc 
        , created_at_utc
        , date_load_utc
    from stg_events
)

select * from dim_events