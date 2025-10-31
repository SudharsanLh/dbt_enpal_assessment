
  
    

  create  table "postgres"."staging"."stg_stages__dbt_tmp"
  
  
    as
  
  (
    

 select 
 stage_id,
 stage_name
  from "postgres"."public"."stages"
  );
  