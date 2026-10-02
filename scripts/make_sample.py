#!/usr/bin/env python3
"""Build the git-sized raw sample in data/raw/ from data/raw_full/ (deterministic, rows copied verbatim).

Rule: India, United States, Brazil, South Africa and World on 2021-12-31 and 2023-12-31, plus the
split-duplicate pair for Faroe Islands on 2021-01-29 (exercises the merge step in sql/02)."""
import csv, pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
FULL, OUT = ROOT / "data/raw_full", ROOT / "data/raw"
OUT.mkdir(parents=True, exist_ok=True)
ISO, DATES = {"IND", "USA", "BRA", "ZAF", "OWID_WRL"}, {"2021-12-31", "2023-12-31"}
n = 0
with open(FULL / "owid-covid-data.csv", newline="", encoding="utf-8") as f, \
     open(OUT / "owid-covid-data.csv", "w", newline="", encoding="utf-8") as g:
    w = csv.writer(g, lineterminator="\n")
    for i, r in enumerate(csv.reader(f)):
        if i == 0 or (r[0] in ISO and r[3] in DATES) or (r[0] == "FRO" and r[3] == "2021-01-29"):
            w.writerow(r); n += i > 0
print("rows", n)
