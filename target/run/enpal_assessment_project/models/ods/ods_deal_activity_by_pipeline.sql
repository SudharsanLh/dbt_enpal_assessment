
  
    

  create  table "postgres"."ods"."ods_deal_activity_by_pipeline__dbt_tmp"
  
  
    as
  
  (
    

with pipeline_deals as (
    -- Get all unique deals that have moved through pipeline stages
    select distinct deal_id
    from "postgres"."ods"."ods_deal_stage_journey"
),

funnel_activities as (
    select
        ea.activity_id,
        ea.deal_id,
        ea.activity_type,
        ea.activity_name,
        ea.funnel_step,
        ea.is_funnel_tracked,
        ea.assigned_to_user,
        ea.user_name,
        ea.due_to,
        ea.month
    from "postgres"."ods"."ods_deal_activity_funnel" ea
    inner join pipeline_deals pd on ea.deal_id = pd.deal_id
    where ea.is_funnel_tracked = true
)

select
    activity_id,
    deal_id,
    activity_type,
    activity_name,
    funnel_step,
    is_funnel_tracked,
    assigned_to_user,
    user_name,
    due_to,
    month
from funnel_activities
order by deal_id, due_to
  );
  