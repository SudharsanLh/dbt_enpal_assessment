
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select change_time_at
from "postgres"."staging"."stg_deal_changes"
where change_time_at is null



  
  
      
    ) dbt_internal_test