
  
    

  create  table "postgres"."_pipedrive_analytics"."test_model__dbt_tmp"
  
  
    as
  
  (
    SELECT *
FROM "postgres"."public"."activity"
  );
  