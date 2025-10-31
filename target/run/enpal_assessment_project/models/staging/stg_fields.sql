
  
    

  create  table "postgres"."staging"."stg_fields__dbt_tmp"
  
  
    as
  
  (
    

 select 
 id as field_id,
 field_key as field_key,
 name as field_name,
 field_value_options
  from "postgres"."public"."fields"
  );
  