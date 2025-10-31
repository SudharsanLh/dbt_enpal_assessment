
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select activity_id
from "postgres"."ods"."ods_deal_activity_by_pipeline"
where activity_id is null



  
  
      
    ) dbt_internal_test