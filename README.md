Please find the contents of the project below.

## Table of Contents

- [Project Objective](#project-objective)
- [Data Overview](#data-overview)
- [Architecture & Layers](#architecture--layers)
- [Data Modeling Approach](#data-modeling-approach)
- [Data Quality Assurance](#data-quality-assurance)
- [Key Findings & Insights](#key-findings--insights)

## Project Objective

To build a scalable, maintainable analytics layer that transforms raw CRM data into actionable business intelligence. I have created a **monthly sales funnel reporting model** tracking deals across 9 pipeline stages plus sub-step KPIs (Sales Calls 1 & 2). This is essential for trend analysis and pipeline health monitoring.

I have also created a complementary  **master deal model** that acts as the single source of truth for deal attributes with deal_id as the primary key, with stage metrics, owner, activity metrics, and time KPI. It enriches deals with lost reasons and ownership history

**Primary Deliverable:** `rep_sales_funnel_monthly` - A reporting table with columns:
- `month` - Monthly aggregation period
- `kpi_name` - Metric type (Deals Entered Stage / Activities Completed)
- `funnel_step` - Pipeline stage (Step 1-9, including substeps 2.1, 3.1)
- `deals_count` - Count of deals/activities per step per month

---

## Data Overview

There are main 6 main source tables with some basic information below

### Deals data & Period
- **Time Range:** January 2024 - March 2025 
- **Unique Deal Ids in Deal changes:** 1995
- **Unique Deal Ids in Activities table:** 4561
- **Unique Deal Ids in Activities table with relevant funnel steps:** 2260
- **Users/Contacts:** 1,787 unique records

---

## Architecture & Layers

I have used a 4-layer model whose purpose are given below

**Staging (stg_*)**
- Cast data types (timestamp strings → timestamps)
- Rename columns for clarity (id → user_id)
- Filter obviously bad data (NULL deal_ids)
- No business logic—purely technical transformation

**ODS (ods_*)**
- Join and enrich staging tables
- Add business context (user names, activity types)
- Create flags for funnel-tracked activities

**Master (master_*)**
- Single row per business entity (deal_id, user_id as primary keys)
- Aggregate metrics, Time KPIs, and User relationships


**Datamart (rep_*)**
- Aggregate metrics by time period (monthly)

---

## Data Modeling Approach

The project employs a star schema design with rep_sales_funnel_monthly as the fact table (granularity: monthly, measures: deals_count by kpi_name and funnel_step) and master_deal, master_user as dimension tables capturing deal attributes and user performance metrics respectively. Each model follows the single responsibility principle—staging layers clean and standardize, ODS layers integrate and enrich, master layers aggregate by entity (deal_id, user_id), and reporting layers aggregate by time period (month). 

All models are materialized as tablesand frequently filtered columns (deal_id, stage_id, user_id, month) for query performance. Deal ownership tracking captures reassignments with current owner derived from the latest user_id assignment, while activity attribution maintains both performer and deal owner relationships for comprehensive funnel analysis.

### Data Lineage
Rep_sales_funnel_monthly lineage
<img width="1151" height="538" alt="Screenshot 2025-10-31 at 23 06 35" src="https://github.com/user-attachments/assets/8265f271-1536-43ce-b3a5-ab2019da1fd0" />


Master_data lineage
<img width="1083" height="617" alt="Screenshot 2025-10-31 at 23 06 53" src="https://github.com/user-attachments/assets/4b4c370c-1bdc-46db-82bb-1f8deb10254e" />



## Data Quality Assurance

### Data Quality Issues Identified and resolved with certain level of assumption

#### 1. Activity ID Duplicates 
- **Issue:** 11 Duplicate activity_ids appear multiple times with different deal_ids, users, and timestamps
- **Solution used:** Deduplication in staging layer with row_number() — kept most recent record

#### 2. Deal Ids which are not in Deal_changes table, but available in Activity Table
- **Finding:** Nearly 2257 deal_ids are found only in activity table
- **Solution used:** These deals are counted as it is for the funnel datamart, however will be excluded from the master_deal table. In master_deal table the source of the deal id comes from deal_changes table

#### 3. JSON Field Parsing of lost reasons 
- **Issue:** `field_value_options` contains JSON arrays (lost reasons)
- **Solution:** Created stg_lost_fields model with jsonb_array_elements() to extract key-value pairs. This is useful in the master deal table

#### 4. All deals have lost label
- **Issue:** From above point, master_deal table shows all deal have lost label even though deals were closed.
- **Solution:** This needs to be either cleaned-up for closed deals or investigated if there is a CRM issue



### dbt Tests Implemented

Uniqueness Tests, not Null Tests, accepted_values, custom Expression Tests

---

## Key Findings & Insights (based on Sales Funnel or Master deal model)

1. Of the 2000 leads generated, only 324 met the Renewal/Expansion stage - There is a 83% drop off end-to-end
2. Biggest drop-off between the stages happen between the 1st and 2nd, i.e in the qualification process. Better qualification or quality lead generation is recommended
3. Impact of Sales call activities are visible in the conversion funnel - 77%-85% completion rate
4. Seasonality of lead generation - very high leads between April to August 2024
5. Average pipeline duration is approximately 500 days, which requires more process optimisation from generation to closure/loss
6. Nearly 25% of the deals have been reassigned to a new owner (more than 2 user assignments


