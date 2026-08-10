with stg as (
    select * from {{ ref('stg_crime_district') }}
)

select
    state || '||' || district                          as district_key,
    crime_category || '||' || crime_type              as crime_type_key,
    crime_date,
    crime_count
from stg
