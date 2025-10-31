
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select change_time_at
from "postgres"."ods"."ods_deal_stage_journey"
where change_time_at is null



  
  
      
    ) dbt_internal_test