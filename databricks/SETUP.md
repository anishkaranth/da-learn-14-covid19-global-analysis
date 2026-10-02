# Databricks setup

Tested on Databricks SQL Serverless (Serverless Starter Warehouse) with Unity Catalog.

1. Create the schema and volume. Step 1 of the notebook does this too:
   ```sql
   CREATE SCHEMA IF NOT EXISTS workspace.da_learn_14;
   CREATE VOLUME IF NOT EXISTS workspace.da_learn_14.raw;
   ```
2. Upload `owid-covid-data.csv` (from `scripts/download_full_data.py`) to `/Volumes/workspace/da_learn_14/raw/`. Use Catalog Explorer → Upload, or `databricks fs cp`.
3. Import `covid_pipeline_notebook.sql` (Workspace → Import → File) and run all cells on a SQL warehouse. It reads the file with `read_files(...)` and builds `stg_covid`, the `cln_*` tables, the star tables, the `a_*` analysis tables and the `dq_*` checks in `workspace.da_learn_14`.
4. Import `covid19_dashboard.lvdash.json` (Dashboards → Create → Import), pick a warehouse, and publish. The dashboard has 2 counters (reported deaths, world share with at least one dose) and 6 charts: monthly global deaths, deaths per million by continent, the top 10 countries by deaths per million, CFR by year, vaccination by income group, and deaths per million by median-age band.

## Verified run (2 Oct 2026, IST)
- The 98.4 MB file was uploaded in 12.7 s, and the 35 statements ran in 206 s.
- The dashboard "da-learn-14 COVID-19 global analysis" was published at 22:00 IST in /Shared/da-learn-14-covid19-global-analysis/.
- `run_outputs/duckdb_vs_databricks.json` shows that the row counts of all 9 tables match DuckDB (stg_covid 429,435 rows, fact_covid_daily 396,268), with 0 cell differences in the KPI, assertion and analysis tables.
