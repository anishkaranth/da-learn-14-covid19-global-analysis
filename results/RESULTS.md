# Results: OWID COVID-19, 2020-01-01 to 2024-08-14 (full data)

All numbers come from `python run_pipeline.py --source full` on DuckDB. Databricks reproduced them with 0 differences.

## KPIs
| Metric | Value |
|---|---|
| Countries / country-days | 239 / 396,268 |
| Population covered | 7,978,165,353 |
| Reported cases | 775,900,191 |
| Reported deaths | 7,058,885 |
| Case fatality rate | 0.91% |
| Deaths per million | 884.8 |
| World population with ≥ 1 dose | 70.61% |
| Peak month (deaths) | 2021-01 (484,000) |

## Continents
| Continent | Deaths | Deaths / M | Cases / M | CFR | ≥ 1 dose |
|---|---|---|---|---|---|
| South America | 1,355,939 | 3,104.1 | 157,525 | 1.97% | 86.0% |
| Europe | 2,102,483 | 2,813.0 | 338,391 | 0.83% | 70.1% |
| North America | 1,671,178 | 2,783.8 | 207,376 | 1.34% | 76.9% |
| Oceania | 32,918 | 730.9 | 333,120 | 0.22% | 64.9% |
| Asia | 1,637,249 | 346.7 | 63,859 | 0.54% | 78.6% |
| Africa | 259,118 | 181.6 | 9,214 | 1.97% | 39.1% |

**Peak death months:** Europe and North America in 2021-01, Asia and South America in 2021-05 (the Delta wave), Africa in 2021-08, and Oceania in 2022-07.

## By year
| Year | Cases | Deaths | CFR | Share of deaths |
|---|---|---|---|---|
| 2020 | 80.3M | 1,897,584 | 2.36% | 26.9% |
| 2021 | 200.3M | 3,549,359 | 1.77% | 50.3% |
| 2022 | 424.0M | 1,249,137 | 0.29% | 17.7% |
| 2023 | 69.2M | 322,650 | 0.47% | 4.6% |
| 2024 (to Aug) | 2.1M | 42,258 | 2.05% | 0.6% |

## Countries (population ≥ 1M)
- **Deaths per million:** Peru 6,490, Bulgaria 5,706, Bosnia and Herzegovina 5,069, Hungary 4,921, North Macedonia 4,766, Slovenia 4,757, Croatia 4,653, Georgia 4,580, Czechia 4,146, Latvia 4,039.
- **Absolute deaths:** United States 1,193,165, Brazil 702,116, India 533,623, Russia 403,188, Mexico 334,551.
- **Vaccination (≥ 1 dose):** the highest are UAE and Qatar at 105.8% (more than 100%, see the caveats), Cuba 96.4% and Portugal 95.6%. The lowest are Burundi 0.29%, Yemen 3.1%, Papua New Guinea 3.8% and Haiti 4.5%.

## Equity and demographics
- **≥ 1 dose by income group:** upper-middle 83.5%, high 79.9%, World 70.6%, lower-middle 66.5%, low 32.8% (as of 2023-12-31).
- **Deaths per million by median-age band:** under 25 years, 118 (55 countries); 25–35, 904; 35–42, 1,102; 42+, 2,066 (25 countries). The correlation between median age and deaths per million is 0.69.
- **Coverage at end of 2021 vs deaths per million from 2022 to 2024:**

  | Coverage band | Countries | Deaths/M, 2022–24 | Avg median age |
  |---|---|---|---|
  | Under 40% | 66 | 43.7 | 22.9 |
  | 40–60% | 28 | 106.1 | 31.8 |
  | 60–75% | 28 | 540.8 | 35.2 |
  | 75% or more | 33 | 275.1 | 38.5 |

  This comparison is confounded by age and by reporting capacity.

## Data quality
- 7,770 split-duplicate rows were merged, taking 429,435 raw rows to 421,665 entity-days.
- 26,525 OWID aggregate rows were separated out.
- 5,234 UK-nation rows were dropped to avoid double counting.
- Country-days with new_cases = 0: 351,142 (weekly reporting). Country-days with new_cases NULL: 6,197.
- 19 cumulative downward revisions were flagged.
- 286 country-days show people_vaccinated greater than population; 6 countries end above 100%.
- 20 countries never reported a vaccination.
- 10/10 assertions pass, including a reconciliation of country totals to OWID World within 1%.
