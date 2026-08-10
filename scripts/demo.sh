#!/bin/bash
# Live demo: rebuild the whole warehouse from scratch, end to end.
# Run from the crime-warehouse/ project root:
#   bash scripts/demo.sh   (activates venv automatically)
set -e
cd "$(dirname "$0")/.."

if [ -d "venv" ]; then
  # shellcheck disable=SC1091
  source venv/bin/activate
fi

# Fresh start: remove any existing database so the demo shows a full rebuild
rm -f crime_dw/crime_dw.duckdb*

echo ""
echo "════════════════════════════════════════════════════"
echo "  STEP 1/4 — BRONZE: land raw data from data.gov.my"
echo "════════════════════════════════════════════════════"
echo "\$ python crime_dw/scripts/ingest.py"
python crime_dw/scripts/ingest.py

echo ""
echo "════════════════════════════════════════════════════"
echo "  STEP 2/4 — SILVER + GOLD: run dbt transformations"
echo "════════════════════════════════════════════════════"
echo "\$ cd crime_dw && dbt run"
cd crime_dw
dbt run

echo ""
echo "════════════════════════════════════════════════════"
echo "  STEP 3/4 — Validate with dbt tests"
echo "════════════════════════════════════════════════════"
echo "\$ dbt test"
dbt test

echo ""
echo "════════════════════════════════════════════════════"
echo "  STEP 4/4 — Query the gold layer (star schema)"
echo "════════════════════════════════════════════════════"
cd ..
echo "\$ python -c \"import duckdb; ...\""
python -c "
import duckdb
con = duckdb.connect('crime_dw/crime_dw.duckdb')
print(con.sql('''
select
    d.state,
    sum(f.crime_count) as total_crimes
from main_gold.fact_crime f
join main_gold.dim_district d using (district_key)
where d.state != 'Malaysia'
group by d.state
order by total_crimes desc
limit 5
''').fetchdf().to_markdown(index=False))"

echo ""
echo "✅ DEMO COMPLETE — bronze → silver → gold, end to end."
echo "   Next: dbt docs serve  (lineage graph in the browser)"
