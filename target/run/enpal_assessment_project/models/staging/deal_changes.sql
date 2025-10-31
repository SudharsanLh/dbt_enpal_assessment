
  
    

  create  table "postgres"."staging"."deal_changes__dbt_tmp"
  
  
    as
  
  (
    

select
  deal_id,
  change_time::timestamp as change_time_at,
  changed_field_key,
  new_value
from "postgres"."public"."deal_changes"
  );
  