-- Example queries against the gold layer (star schema).
-- Run: dbt compile  (or copy into DuckDB / dbt docs)

-- 1. Top 5 states by total reported crimes, 2016-2023
select
    d.state,
    count(distinct f.crime_date) as years,
    sum(f.crime_count) as total_crimes
from {{ ref('fact_crime') }} f
join {{ ref('dim_district') }} d using (district_key)
where d.state != 'Malaysia'
group by d.state
order by total_crimes desc
limit 5;

-- 2. Top 5 crime types nationally
select
    c.crime_category,
    c.crime_type,
    sum(f.crime_count) as total_crimes
from {{ ref('fact_crime') }} f
join {{ ref('dim_crime_type') }} c using (crime_type_key)
where c.crime_type != 'all'
group by 1, 2
order by total_crimes desc
limit 5;

-- 3. National crime trend by year (category 'all' only, to avoid double counting)
select
    f.crime_date,
    sum(f.crime_count) as total_crimes
from {{ ref('fact_crime') }} f
join {{ ref('dim_district') }} d using (district_key)
join {{ ref('dim_crime_type') }} c using (crime_type_key)
where d.state = 'Malaysia'
  and c.crime_type = 'all'
group by f.crime_date
order by f.crime_date;
