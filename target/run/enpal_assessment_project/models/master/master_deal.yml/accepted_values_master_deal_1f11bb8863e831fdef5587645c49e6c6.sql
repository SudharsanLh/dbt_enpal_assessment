
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        funnel_step as value_field,
        count(*) as n_records

    from "postgres"."master"."master_deal"
    group by funnel_step

)

select *
from all_values
where value_field not in (
    'Step 1: Lead Generation','Step 2: Qualified Lead','Step 2.1: Sales Call 1','Step 3: Needs Assessment','Step 3.1: Sales Call 2','Step 4: Proposal/Quote Preparation','Step 5: Negotiation','Step 6: Closing','Step 7: Implementation/Onboarding','Step 8: Follow-up/Customer Success','Step 9: Renewal/Expansion'
)



  
  
      
    ) dbt_internal_test