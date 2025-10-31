
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select deal_id
from "postgres"."ods"."ods_deal_stage_journey"
where deal_id is null



  
  
      
    ) dbt_internal_test