-- 05_quality_checks.sql  before/after counts, DQ issue counts and hard assertions

CREATE OR REPLACE TABLE dq_row_counts AS
SELECT 'raw rows' AS entity, (SELECT COUNT(*) FROM stg_covid) AS raw_rows,
       (SELECT COUNT(*) FROM (SELECT DISTINCT iso_code, date FROM stg_covid) x) AS distinct_keys,
       (SELECT COUNT(*) FROM cln_merged) AS clean_rows, 'iso_code + date' AS grain
UNION ALL SELECT 'country-days', NULL, NULL, (SELECT COUNT(*) FROM cln_country_daily), 'country + date'
UNION ALL SELECT 'aggregate-days', NULL, NULL, (SELECT COUNT(*) FROM cln_aggregate_daily), 'OWID aggregate + date'
UNION ALL SELECT 'fact_covid_daily', NULL, NULL, (SELECT COUNT(*) FROM fact_covid_daily), 'country + day'
UNION ALL SELECT 'fact_country_month', NULL, NULL, (SELECT COUNT(*) FROM fact_country_month), 'country + month'
UNION ALL SELECT 'dim_country', NULL, NULL, (SELECT COUNT(*) FROM dim_country), 'country'
UNION ALL SELECT 'dim_date', NULL, NULL, (SELECT COUNT(*) FROM dim_date), 'day';

CREATE OR REPLACE TABLE dq_issues AS
SELECT 'raw: split duplicate rows merged (iso_code, date)' AS check_name,
       (SELECT COUNT(*) FROM stg_covid) - (SELECT COUNT(*) FROM cln_merged) AS affected_rows
UNION ALL SELECT 'raw: OWID aggregate rows (World, continents, income groups, EU)', (SELECT COUNT(*) FROM cln_typed WHERE entity_type = 'aggregate')
UNION ALL SELECT 'raw: UK sub-national rows dropped (double count)', (SELECT COUNT(*) FROM cln_typed WHERE entity_type = 'subnational')
UNION ALL SELECT 'country-days: new_cases NULL', (SELECT COUNT(*) FROM cln_country_daily WHERE new_cases IS NULL)
UNION ALL SELECT 'country-days: new_cases = 0 (weekly reporting gaps)', (SELECT COUNT(*) FROM cln_country_daily WHERE new_cases = 0)
UNION ALL SELECT 'country-days: cumulative cases revised down', (SELECT SUM(dq_cases_revised_down) FROM cln_country_daily)
UNION ALL SELECT 'country-days: people_vaccinated > population', (SELECT SUM(dq_vax_over_population) FROM cln_country_daily)
UNION ALL SELECT 'countries: vaccinated share > 100% (stale population or non-residents)', (SELECT COUNT(*) FROM a_country_latest WHERE pct_vaccinated > 100)
UNION ALL SELECT 'countries: never reported a vaccination', (SELECT COUNT(*) FROM a_country_latest WHERE people_vaccinated IS NULL)
UNION ALL SELECT 'country-days: negative new cases/deaths', (SELECT SUM(dq_negative_new) FROM cln_country_daily);

CREATE OR REPLACE TABLE dq_assertions AS
WITH w AS (SELECT MAX(total_cases) AS wc, MAX(total_deaths) AS wd FROM cln_aggregate_daily WHERE iso_code = 'OWID_WRL'),
c AS (
  SELECT 'one row per country-day' AS check_name,
         (SELECT COUNT(*) FROM (SELECT country_key, date_key FROM fact_covid_daily GROUP BY 1, 2 HAVING COUNT(*) > 1) x) AS failed_rows
  UNION ALL SELECT 'every fact row has a country', (SELECT COUNT(*) FROM fact_covid_daily f LEFT JOIN dim_country d ON d.country_key = f.country_key WHERE d.country_key IS NULL)
  UNION ALL SELECT 'every fact row has a date', (SELECT COUNT(*) FROM fact_covid_daily f LEFT JOIN dim_date d ON d.date_key = f.date_key WHERE d.date_key IS NULL)
  UNION ALL SELECT 'every country has continent + population', (SELECT COUNT(*) FROM dim_country WHERE continent IS NULL OR population IS NULL)
  UNION ALL SELECT 'no negative new cases or deaths', (SELECT COUNT(*) FROM fact_covid_daily WHERE new_cases < 0 OR new_deaths < 0)
  UNION ALL SELECT 'deaths never exceed cases (country final)', (SELECT COUNT(*) FROM a_country_latest WHERE total_deaths > total_cases)
  UNION ALL SELECT 'monthly new_cases sum = daily sum', (SELECT CASE WHEN (SELECT SUM(new_cases) FROM fact_country_month) = (SELECT SUM(COALESCE(new_cases, 0)) FROM fact_covid_daily) THEN 0 ELSE 1 END)
  UNION ALL SELECT 'country cases within 1% of OWID World', (SELECT CASE WHEN ABS(k.total_cases - w.wc) / w.wc <= 0.01 THEN 0 ELSE 1 END FROM a_kpi_headline k CROSS JOIN w)
  UNION ALL SELECT 'country deaths within 1% of OWID World', (SELECT CASE WHEN ABS(k.total_deaths - w.wd) / w.wd <= 0.01 THEN 0 ELSE 1 END FROM a_kpi_headline k CROSS JOIN w)
  UNION ALL SELECT 'UK sub-national rows excluded', (SELECT COUNT(*) FROM dim_country WHERE iso_code IN ('OWID_ENG', 'OWID_SCT', 'OWID_WLS', 'OWID_NIR'))
)
SELECT check_name, failed_rows, CASE WHEN failed_rows = 0 THEN 'PASS' ELSE 'FAIL' END AS status FROM c;
