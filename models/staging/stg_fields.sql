{{ config(materialized = 'table')}}

 select 
 id as field_id,
 field_key as field_key,
 name as field_name,
 field_value_options
  from {{ source('dwh_raw', 'fields') }}