
  
    

  create  table "postgres"."ods"."ods_deal_activity_funnel__dbt_tmp"
  
  
    as
  
  (
    

with activities as (
    select
        activity_id,
        activity_type,
        assigned_to_user,
        deal_id,
        done,
        due_to
    from "postgres"."staging"."stg_activity"
    where deal_id is not null
        and activity_type is not null
),

activity_type_details as (
    select
        activity_type_id,
        activity_name,
        activity_type
    from "postgres"."staging"."stg_activity_types"
),

user_details as (
    select
        user_id,
        user_name,
        user_email
    from "postgres"."staging"."stg_users"
),

enriched_activities as (
    select
        a.activity_id,
        a.deal_id,
        a.activity_type,
        atd.activity_name,
        -- Map activities to funnel sub-steps
        case
            when a.activity_type = 'meeting' then 'Step 2.1: Sales Call 1'
            when a.activity_type = 'sc_2' then 'Step 3.1: Sales Call 2'
            else 'Other Activity'
        end as funnel_step,
        -- Flag if activity is tracked in funnel KPIs
        case
            when a.activity_type in ('meeting', 'sc_2') then true
            else false
        end as is_funnel_tracked,
        a.assigned_to_user,
        ud.user_name,
        ud.user_email,
        a.done as is_completed,
        a.due_to,
        date_trunc('month', a.due_to)::date as month
    from activities a
    left join activity_type_details atd on a.activity_type = atd.activity_type
    left join user_details ud on a.assigned_to_user = ud.user_id
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
    user_email,
    is_completed,
    due_to,
    month
from enriched_activities
order by deal_id, due_to
  );
  