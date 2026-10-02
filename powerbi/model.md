# Power BI model (star schema)

| Table | Grain | Key | Sample rows in data/ |
|---|---|---|---|
| fact_covid_daily | country × day | date_key + country_key | 61 (India, 2021-04-01 to 2021-05-31: the Delta wave) |
| fact_country_month | country × month | country_key + year_month | 72 (6 countries × the 12 months of 2021) |
| dim_country | country | country_key | 6 (IND, USA, BRA, GBR, ZAF, JPN) |
| dim_date | day | date_key | 61 (April and May 2021) |

The full tables in `data/clean_full/star/` hold 396,268, 13,257, 239 and 1,688 rows.

## Relationships (single direction, dim → fact)
- dim_country[country_key] 1→* fact_covid_daily[country_key]
- dim_country[country_key] 1→* fact_country_month[country_key]
- dim_date[date_key] 1→* fact_covid_daily[date_key]
- fact_country_month has no date dimension. Use `year_month` (an integer such as 202101) directly as the axis, or add a small calculated `dim_month = DISTINCT(dim_date[year_month], dim_date[year_month_label])` and relate it on year_month.

## Notes
- **Flows and stocks.** `new_cases` and `new_deaths` are daily flows, so SUM them. `total_*` and `people_vaccinated` are cumulative stocks, so take the latest value per country (see `Latest Deaths` in measures.dax) rather than summing.
- In fact_country_month the `_eom` columns already hold month-end stocks.
- `pop_1m_plus_flag` = 1 marks countries with at least 1M people. Use it as a filter for per-capita rankings.
- Flags (`dq_cases_revised_down`, `dq_vax_over_population`) are 0/1 integers.
- The CSVs here are sample-sized. For the full model, run `python run_pipeline.py --source full` and point Power BI at `data/clean_full/star/`.
