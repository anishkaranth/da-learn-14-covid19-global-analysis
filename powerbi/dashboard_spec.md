# Dashboard spec: COVID-19 global analysis

**Page 1 · Global overview.** Slicers: continent, year.
- Cards: Countries, New Cases, New Deaths, CFR %, Deaths per Million, Pct Vaccinated (≥1 dose)
- Line: Monthly Deaths by fact_country_month[year_month]
- Clustered bar: Deaths per Million by dim_country[continent], sorted descending
- Column: CFR % by dim_date[year]

**Page 2 · Countries.** Visual-level filter: dim_country[pop_1m_plus_flag] = 1.
- Bar: Deaths per Million by dim_country[location], Top N = 10
- Bar: Pct Vaccinated by dim_country[location], Bottom N = 10
- Scatter: x = dim_country[median_age], y = Deaths per Million, size = Population, legend = continent

**Page 3 · Waves.**
- Line: Deaths 7d Avg by dim_date[full_date], with continent as the legend (small multiples)
- Matrix: continent × year_month with Monthly Deaths and conditional formatting (a heatmap)

Expected values on the full data, to sanity-check your build: New Deaths 7,058,885, New Cases 775,900,191, CFR 0.91%, Deaths per Million 884.8, peak month 2021-01 with 484,000 deaths, Peru 6,489.8 deaths per million.
