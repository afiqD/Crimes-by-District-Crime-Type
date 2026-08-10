with stg as (
    select * from {{ ref('stg_crime_district') }}
)

select distinct
    crime_category || '||' || crime_type              as crime_type_key,
    crime_category,
    crime_type
from stg
