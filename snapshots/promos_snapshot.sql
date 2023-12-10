
{% snapshot promos_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='id_promo',
      strategy='timestamp',
      updated_at='date_load_utc',
    )
}}

with stg_promos_snapshot as 
(
    select *
    from {{ ref('stg_sql_server_dbo_promos') }}
)

select * from stg_promos_snapshot

{% endsnapshot %}