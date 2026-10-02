# Databricks setup

Tested on Databricks SQL Serverless (Serverless Starter Warehouse) with Unity Catalog.

1. Run `python scripts/download_full_data.py`, then upload `owid-covid-data.csv` to `/Volumes/workspace/da_learn_14/raw/`. The notebook's first cell creates the schema `workspace.da_learn_14` and the volume `raw`. To upload, use Catalog Explorer → Upload, or `databricks fs cp`.
2. Import `covid_pipeline_notebook.sql` (Workspace → Import) and *Run all* on a SQL warehouse. It builds the `stg_`, `cln_`, star, `a_` and `dq_` tables.
3. Import `covid19_dashboard.lvdash.json` (Dashboards → Import), choose a warehouse, and publish. The dashboard has 2 counters (deaths, world share with at least 1 dose) and 6 charts: monthly deaths, continent deaths per million, top countries, yearly CFR, income-group vaccination, and median-age band.

## Verified run (2 Oct 2026, IST)
- The 98.4 MB file was uploaded in 12.7 s, and the 35 statements ran in 206 s, finishing at 21:59 IST.
- The dashboard "da-learn-14 COVID-19 global analysis" was published at 21:59 IST in /Shared/da-learn-14-covid19-global-analysis/.
- The notebook is at /Workspace/Shared/da-learn-14-covid19-global-analysis/covid_pipeline_notebook.
- `run_outputs/duckdb_vs_databricks.json` shows that the row counts of all 9 tables match DuckDB, with 0 cell differences in the 9 compared result tables.
