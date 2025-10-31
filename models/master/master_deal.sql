{{ config(
    materialized='table'
)}}
-- Get the current stage (most recent stage change)
with latest_stage as (
    select
        deal_id,
        stage_id as current_stage_id,
        stage_name as current_stage_name,
        funnel_step as current_funnel_step,
        change_time_at as latest_stage_change_at,
        month as current_month,
        row_number() over (partition by deal_id order by change_time_at desc) as rn
    from {{ ref('ods_deal_stage_journey') }}
),
latest_stage_final as (
    select
        deal_id,
        current_stage_id,
        current_stage_name,
        current_funnel_step,
        latest_stage_change_at,
        current_month
    from latest_stage
    where rn = 1
),
-- Get the first stage (entry point into pipeline)
first_stage as (
    select
        deal_id,
        stage_id as first_stage_id,
        stage_name as first_stage_name,
        change_time_at as first_stage_entered_at,
        month as month_entered_pipeline,
        row_number() over (partition by deal_id order by change_time_at asc) as rn
    from {{ ref('ods_deal_stage_journey') }}
),
first_stage_final as (
    select
        deal_id,
        first_stage_id,
        first_stage_name,
        first_stage_entered_at,
        month_entered_pipeline
    from first_stage
    where rn = 1
),
-- Get current owner (most recent user_id assignment)
owner_extraction as (
    select
        deal_id,
        cast(new_value as integer) as current_owner_id,
        change_time_at,
        row_number() over (partition by deal_id order by change_time_at desc) as rn
    from {{ ref('stg_deal_changes') }}
    where changed_field_key = 'user_id'
        and new_value is not null
),
current_owner as (
    select
        deal_id,
        current_owner_id
    from owner_extraction
    where rn = 1
),
-- Get owner user details
user_details as (
    select
        user_id,
        user_name,
        user_email
    from {{ ref('stg_users') }}
),
-- Aggregate all deal changes
deal_changes_summary as (
    select
        deal_id,
        count(distinct changed_field_key) as total_field_changes,
        max(change_time_at) as last_change_at,
        min(change_time_at) as first_change_at
    from {{ ref('stg_deal_changes') }}
    where deal_id is not null
    group by deal_id
),
-- Count owner reassignments (times deal was reassigned)
owner_reassignments as (
    select
        deal_id,
        count(distinct new_value) as times_reassigned
    from {{ ref('stg_deal_changes') }}
    where changed_field_key = 'user_id'
        and new_value is not null
    group by deal_id
),
-- Aggregate activities on the deal
activity_summary as (
    select
        deal_id,
        count(distinct activity_id) as total_activities,
        count(distinct case when is_completed then activity_id end) as completed_activities,
        count(distinct case when is_funnel_tracked then activity_id end) as funnel_tracked_activities,
        max(due_to) as last_activity_date,
        count(distinct assigned_to_user) as unique_users_performed_activities
    from {{ ref('ods_deal_activity_funnel') }}
    where deal_id is not null
    group by deal_id
),
-- Combine all metrics
final_combined as (
    select
        ls.deal_id,       
        -- Latest stage of the deal 
        ls.current_stage_id,
        ls.current_stage_name,
        ls.current_funnel_step,
        ls.latest_stage_change_at,
        ls.current_month,  
        -- First stage of the deal 
        fs.first_stage_id,
        fs.first_stage_name,
        fs.first_stage_entered_at,
        -- Current Owner
        co.current_owner_id,
        ud.user_name as current_owner_name,
        ud.user_email as current_owner_email,
        -- Deal Changes Summary
        coalesce(dcs.total_field_changes, 0) as total_field_changes,
        dcs.last_change_at as last_change_at,
        dcs.first_change_at as first_change_at,
        coalesce(ore.times_reassigned, 0) as times_reassigned, 
        -- Activity Summary
        coalesce(act.total_activities, 0) as total_activities,
        coalesce(act.completed_activities, 0) as completed_activities,
        coalesce(act.funnel_tracked_activities, 0) as funnel_tracked_activities,
        act.last_activity_date,
        -- Derived Metrics
        (current_date - ls.latest_stage_change_at::date)  as days_in_current_stage,
       (current_date - fs.first_stage_entered_at::date)as days_in_pipeline
    from latest_stage_final ls
    left join first_stage_final fs on ls.deal_id = fs.deal_id
    left join deal_changes_summary dcs on ls.deal_id = dcs.deal_id
    left join owner_reassignments ore on ls.deal_id = ore.deal_id
    left join activity_summary act on ls.deal_id = act.deal_id
    left join current_owner co on ls.deal_id = co.deal_id
    left join user_details ud on co.current_owner_id = ud.user_id
)
select * from final_combined


