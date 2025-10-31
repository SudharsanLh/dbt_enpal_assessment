{{ config(materialized = 'table')}}

 select 
 id as activity_type_id,
 name as activity_name,
 active,
 type as activity_type from {{ source('dwh_raw', 'activity_types') }}