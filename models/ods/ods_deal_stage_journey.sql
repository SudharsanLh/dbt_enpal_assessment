{{ config(
    materialized='table'
)}}

with stage_changes as (
    -- Filter only stage changes from deal_changes
    select
        deal_id,
        change_time_at,
        changed_field_key,
        new_value as stage_id_str
    from {{ ref('stg_deal_changes') }}
    where changed_field_key = 'stage_id'
        and new_value is not null
        and deal_id is not null
),
stage_details as (
    select
        stage_id,
        stage_name
    from {{ ref('stg_stages') }}
),
enriched_journey as (
    select
        sc.deal_id,
        sc.change_time_at,
        cast(sc.stage_id_str as integer) as stage_id,
        sd.stage_name,
        -- Map to funnel steps (9 steps as per assessment)
        case
            when cast(sc.stage_id_str as integer) = 1 then 'Step 1: Lead Generation'
            when cast(sc.stage_id_str as integer) = 2 then 'Step 2: Qualified Lead'
            when cast(sc.stage_id_str as integer) = 3 then 'Step 3: Needs Assessment'
            when cast(sc.stage_id_str as integer) = 4 then 'Step 4: Proposal/Quote Preparation'
            when cast(sc.stage_id_str as integer) = 5 then 'Step 5: Negotiation'
            when cast(sc.stage_id_str as integer) = 6 then 'Step 6: Closing'
            when cast(sc.stage_id_str as integer) = 7 then 'Step 7: Implementation/Onboarding'
            when cast(sc.stage_id_str as integer) = 8 then 'Step 8: Follow-up/Customer Success'
            when cast(sc.stage_id_str as integer) = 9 then 'Step 9: Renewal/Expansion'
            else 'Unknown Stage'
        end as funnel_step,
        date_trunc('month', sc.change_time_at)::date as month,
        row_number() over (partition by sc.deal_id order by sc.change_time_at) as stage_sequence
    from stage_changes sc
    left join stage_details sd on cast(sc.stage_id_str as integer) = sd.stage_id
)
select
    deal_id,
    change_time_at,
    stage_id,
    stage_name,
    funnel_step,
    month,
    stage_sequence
from enriched_journey
where stage_id is not null
order by deal_id, change_time_at
