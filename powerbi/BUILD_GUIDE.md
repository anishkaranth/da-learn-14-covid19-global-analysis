# Build guide (Power BI Desktop)

1. **Get data.** Use Get data → Text/CSV and load the 4 files in `powerbi/data/`. For the full model, load `data/clean_full/star/` after running the full pipeline.
2. **Types.** Set `full_date` and `obs_date` to Date. Set the `*_key`, year_month, counts and population columns to Whole number. Set the rates, stringency and age columns to Decimal.
3. **Relationships.** Create them as listed in [model.md](model.md). Optionally add the `Month` table described there.
4. **Measures.** Paste the measures from [measures.dax](measures.dax) into a `_Measures` table. Format CFR % and Vaccinated % as percentages, and Deaths per Million as a whole number.
5. **Pages.** Build the pages in [dashboard_spec.md](dashboard_spec.md), using accent colour #1f6f8b to match `results/charts/dashboard.svg`.
6. **Validate.** On the full data, the cards must match the expected values in the spec.
7. Save the .pbix locally. It is not committed, because it needs Windows.
