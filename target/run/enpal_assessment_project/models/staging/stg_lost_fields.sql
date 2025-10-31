
  
    

  create  table "postgres"."staging"."stg_lost_fields__dbt_tmp"
  
  
    as
  
  (
    


select 
id as field_id,
name as field_name,
value  ->> 'id' as lost_id, 
value ->> 'label' as lost_label
from  "postgres"."public"."fields",
 jsonb_array_elements(field_value_options::jsonb) as value
 where field_key = 'lost_reason'
  );
  