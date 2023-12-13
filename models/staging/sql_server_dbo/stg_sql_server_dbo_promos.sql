
/*
    Staging Model: stg_sql_server_dbo_promos

    This dbt model stages raw data about available promotions from the source SQL Server 
    table 'promos'.

    Note: Configurations are defined in dbt_project.yml or can be overridden in SQL files.
*/

{{
  config(
    materialized='incremental'
    , unique_key='id_promo'
    , on_schema_change='fail'
  )
}}

with src_promos as (
    select
          lower(promo_id) as promo_desc
        , discount::int as discount_usd
        , status::varchar(50) as status
        , _fivetran_synced
    from {{ source('sql_server_dbo', 'promos') }}
{% if is_incremental() %}

	  where _fivetran_synced > (select max(date_load_utc) from {{ this }} )

{% endif %}
    ),

stg_promos as (
    select
          {{dbt_utils.generate_surrogate_key(['promo_desc'])}} as id_promo
        , promo_desc
        , discount_usd
        , status
        , {{ dbt_date.convert_timezone("_fivetran_synced", "America/Los_Angeles", "UTC") }} AS date_load_utc
    from src_promos
)

select * from stg_promos
union all
select
      {{dbt_utils.generate_surrogate_key(['promo_desc'])}} as id_promo
    , 'no promo' as promo_desc
    , 0 as discount_usd
    , 'active' as status 
    , {{dbt_date.now("America/Los_Angeles")}} as date_load_utc