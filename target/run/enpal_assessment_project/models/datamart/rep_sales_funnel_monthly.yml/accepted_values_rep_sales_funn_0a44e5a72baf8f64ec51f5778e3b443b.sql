
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        kpi_name as value_field,
        count(*) as n_records

    from "postgres"."datamart"."rep_sales_funnel_monthly"
    group by kpi_name

)

select *
from all_values
where value_field not in (
    'Deals Entered Stage','Activities Completed'
)



  
  
      
    ) dbt_internal_test