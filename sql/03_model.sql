-- 03_model.sql  Star schema: fact_covid_daily (country x day), fact_country_month (country x month),
-- dim_country, dim_date.

CREATE OR REPLACE TABLE dim_country AS
SELECT ROW_NUMBER() OVER (ORDER BY iso_code) AS country_key, iso_code, location, continent,
       CAST(population AS BIGINT) AS population, gdp_per_capita, median_age, aged_65_older, life_expectancy,
       hospital_beds_per_thousand,
       CASE WHEN population >= 1000000 THEN 1 ELSE 0 END AS pop_1m_plus_flag
FROM (SELECT iso_code, MAX(location) AS location, MAX(continent) AS continent, MAX(population) AS population,
             MAX(gdp_per_capita) AS gdp_per_capita, MAX(median_age) AS median_age, MAX(aged_65_older) AS aged_65_older,
             MAX(life_expectancy) AS life_expectancy, MAX(hospital_beds_per_thousand) AS hospital_beds_per_thousand
      FROM cln_country_daily GROUP BY iso_code) c;

CREATE OR REPLACE TABLE dim_date AS
SELECT DISTINCT
  CAST(year(obs_date) * 10000 + month(obs_date) * 100 + day(obs_date) AS INT) AS date_key,
  obs_date AS full_date, year(obs_date) AS year, quarter(obs_date) AS quarter, month(obs_date) AS month,
  CAST(year(obs_date) * 100 + month(obs_date) AS INT) AS year_month,
  concat(CAST(year(obs_date) AS STRING), '-', lpad(CAST(month(obs_date) AS STRING), 2, '0')) AS year_month_label,
  dayofweek(obs_date) AS day_of_week
FROM cln_merged;

CREATE OR REPLACE TABLE fact_covid_daily AS
SELECT
  CAST(year(d.obs_date) * 10000 + month(d.obs_date) * 100 + day(d.obs_date) AS INT) AS date_key,
  c.country_key, d.obs_date,
  CAST(d.new_cases AS BIGINT) AS new_cases, CAST(d.new_deaths AS BIGINT) AS new_deaths,
  CAST(d.total_cases AS BIGINT) AS total_cases, CAST(d.total_deaths AS BIGINT) AS total_deaths,
  CAST(d.people_vaccinated AS BIGINT) AS people_vaccinated,
  CAST(d.people_fully_vaccinated AS BIGINT) AS people_fully_vaccinated,
  CAST(d.total_boosters AS BIGINT) AS total_boosters,
  CAST(d.total_vaccinations AS BIGINT) AS total_vaccinations,
  d.stringency_index, d.excess_mortality_cum_per_million,
  d.dq_cases_revised_down, d.dq_vax_over_population, d.source_rows
FROM cln_country_daily d
JOIN dim_country c ON c.iso_code = d.iso_code;

-- Monthly grain: flows are summed, stocks (cumulative counts) take the month-end (max) value.
CREATE OR REPLACE TABLE fact_country_month AS
SELECT f.country_key, CAST(year(f.obs_date) * 100 + month(f.obs_date) AS INT) AS year_month,
  SUM(COALESCE(f.new_cases, 0)) AS new_cases, SUM(COALESCE(f.new_deaths, 0)) AS new_deaths,
  MAX(f.total_cases) AS total_cases_eom, MAX(f.total_deaths) AS total_deaths_eom,
  MAX(f.people_vaccinated) AS people_vaccinated_eom, MAX(f.people_fully_vaccinated) AS people_fully_vaccinated_eom,
  MAX(f.total_boosters) AS total_boosters_eom, ROUND(AVG(f.stringency_index), 2) AS avg_stringency
FROM fact_covid_daily f
GROUP BY f.country_key, CAST(year(f.obs_date) * 100 + month(f.obs_date) AS INT);
