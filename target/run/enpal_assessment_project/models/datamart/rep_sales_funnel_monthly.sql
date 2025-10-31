
  
    

  create  table "postgres"."datamart"."rep_sales_funnel_monthly__dbt_tmp"
  
  
    as
  
  (
    

-- Stage 1: Get deals entering each pipeline stage
with stage_progression as (
    select
        month,
        funnel_step,
        'Deals Entered Stage' as kpi_name,
        count(distinct deal_id) as deals_count
    from "postgres"."ods"."ods_deal_stage_journey"
    group by month, funnel_step
),

-- Stage 2: Get activities (Sales Calls) completed
activity_completion as (
    select
        month,
        funnel_step,
        'Activities Completed' as kpi_name,
        count(distinct activity_id) as deals_count
    from "postgres"."ods"."ods_deal_activity_funnel"
    where is_funnel_tracked = true
        and funnel_step in ('Step 2.1: Sales Call 1', 'Step 3.1: Sales Call 2')
    group by month, funnel_step
),

-- Combine both: Stage progression + Activity completion
combined_funnel as (
    select * from stage_progression
    
    union all
    
    select * from activity_completion
),

-- Add month sequencing for sorting
final_result as (
    select
        month,
        kpi_name,
        funnel_step,
        deals_count,
        row_number() over (partition by month order by 
            case
                when funnel_step = 'Step 1: Lead Generation' then 1
                when funnel_step = 'Step 2: Qualified Lead' then 2
                when funnel_step = 'Step 2.1: Sales Call 1' then 2.1
                when funnel_step = 'Step 3: Needs Assessment' then 3
                when funnel_step = 'Step 3.1: Sales Call 2' then 3.1
                when funnel_step = 'Step 4: Proposal/Quote Preparation' then 4
                when funnel_step = 'Step 5: Negotiation' then 5
                when funnel_step = 'Step 6: Closing' then 6
                when funnel_step = 'Step 7: Implementation/Onboarding' then 7
                when funnel_step = 'Step 8: Follow-up/Customer Success' then 8
                when funnel_step = 'Step 9: Renewal/Expansion' then 9
                else 99
            end
        ) as funnel_sequence
    from combined_funnel
)

select
    month,
    kpi_name,
    funnel_step,
    deals_count
from final_result
order by month, funnel_sequence
  );
  