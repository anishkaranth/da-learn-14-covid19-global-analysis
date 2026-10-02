"""Project config shared by run_pipeline.py, build_databricks.py (and the Databricks deploy)."""
REPO = "da-learn-14-covid19-global-analysis"
NN = "14"
DASH_TITLE = "COVID-19 global analysis 2020-2024 (OWID)"
DASH_NAME = "da-learn-14 COVID-19 global analysis"
NOTEBOOK = "covid_pipeline_notebook"
DASH_FILE = "covid19_dashboard"
CURRENCY = "USD"
DATASET = "Our World in Data COVID-19 dataset (owid/covid-19-data, public/data/owid-covid-data.csv, final snapshot to 2024-08-14)"
RAW = {"stg_covid": {"file": "owid-covid-data.csv", "format": "csv"}}
RAW_FILES = [v["file"] for v in RAW.values()]
CLEAN = ["cln_typed", "cln_merged", "cln_country_daily", "cln_aggregate_daily"]
STAR = ["fact_covid_daily", "fact_country_month", "dim_country", "dim_date"]
# Power BI kit: sample-sized star (6 large countries; months of 2021; daily rows for India, April-May 2021)
_C = "('IND', 'USA', 'BRA', 'GBR', 'ZAF', 'JPN')"
PBI_CAP = {"fact_covid_daily": 61, "fact_country_month": 72, "dim_country": 6, "dim_date": 61}
PBI_SAMPLE_FILTER = {
    "dim_country": f"iso_code IN {_C}",
    "fact_country_month": f"year_month BETWEEN 202101 AND 202112 AND country_key IN (SELECT country_key FROM dim_country WHERE iso_code IN {_C})",
    "fact_covid_daily": "date_key BETWEEN 20210401 AND 20210531 AND country_key = (SELECT country_key FROM dim_country WHERE iso_code = 'IND')",
    "dim_date": "date_key BETWEEN 20210401 AND 20210531"}
COMPARE_TABLES = ["a_kpi_headline", "a_continent_summary", "a_yearly", "a_continent_peak", "a_vax_band_outcomes",
                  "a_age_band_deaths", "a_income_vaccination", "dq_issues"]
SHOT_CONFIG = {"engine": "duckdb (local, full data) + Databricks serverless SQL", "sql_dialect": "Spark/Databricks SQL + DuckDB shims (sql/00)",
               "entities": "countries only (continent not null); UK nations dropped; OWID aggregates used for World/income checks",
               "duplicates": "split (iso_code, date) rows merged with MAX per column",
               "per_capita": "OWID population column (2022 UN WPP)", "ranking_filter": "population >= 1,000,000",
               "sample_rule": "data/raw = India, United States, Brazil, South Africa + World on 2021-12-31 and 2023-12-31, plus the split-duplicate pair Faroe Islands 2021-01-29"}
SHOT_QUERIES = {
    "continents": "SELECT continent, total_cases, total_deaths, deaths_per_million, pct_vaccinated FROM a_continent_summary ORDER BY deaths_per_million DESC",
    "top5_deaths_per_million": "SELECT location, deaths_per_million, cfr_pct FROM a_country_latest WHERE pop_1m_plus_flag = 1 ORDER BY deaths_per_million DESC LIMIT 5",
    "yearly": "SELECT year, new_cases, new_deaths, cfr_pct FROM a_yearly ORDER BY year",
    "income_vaccination": "SELECT income_group, pct_vaccinated FROM a_income_vaccination ORDER BY pct_vaccinated DESC",
}
METRIC_QUERIES = {
    "continent_summary": "SELECT * FROM a_continent_summary ORDER BY deaths_per_million DESC",
    "yearly": "SELECT * FROM a_yearly ORDER BY year",
    "continent_peak": "SELECT * FROM a_continent_peak ORDER BY continent",
    "top10_deaths_per_million": "SELECT location, continent, population, total_deaths, deaths_per_million, cfr_pct, pct_vaccinated FROM a_country_latest WHERE pop_1m_plus_flag = 1 ORDER BY deaths_per_million DESC LIMIT 10",
    "top10_total_deaths": "SELECT location, total_deaths, deaths_per_million FROM a_country_latest ORDER BY total_deaths DESC LIMIT 10",
    "top10_vaccinated": "SELECT location, pct_vaccinated FROM a_country_latest WHERE pop_1m_plus_flag = 1 AND pct_vaccinated IS NOT NULL ORDER BY pct_vaccinated DESC LIMIT 10",
    "bottom10_vaccinated": "SELECT location, pct_vaccinated FROM a_country_latest WHERE pop_1m_plus_flag = 1 AND pct_vaccinated IS NOT NULL ORDER BY pct_vaccinated LIMIT 10",
    "vax_band_outcomes": "SELECT * FROM a_vax_band_outcomes ORDER BY 1",
    "age_band_deaths": "SELECT * FROM a_age_band_deaths ORDER BY 1",
    "income_vaccination": "SELECT * FROM a_income_vaccination ORDER BY pct_vaccinated DESC",
    "monthly_global_top5_deaths": "SELECT * FROM a_monthly_global ORDER BY new_deaths DESC LIMIT 5",
}
CARDS = [("countries", "Countries", "{:,}"), ("total_cases", "Reported cases", "{:,}"), ("total_deaths", "Reported deaths", "{:,}"),
         ("cfr_pct", "Case fatality", "{:.2f}%"), ("deaths_per_million", "Deaths / million", "{:,.0f}"),
         ("world_pct_vaccinated", "World >= 1 dose", "{:.1f}%"), ("peak_death_month", "Peak death month", "{}")]
DASH_KPI_SQL = "SELECT countries, total_cases, total_deaths, cfr_pct / 100 AS cfr, world_pct_vaccinated / 100 AS world_vaccinated FROM {S}a_kpi_headline"
COUNTERS = [("total_deaths", "Reported COVID-19 deaths", "num"), ("world_vaccinated", "World population with >= 1 dose", "pct")]
DASH_NOTE = "Source: Our World in Data COVID-19 dataset (CC BY 4.0), final snapshot 2024-08-14. Countries only. Tables: workspace.da_learn_14."
VIZ = [
    {"name": "monthly_deaths", "title": "Global reported deaths per month", "kind": "line", "x": "month_label", "y": "new_deaths", "fmt": "{:,.0f}",
     "sql": "SELECT month_label, new_deaths FROM {S}a_monthly_global ORDER BY year_month"},
    {"name": "continent_deaths_pm", "title": "Deaths per million by continent", "kind": "hbar", "x": "continent", "y": "deaths_per_million", "fmt": "{:,.0f}",
     "sql": "SELECT continent, deaths_per_million FROM {S}a_continent_summary ORDER BY deaths_per_million DESC"},
    {"name": "top_deaths_pm", "title": "Highest deaths per million (pop >= 1M)", "kind": "hbar", "x": "location", "y": "deaths_per_million", "fmt": "{:,.0f}",
     "sql": "SELECT location, deaths_per_million FROM {S}a_country_latest WHERE pop_1m_plus_flag = 1 ORDER BY deaths_per_million DESC LIMIT 10"},
    {"name": "yearly_cfr", "title": "Case fatality rate by year (%)", "kind": "bar", "x": "year", "y": "cfr_pct", "fmt": "{:.2f}%",
     "sql": "SELECT CAST(year AS STRING) AS year, cfr_pct FROM {S}a_yearly ORDER BY year"},
    {"name": "income_vaccination", "title": "Share with >= 1 vaccine dose by income group", "kind": "hbar", "x": "income_group", "y": "pct_vaccinated", "fmt": "{:.1f}%",
     "sql": "SELECT replace(income_group, '-income countries', ' income') AS income_group, pct_vaccinated FROM {S}a_income_vaccination ORDER BY pct_vaccinated DESC"},
    {"name": "age_band_deaths", "title": "Deaths per million by median-age band", "kind": "bar", "x": "median_age_band", "y": "deaths_per_million", "fmt": "{:,.0f}",
     "sql": "SELECT median_age_band, deaths_per_million FROM {S}a_age_band_deaths ORDER BY median_age_band"},
]
