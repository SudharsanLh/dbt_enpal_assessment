{{ config(materialized = 'table')}}

 select 
 stage_id,
 stage_name
  from {{ source('dwh_raw', 'stages') }}