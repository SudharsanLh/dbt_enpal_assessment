
    
    

select
    field_id as unique_field,
    count(*) as n_records

from "postgres"."staging"."stg_fields"
where field_id is not null
group by field_id
having count(*) > 1


