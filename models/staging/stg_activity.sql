{{ config(materialized = 'table')}}

with overall as (
 select 
 activity_id,
 type as activity_type,
 assigned_to_user,
 deal_id,
 done,
 due_to::timestamp as due_to,
  row_number() over (partition by activity_id order by due_to::timestamp asc) as rn
 from {{ source('dwh_raw', 'activity') }}
)
select * from 
overall 
where rn = 1