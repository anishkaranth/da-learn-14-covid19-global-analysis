# Build guide (Power BI Desktop)

1. **Get data.** Use Get data → Text/CSV and load the four files in `powerbi/data/`. For the full data, first run `python scripts/download_full_data.py && python run_pipeline.py --source full`, then load the same four tables from `data/clean_full/star/`.
2. **Types.** In Power Query, set `obs_date` and `full_date` to Date, the `*_key`, `year_month`, case, death and vaccination columns to Whole number, `stringency_index`, `gdp_per_capita` and `median_age` to Decimal, and everything else to Text.
3. **Date table.** Mark `dim_date` as a date table on `full_date`.
4. **Relationships.** Create them as listed in [model.md](model.md), all single direction from dim to fact.
5. **Measures.** Create a blank `_Measures` table and paste each measure from [measures.dax](measures.dax). Format CFR % and Pct Vaccinated as percentages with 2 decimals, and the per-million measures with 1 decimal.
6. **Report.** Build the three pages in [dashboard_spec.md](dashboard_spec.md). Use one accent colour (#1f6f8b) to match `results/charts/dashboard.svg`.
7. **Check.** On the full data the cards should show the expected values listed at the end of the spec. On the sample CSVs (6 countries, 2021) the numbers will differ.
8. Save the .pbix locally. It is not committed, because it needs Windows.
