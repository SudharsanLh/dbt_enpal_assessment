{{ config(materialized = 'table')}}

select
  deal_id,
  change_time::timestamp as change_time_at,
  changed_field_key,
  new_value
from {{ source('dwh_raw', 'deal_changes') }}
