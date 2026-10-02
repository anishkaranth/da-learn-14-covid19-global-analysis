# Dashboard spec: COVID-19 global analysis

**Page 1 · Global overview.** Slicers: continent, year.
- Cards: New Cases, New Deaths, CFR %, Deaths per Million, Vaccinated %
- Line: New Deaths by month
- Bar: Deaths per Million by dim_country[continent]
- Column: CFR % by year

**Page 2 · Countries.**
- Bar: Top 10 countries by Deaths per Million (pop_1m_plus_flag = 1)
- Scatter: x = dim_country[median_age], y = Deaths per Million, size = Population, legend = continent
- Table: country, New Deaths, Deaths per Million, CFR %, Vaccinated %

**Page 3 · Vaccination.**
- Bar: Vaccinated % by country (sorted ascending, to highlight gaps)
- Line: People Vaccinated (latest) by month for selected countries

Expected values on the full data: New Deaths 7,058,885, CFR % 0.91%, Deaths per Million 885, South America 3,104 per million, Peru 6,490 per million.
