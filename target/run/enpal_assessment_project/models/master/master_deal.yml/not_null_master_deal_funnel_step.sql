
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select funnel_step
from "postgres"."master"."master_deal"
where funnel_step is null



  
  
      
    ) dbt_internal_test