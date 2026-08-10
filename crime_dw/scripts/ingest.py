"""Bronze layer: land the raw dataset as-is, untouched."""
import duckdb

DB_PATH = "crime_dw.duckdb"
API_URL = "https://api.data.gov.my/data-catalogue/?id=crime_district&sort=-date"

con = duckdb.connect(DB_PATH)
con.sql("""
    CREATE SCHEMA IF NOT EXISTS bronze;
    CREATE OR REPLACE TABLE bronze.crime_district_raw AS
    SELECT * FROM read_json_auto(?);
""", params=[API_URL])

count = con.sql("SELECT COUNT(*) FROM bronze.crime_district_raw").fetchone()[0]
columns = [c[0] for c in con.sql("DESCRIBE bronze.crime_district_raw").fetchall()]
print(f"Loaded {count} rows into bronze.crime_district_raw")
print(f"Columns: {columns}")
