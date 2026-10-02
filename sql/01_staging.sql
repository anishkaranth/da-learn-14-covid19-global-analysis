-- 01_staging.sql  Land the OWID CSV as an all-STRING table (no type inference); types are applied in 02.
-- {{RAW_DIR}} is set by run_pipeline.py. Databricks: read_files(..., format => 'csv', header => true, inferColumnTypes => false)
CREATE OR REPLACE TABLE stg_covid AS
SELECT * FROM read_csv('{{RAW_DIR}}/owid-covid-data.csv', header = true, all_varchar = true);
