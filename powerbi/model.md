# Power BI model (star schema)

| Table | Grain | Key | Sample rows in data/ |
|---|---|---|---|
| fact_country_month | country × month | country_key + year_month | 72 (6 countries, months of 2021) |
| fact_covid_daily | country × day | country_key + date_key | 61 (India, 2021-04-01 to 2021-05-31) |
| dim_country | country | country_key | 6 (BRA, GBR, IND, JPN, USA, ZAF) |
| dim_date | day | date_key (yyyymmdd) | 61 |

## Relationships (single direction, dim → fact)
- dim_country[country_key] 1→* fact_country_month[country_key], and 1→* fact_covid_daily[country_key]
- dim_date[date_key] 1→* fact_covid_daily[date_key]
- For month-level time slicing, add a calculated `Month` table (DISTINCT dim_date[year_month], year_month_label) and relate it to fact_country_month[year_month].

## Notes
- Flows (new_cases, new_deaths) are additive. Stocks (`*_eom`, total_*) are **not** additive over time, so use the "latest" measures for them.
- dim_country carries the population, median_age, gdp_per_capita and pop_1m_plus_flag columns. Use pop_1m_plus_flag = 1 for rankings.
- For the full model, run `python run_pipeline.py --source full` and load `data/clean_full/star/*.csv` (13,257 monthly rows and 396,268 daily rows).
