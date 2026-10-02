# Data

- `raw/owid-covid-data.csv` is the committed reproducible sample: 12 rows copied verbatim with all 67 columns.
  - It covers India, the United States, Brazil, South Africa and the World aggregate, each on 2021-12-31 and 2023-12-31.
  - It also includes the **split-duplicate pair** for Faroe Islands on 2021-01-29, where one row holds cases and the other holds vaccinations. This exercises the merge step.
  - It is built by `scripts/make_sample.py`.
- `raw_full/` is git-ignored. Fill it with `python scripts/download_full_data.py`, which downloads 98.4 MB and verifies SHA-256.
- `clean_full/` is git-ignored. It holds the star tables written by `run_pipeline.py --source full`.

The grain is one row per entity (`iso_code`) per day. Entities whose `iso_code` starts with `OWID_` and have no continent are aggregates: World, continents, income groups and the EU. `OWID_KOS` (Kosovo) and `OWID_CYN` (Northern Cyprus) are countries. `OWID_ENG`, `OWID_SCT`, `OWID_WLS` and `OWID_NIR` are UK nations and are dropped.
