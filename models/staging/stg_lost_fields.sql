{{ config(materialized = 'table')}}


select 
id as field_id,
name as field_name,
value  ->> 'id' as lost_id, 
value ->> 'label' as lost_label
from  {{ source('dwh_raw', 'fields') }},
 jsonb_array_elements(field_value_options::jsonb) as value
 where field_key = 'lost_reason'



