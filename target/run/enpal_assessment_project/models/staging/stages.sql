
  
    

  create  table "postgres"."staging"."stages__dbt_tmp"
  
  
    as
  
  (
    

 select 
 stage_id,
 stage_name
  from "postgres"."public"."stages"
  );
  