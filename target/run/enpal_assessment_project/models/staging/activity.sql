
  
    

  create  table "postgres"."staging"."activity__dbt_tmp"
  
  
    as
  
  (
    

 select 
 activity_id,
 type as activity_type,
 assigned_to_user,
 deal_id,
 done,
 due_to::timestamp as due_to
 from "postgres"."public"."activity"
  );
  