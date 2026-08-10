with stg as (
    select * from {{ ref('stg_crime_district') }}
)

select distinct
    state || '||' || district                          as district_key,
    state,
    district
from stg
where state is not null
