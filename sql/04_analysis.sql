-- 04_analysis.sql  KPIs and business questions (countries only; aggregates used for equity + reconciliation)

-- Q1/Q4: final cumulative totals and per-capita rates per country
CREATE OR REPLACE TABLE a_country_latest AS
WITH t AS (
  SELECT country_key, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths,
         MAX(people_vaccinated) AS people_vaccinated, MAX(people_fully_vaccinated) AS people_fully_vaccinated,
         MAX(total_boosters) AS total_boosters, MAX(obs_date) AS last_date
  FROM fact_covid_daily GROUP BY country_key
), x AS (
  SELECT country_key, excess_mortality_cum_per_million FROM fact_covid_daily
  WHERE excess_mortality_cum_per_million IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (PARTITION BY country_key ORDER BY obs_date DESC) = 1
)
SELECT c.country_key, c.iso_code, c.location, c.continent, c.population, c.pop_1m_plus_flag, c.median_age, c.gdp_per_capita,
  t.total_cases, t.total_deaths, t.people_vaccinated, t.last_date,
  ROUND(t.total_cases * 1e6 / NULLIF(c.population, 0), 1)             AS cases_per_million,
  ROUND(t.total_deaths * 1e6 / NULLIF(c.population, 0), 1)            AS deaths_per_million,
  ROUND(100.0 * t.total_deaths / NULLIF(t.total_cases, 0), 3)          AS cfr_pct,
  ROUND(100.0 * t.people_vaccinated / NULLIF(c.population, 0), 2)      AS pct_vaccinated,
  ROUND(100.0 * t.people_fully_vaccinated / NULLIF(c.population, 0), 2) AS pct_fully_vaccinated,
  ROUND(100.0 * t.total_boosters / NULLIF(c.population, 0), 2)         AS boosters_per_hundred,
  ROUND(x.excess_mortality_cum_per_million, 1)                         AS excess_mortality_cum_per_million
FROM dim_country c
JOIN t ON t.country_key = c.country_key
LEFT JOIN x ON x.country_key = c.country_key;

-- Q2: continent comparison (vaccination share uses only countries that report vaccinations)
CREATE OR REPLACE TABLE a_continent_summary AS
SELECT continent, COUNT(*) AS countries, SUM(population) AS population,
  SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths,
  ROUND(SUM(total_cases) * 1e6 / SUM(population), 1)  AS cases_per_million,
  ROUND(SUM(total_deaths) * 1e6 / SUM(population), 1) AS deaths_per_million,
  ROUND(100.0 * SUM(total_deaths) / NULLIF(SUM(total_cases), 0), 3) AS cfr_pct,
  ROUND(100.0 * SUM(people_vaccinated) / NULLIF(SUM(CASE WHEN people_vaccinated IS NOT NULL THEN population END), 0), 2) AS pct_vaccinated
FROM a_country_latest GROUP BY continent;

-- Q3: global timeline
CREATE OR REPLACE TABLE a_monthly_global AS
SELECT m.year_month, concat(substr(CAST(m.year_month AS STRING), 1, 4), '-', substr(CAST(m.year_month AS STRING), 5, 2)) AS month_label,
  SUM(m.new_cases) AS new_cases, SUM(m.new_deaths) AS new_deaths,
  ROUND(100.0 * SUM(m.new_deaths) / NULLIF(SUM(m.new_cases), 0), 3) AS monthly_cfr_pct
FROM fact_country_month m GROUP BY m.year_month;

CREATE OR REPLACE TABLE a_yearly AS
SELECT CAST(year_month / 100 AS INT) AS year, SUM(new_cases) AS new_cases, SUM(new_deaths) AS new_deaths,
  ROUND(100.0 * SUM(new_deaths) / NULLIF(SUM(new_cases), 0), 3) AS cfr_pct,
  ROUND(100.0 * SUM(new_deaths) / SUM(SUM(new_deaths)) OVER (), 2) AS pct_of_all_deaths
FROM fact_country_month GROUP BY CAST(year_month / 100 AS INT);

CREATE OR REPLACE TABLE a_continent_month AS
SELECT c.continent, m.year_month, SUM(m.new_cases) AS new_cases, SUM(m.new_deaths) AS new_deaths,
  ROUND(SUM(m.new_deaths) * 1e6 / SUM(c.population), 2) AS deaths_per_million
FROM fact_country_month m JOIN dim_country c ON c.country_key = m.country_key
GROUP BY c.continent, m.year_month;

CREATE OR REPLACE TABLE a_continent_peak AS
SELECT continent, year_month AS peak_death_month, new_deaths AS peak_month_deaths, deaths_per_million AS peak_deaths_per_million
FROM a_continent_month
QUALIFY ROW_NUMBER() OVER (PARTITION BY continent ORDER BY new_deaths DESC) = 1;

-- Q5: vaccination coverage at end-2021 vs deaths per million afterwards (countries >= 1M people)
CREATE OR REPLACE TABLE a_vax_band_outcomes AS
WITH e21 AS (
  SELECT country_key, MAX(people_vaccinated) AS vax_2021, MAX(total_deaths) AS deaths_2021
  FROM fact_covid_daily WHERE obs_date <= DATE'2021-12-31' GROUP BY country_key
), b AS (
  SELECT l.country_key, l.population, l.median_age, l.total_deaths, COALESCE(e.deaths_2021, 0) AS deaths_2021,
    100.0 * e.vax_2021 / l.population AS pct_vax_2021
  FROM a_country_latest l JOIN e21 e ON e.country_key = l.country_key
  WHERE l.pop_1m_plus_flag = 1 AND e.vax_2021 IS NOT NULL AND l.total_deaths IS NOT NULL
)
SELECT CASE WHEN pct_vax_2021 < 40 THEN '1 <40%' WHEN pct_vax_2021 < 60 THEN '2 40-60%'
            WHEN pct_vax_2021 < 75 THEN '3 60-75%' ELSE '4 >=75%' END AS vax_band_end_2021,
  COUNT(*) AS countries,
  ROUND(SUM(deaths_2021) * 1e6 / SUM(population), 1) AS deaths_pm_2020_21,
  ROUND(SUM(total_deaths - deaths_2021) * 1e6 / SUM(population), 1) AS deaths_pm_2022_24,
  ROUND(AVG(median_age), 1) AS avg_median_age
FROM b GROUP BY 1;

-- Q6: demographics - deaths per million by median-age band (countries >= 1M people)
CREATE OR REPLACE TABLE a_age_band_deaths AS
SELECT CASE WHEN median_age < 25 THEN '1 <25' WHEN median_age < 35 THEN '2 25-35'
            WHEN median_age < 42 THEN '3 35-42' ELSE '4 42+' END AS median_age_band,
  COUNT(*) AS countries, ROUND(SUM(total_deaths) * 1e6 / SUM(population), 1) AS deaths_per_million,
  ROUND(100.0 * SUM(total_deaths) / NULLIF(SUM(total_cases), 0), 3) AS cfr_pct
FROM a_country_latest WHERE pop_1m_plus_flag = 1 AND median_age IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY 1;

-- Q7: vaccine equity by World Bank income group (OWID aggregates, latest reported value)
CREATE OR REPLACE TABLE a_income_vaccination AS
SELECT location AS income_group, obs_date AS as_of, people_vaccinated_per_hundred AS pct_vaccinated
FROM cln_aggregate_daily
WHERE iso_code IN ('OWID_HIC', 'OWID_UMC', 'OWID_LMC', 'OWID_LIC', 'OWID_WRL') AND people_vaccinated_per_hundred IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY location ORDER BY obs_date DESC) = 1;

CREATE OR REPLACE TABLE a_kpi_headline AS
WITH s AS (SELECT COUNT(*) AS countries, SUM(population) AS population, SUM(total_cases) AS total_cases,
                  SUM(total_deaths) AS total_deaths FROM a_country_latest),
     d AS (SELECT MIN(obs_date) AS first_date, MAX(obs_date) AS last_date, COUNT(*) AS country_days FROM fact_covid_daily),
     p AS (SELECT month_label AS peak_death_month, new_deaths AS peak_month_deaths FROM a_monthly_global
           ORDER BY new_deaths DESC LIMIT 1),
     w AS (SELECT pct_vaccinated AS world_pct_vaccinated FROM a_income_vaccination WHERE income_group = 'World')
SELECT s.countries, d.country_days, d.first_date, d.last_date, CAST(s.population AS BIGINT) AS population,
  CAST(s.total_cases AS BIGINT) AS total_cases, CAST(s.total_deaths AS BIGINT) AS total_deaths,
  ROUND(100.0 * s.total_deaths / s.total_cases, 3) AS cfr_pct,
  ROUND(s.total_deaths * 1e6 / s.population, 1) AS deaths_per_million,
  w.world_pct_vaccinated, p.peak_death_month, CAST(p.peak_month_deaths AS BIGINT) AS peak_month_deaths
FROM s CROSS JOIN d CROSS JOIN p CROSS JOIN w;
