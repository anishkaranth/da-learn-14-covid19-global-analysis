-- 02_cleaning.sql  (Spark SQL dialect; DuckDB via 00 shims)
-- types -> split entity types (country vs OWID aggregate) -> merge split duplicate rows per (iso_code, date)
-- -> outlier / revision flags. Sub-national UK rows (England, Scotland, Wales, N. Ireland) are dropped
-- because the United Kingdom row already contains them.

CREATE OR REPLACE TABLE cln_typed AS
SELECT
  trim(iso_code)                                                   AS iso_code,
  NULLIF(trim(continent), '')                                      AS continent,
  trim(location)                                                   AS location,
  to_date(trim(date))                                              AS obs_date,
  TRY_CAST(total_cases AS DOUBLE)                                  AS total_cases,
  TRY_CAST(new_cases AS DOUBLE)                                    AS new_cases,
  TRY_CAST(total_deaths AS DOUBLE)                                 AS total_deaths,
  TRY_CAST(new_deaths AS DOUBLE)                                   AS new_deaths,
  TRY_CAST(total_tests AS DOUBLE)                                  AS total_tests,
  TRY_CAST(total_vaccinations AS DOUBLE)                           AS total_vaccinations,
  TRY_CAST(people_vaccinated AS DOUBLE)                            AS people_vaccinated,
  TRY_CAST(people_fully_vaccinated AS DOUBLE)                      AS people_fully_vaccinated,
  TRY_CAST(total_boosters AS DOUBLE)                               AS total_boosters,
  TRY_CAST(people_vaccinated_per_hundred AS DOUBLE)                AS people_vaccinated_per_hundred,
  TRY_CAST(stringency_index AS DOUBLE)                             AS stringency_index,
  TRY_CAST(excess_mortality_cumulative_per_million AS DOUBLE)      AS excess_mortality_cum_per_million,
  TRY_CAST(population AS DOUBLE)                                   AS population,
  TRY_CAST(gdp_per_capita AS DOUBLE)                               AS gdp_per_capita,
  TRY_CAST(median_age AS DOUBLE)                                   AS median_age,
  TRY_CAST(aged_65_older AS DOUBLE)                                AS aged_65_older,
  TRY_CAST(life_expectancy AS DOUBLE)                              AS life_expectancy,
  TRY_CAST(hospital_beds_per_thousand AS DOUBLE)                   AS hospital_beds_per_thousand,
  CASE WHEN trim(iso_code) IN ('OWID_ENG', 'OWID_SCT', 'OWID_WLS', 'OWID_NIR') THEN 'subnational'
       WHEN NULLIF(trim(continent), '') IS NOT NULL THEN 'country'
       ELSE 'aggregate' END                                        AS entity_type
FROM stg_covid
WHERE to_date(trim(date)) IS NOT NULL AND NULLIF(trim(iso_code), '') IS NOT NULL;

-- Some (iso_code, date) pairs appear twice: one row carries cases/deaths, the other vaccinations.
-- Merge them with MAX per column (non-null wins) so every country-day is a single row.
CREATE OR REPLACE TABLE cln_merged AS
SELECT iso_code, obs_date, entity_type,
  MAX(continent) AS continent, MAX(location) AS location, COUNT(*) AS source_rows,
  MAX(total_cases) AS total_cases, MAX(new_cases) AS new_cases, MAX(total_deaths) AS total_deaths,
  MAX(new_deaths) AS new_deaths, MAX(total_tests) AS total_tests, MAX(total_vaccinations) AS total_vaccinations,
  MAX(people_vaccinated) AS people_vaccinated, MAX(people_fully_vaccinated) AS people_fully_vaccinated,
  MAX(total_boosters) AS total_boosters, MAX(people_vaccinated_per_hundred) AS people_vaccinated_per_hundred,
  MAX(stringency_index) AS stringency_index, MAX(excess_mortality_cum_per_million) AS excess_mortality_cum_per_million,
  MAX(population) AS population, MAX(gdp_per_capita) AS gdp_per_capita, MAX(median_age) AS median_age,
  MAX(aged_65_older) AS aged_65_older, MAX(life_expectancy) AS life_expectancy,
  MAX(hospital_beds_per_thousand) AS hospital_beds_per_thousand
FROM cln_typed
GROUP BY iso_code, obs_date, entity_type;

-- Country-day table with quality flags.
CREATE OR REPLACE TABLE cln_country_daily AS
SELECT m.*,
  CASE WHEN m.total_cases < LAG(m.total_cases) OVER (PARTITION BY m.iso_code ORDER BY m.obs_date) THEN 1 ELSE 0 END AS dq_cases_revised_down,
  CASE WHEN m.people_vaccinated > m.population THEN 1 ELSE 0 END                                              AS dq_vax_over_population,
  CASE WHEN COALESCE(m.new_cases, 0) < 0 OR COALESCE(m.new_deaths, 0) < 0 THEN 1 ELSE 0 END                  AS dq_negative_new
FROM cln_merged m
WHERE m.entity_type = 'country';

-- OWID aggregates (World, continents, income groups, EU) kept for reconciliation and equity analysis.
CREATE OR REPLACE TABLE cln_aggregate_daily AS
SELECT * FROM cln_merged WHERE entity_type = 'aggregate';
