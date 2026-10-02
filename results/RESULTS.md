# Results: COVID-19 global 2020–2024 (full data)

All numbers come from `python run_pipeline.py --source full` on DuckDB over the full OWID file (429,435 raw rows). Databricks reproduced them with 0 differences.

## KPIs
| Metric | Value |
|---|---|
| Countries / country-days | 239 / 396,268 |
| Date range | 2020-01-01 to 2024-08-14 |
| Population covered | 7,978,165,353 |
| Reported cases | 775,900,191 |
| Reported deaths | 7,058,885 |
| Case fatality rate | 0.91% |
| Deaths per million | 884.8 |
| World population with ≥ 1 dose | 70.61% |
| Peak death month | 2021-01 (484,000 deaths) |

## Continents
| Continent | Cases | Deaths | Deaths / million | ≥ 1 dose |
|---|---|---|---|---|
| South America | 68,809,418 | 1,355,939 | 3,104.1 | 86.01% |
| Europe | 252,916,868 | 2,102,483 | 2,813.0 | 70.08% |
| North America | 124,492,666 | 1,671,178 | 2,783.8 | 76.92% |
| Oceania | 15,003,352 | 32,918 | 730.9 | 64.93% |
| Asia | 301,532,347 | 1,637,249 | 346.7 | 78.57% |
| Africa | 13,145,540 | 259,118 | 181.6 | 39.05% |

Peak death months by continent: Europe and North America in 2021-01, Asia and South America in 2021-05, Africa in 2021-08 and Oceania in 2022-07. South America's peak was 326.26 deaths per million in a single month.

## By year
| Year | New cases | New deaths | CFR |
|---|---|---|---|
| 2020 | 80,317,671 | 1,897,584 | 2.36% |
| 2021 | 200,298,480 | 3,549,359 | 1.77% |
| 2022 | 424,017,377 | 1,249,137 | 0.30% |
| 2023 | 69,238,166 | 322,650 | 0.47% |
| 2024 (to Aug) | 2,063,363 | 42,258 | 2.05% (few cases reported) |

## Countries (population at least 1M)
- **Deaths per million:** Peru 6,489.8 (CFR 4.88%), Bulgaria 5,706.3, Bosnia and Herzegovina 5,069.4, Hungary 4,921.4, North Macedonia 4,765.9.
- **Total deaths:** United States 1,193,165, Brazil 702,116, India 533,623, Russia 403,188, Mexico 334,551.
- **≥ 1 dose:** the highest are UAE and Qatar at 105.83% (non-residents, so flagged), Cuba 96.37% and Portugal 95.62%. The lowest are Burundi 0.29%, Yemen 3.12%, Papua New Guinea 3.77% and Haiti 4.50%.

## Vaccination, income and age
- **≥ 1 dose by income group:** upper-middle 83.49%, high 79.86%, world 70.61%, lower-middle 66.49%, low 32.76%.
- **Median-age band:** under 25 → 117.9 deaths per million (55 countries); 25–35 → 903.5; 35–42 → 1,102.4; 42 or more → 2,065.6 (25 countries).
- **Vaccination by the end of 2021 against deaths per million in 2022–24:** under 40% → 43.7; 40–60% → 106.1; 60–75% → 540.8; 75% or more → 275.1. The low-vaccination band is also the youngest (average median age 22.9) and reports the least, so this is confounded, not causal.

## Data quality
- 429,435 raw rows contain 421,665 distinct (iso_code, date) keys. The 7,770 split duplicates were merged.
- 26,525 aggregate rows were separated, and 5,234 UK-nation rows were dropped.
- 6,197 country-days have NULL new_cases, and 351,142 have new_cases = 0 because of weekly reporting.
- Cumulative cases were revised downwards 19 times. 286 country-days have people_vaccinated above population, and 20 countries never reported a vaccination.
- 10/10 assertions pass: one row per country-day, foreign-key integrity, no negative flows, deaths ≤ cases, monthly sums equal daily sums, and country totals within 1% of the OWID World row.

## Charts
`charts/dashboard.svg`, `monthly_deaths.svg`, `continent_deaths_pm.svg`, `top_deaths_pm.svg`, `yearly_cfr.svg`, `income_vaccination.svg`, `age_band_deaths.svg` (vector SVG only).
