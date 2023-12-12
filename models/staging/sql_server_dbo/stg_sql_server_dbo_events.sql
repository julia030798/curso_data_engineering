
/*
    Staging Model: stg_sql_server_dbo_events

    This dbt model stages raw event data capturing significant user interactions on a eCommerce
    platform from the source SQL Serves table 'events'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
      materialized='incremental'
    , unique_key = 'id_event'
  )
}}

with src_events as (
    select 
          event_id
        , page_url::varchar(500) as page_url
        , event_type::varchar(50) as event_type
        , user_id
        , decode(product_id, '', null, product_id) as id_product
        , session_id
        , decode(order_id, '', null, order_id) as id_order
        , created_at::date as created_date_utc
        , created_at::time as created_time_utc
        , _fivetran_synced
    from {{ source('sql_server_dbo', 'events') }}
{% if is_incremental() %}

	  where _fivetran_synced > (select max(date_load_utc) from {{ this }} )

{% endif %}
    ),

stg_events as (
    select
          {{ dbt_utils.generate_surrogate_key(['event_id']) }} as id_event
        , {{ dbt_utils.generate_surrogate_key(['page_url']) }} as id_page
        , page_url
        , event_type
        , {{ dbt_utils.generate_surrogate_key(['user_id']) }} as id_user
        , case
            when id_product is null then null
            else {{ dbt_utils.generate_surrogate_key(['id_product']) }} 
          end as id_product
        , session_id as id_session
        , {{ dbt_utils.generate_surrogate_key(['created_date_utc']) }} as id_date_created
        , {{ dbt_utils.generate_surrogate_key(['created_time_utc']) }} as id_time_created
        , case
            when id_order is null then null
            else {{ dbt_utils.generate_surrogate_key(['id_order']) }} 
          end as id_order
        , {{ dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} as date_load_utc
    from src_events
    )

select * from stg_events