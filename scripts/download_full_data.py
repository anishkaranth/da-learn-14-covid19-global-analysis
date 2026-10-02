#!/usr/bin/env python3
"""Download the full OWID COVID-19 dataset into data/raw_full/ and verify SHA-256.

Source  : Our World in Data, https://github.com/owid/covid-19-data (public/data/owid-covid-data.csv).
          OWID stopped updating this file in Aug 2024; the pinned snapshot ends 2024-08-14.
Kaggle  : https://www.kaggle.com/datasets/caesarmario/our-world-in-data-covid19-dataset (same OWID file, re-hosted)
Licence : Creative Commons BY 4.0 (OWID). Underlying case/death data: WHO; vaccinations: official national sources.
"""
import hashlib, pathlib, urllib.request

URL = "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv"
SHA = "8473d0f0fdf962e1ffbd5b85b18726fc96a49bab109e271186c339725a12b10c"
out = pathlib.Path(__file__).resolve().parents[1] / "data" / "raw_full"
out.mkdir(parents=True, exist_ok=True)
p = out / "owid-covid-data.csv"
if not p.exists():
    print("downloading", URL)
    urllib.request.urlretrieve(URL, p)
got = hashlib.sha256(p.read_bytes()).hexdigest()
print(f"{p.name} {p.stat().st_size:,} bytes  {'OK' if got == SHA else 'CHECKSUM MISMATCH ' + got + ' (upstream file changed?)'}")
raise SystemExit(0 if got == SHA else 1)
