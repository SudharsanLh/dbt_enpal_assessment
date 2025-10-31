
  
    

  create  table "postgres"."ods"."ods_deal__dbt_tmp"
  
  
    as
  
  (
    

 select * from "postgres"."staging"."activity_types"
  );
  