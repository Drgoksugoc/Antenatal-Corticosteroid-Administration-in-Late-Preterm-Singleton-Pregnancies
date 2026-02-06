Antenatal Corticosteroid Administration in Late Preterm Singleton Pregnancies

This repository contains de-identified data and analysis code:

Contents

- `data/ACS_Late_Preterm_deidentified.csv` — source dataset (de-identified)
- `code/ACS_late_preterm_statistical_script.R` — main analysis pipeline (R)
- `outputs/` — key analysis outputs used to generate manuscript tables/figures
- `figures/` — submitted figure files (PNG + TIFF)
- `docs/` — STROBE checklist

Reproducibility (brief)

1. Open R (>=4.2 recommended).
2. Install packages referenced in `outputs/session_info.txt` as needed.
3. Run:
   - `Rscript code/ACS_late_preterm_advanced_pipeline_v1_5.R.`
4. Confirm generated results match files in `outputs/`.

Notes

- Primary outcome: “any respiratory support at birth” (reported as `oxygen_any`).
- The previously duplicated “resuscitation” endpoint is “not reported” in this version to avoid redundancy.
