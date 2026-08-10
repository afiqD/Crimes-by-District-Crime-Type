"""View the actual data in each layer. Run:  python scripts/view_data.py"""
import os

import duckdb

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(PROJECT_DIR, "crime_dw.duckdb")

con = duckdb.connect(DB_PATH)

def show(title, sql):
    print(f"\n=== {title} ===")
    print(con.sql(sql).fetchdf().to_markdown(index=False))

show("BRONZE — raw (5 sample rows)", """
    select * from bronze.crime_district_raw limit 5
""")

show("SILVER — cleaned staging (5 sample rows)", """
    select * from main_silver.stg_crime_district limit 5
""")

show("GOLD — fact_crime (5 sample rows)", """
    select * from main_gold.fact_crime limit 5
""")

show("GOLD — dim_district (count)", """
    select count(*) as districts from main_gold.dim_district
""")

show("GOLD — dim_crime_type (count)", """
    select count(*) as crime_types from main_gold.dim_crime_type
""")

show("Top 5 states by total crimes", """
    select d.state, sum(f.crime_count) as total_crimes
    from main_gold.fact_crime f
    join main_gold.dim_district d using (district_key)
    where d.state != 'Malaysia'
    group by d.state
    order by total_crimes desc
    limit 5
""")
