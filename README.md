# Antenatal Corticosteroid Administration in Late Preterm Singleton Pregnancies

This repository contains the de-identified dataset, R analysis code, and outputs for:

**Antenatal Corticosteroid Administration in Late Preterm Singleton Pregnancies: A Propensity Score-Weighted Analysis of Neonatal Outcomes**

## Repository status

This version was prepared for the major-revision resubmission. The repository was updated to align the public analysis package with the revised manuscript and reviewer response, including added ACS dose/timing summaries and respiratory-support modality tables.

## Main analysis

The analytic cohort was defined as singleton late preterm deliveries at 34+0 to 36+6 weeks. Pregnancies with ACS before 34 weeks were excluded from the main cohort to reduce exposure mixing.

| Quantity | Value |
|---|---:|
| Source records | 1,091 |
| Singleton late-preterm deliveries | 1,087 |
| Excluded: ACS before 34 weeks | 75 |
| Final analytic cohort | 1,012 |
| ACS 34+0 to 36+6 weeks | 126 |
| No ACS 34+0 to 36+6 weeks | 886 |

The primary outcome is **any initial respiratory support at birth**, represented in the analysis as `oxygen_any`, derived from `oxygen_support`. It includes hood oxygen, CPAP, positive-pressure ventilation/PBV, or intubation. The variable `resp_any` is diagnosis-based pulmonary morbidity and is not the primary outcome.

## Key results from the revised analysis

| Outcome | IPTW estimate |
|---|---|
| Any initial respiratory support at birth (`oxygen_any`) | OR 1.39, 95% CI 0.89–2.15, P=.148 |
| NICU admission | OR 1.08, 95% CI 0.67–1.71, P=.759 |
| Neonatal hypoglycemia | OR 2.08, 95% CI 0.61–7.11, P=.243 |
| Diagnosis-based pulmonary morbidity (`resp_any`) | OR 0.86, 95% CI 0.48–1.54, P=.603 |

Among ACS-exposed pregnancies in the analytic cohort, 108/126 (85.7%) received a single documented dose and 18/126 (14.3%) received a documented double-dose course. Delivery occurred within 24 hours of ACS in 70/126 (55.6%), between 24 hours and 7 days in 48/126 (38.1%), and after more than 7 days in 8/126 (6.3%).

## Contents

```text
data/
  ACS_Late_Preterm_deidentified.csv       Source de-identified dataset

code/
  ACS_late_preterm_statistical_script.R   Main reproducible R analysis pipeline

outputs/
  outcome_results_main.csv                Binary outcomes: crude, adjusted, IPTW, doubly robust
  outcome_results_continuous_main.csv     Continuous outcomes
  outcome_results_by_gaweek.csv           Exploratory GA-week stratified results
  outcome_results_sensitivity_include_early.csv
  balance_smd_before_after.csv            Covariate balance before/after IPTW
  ps_boundary_and_weight_diagnostics_main.csv
  dose_timing_summary_treated.csv         Dose-by-timing cross-tab among treated pregnancies
  dose_timing_summary_overall.csv         Overall dose and timing summaries among treated pregnancies
  initial_respiratory_support_modality.csv
  respiratory_support_descriptive_counts.csv
  outcome_definitions.csv
  key_manuscript_results.csv
  session_info.txt
  plots/

figures/
  Figure_1.tif, Figure_2.tif, Figure_S1.tif, Figure_S2.tif
  Figure_1.png, Figure_2.png, Figure_S1.png, Figure_S2.png

docs/
  data_dictionary.csv
  CODEBOOK.md
  repository_revision_notes.md
  reproducibility_checklist.md
  upload_commands.md
```

## Reproducibility

From the repository root, run:

```bash
Rscript code/ACS_late_preterm_statistical_script.R data/ACS_Late_Preterm_deidentified.csv outputs
```

The script reads either CSV or SPSS `.sav` files, but the repository package uses the CSV file. It will create/overwrite files in `outputs/` and `outputs/plots/`.

The analysis used R 4.5.2 in the exported `outputs/session_info.txt`. R >=4.2 is expected to work if the listed packages are available.

## Important interpretation notes

`oxygen_any` is the manuscript primary outcome: documented initial respiratory support at birth.

`support_modality` gives the modality breakdown requested during peer review: no support, hood oxygen only, CPAP, PBV/positive-pressure ventilation, or intubation.

`high_intensity_initial_support` is an exploratory descriptive endpoint including CPAP, PBV/positive-pressure ventilation, or intubation.

`hospital_course_respiratory_support` is a descriptive endpoint based on support duration variables: oxygen days, nasal/non-invasive mechanical ventilation days, or invasive mechanical ventilation days.

`resp_any` is diagnosis-based pulmonary morbidity from the `respiratory_morbidity` field and should not be interpreted as the same outcome as initial respiratory support.

Gestational-age stratified results in `outcome_results_by_gaweek.csv` are exploratory and should be interpreted cautiously because subgroup sample sizes and event counts are limited.

## Data availability and use

The CSV contains de-identified clinical data without direct identifiers or dates. A pseudonymized record ID is retained only to allow reproducibility checks. Users should not attempt to re-identify individuals or link records to external sources. See `DATA_USE.md`.

## Citation

Please cite the associated manuscript and this repository. A machine-readable citation file is provided in `CITATION.cff`.

## Journal-facing repository structure

This repository is organized for peer-review reproducibility:

- `code/`: executable R analysis script.
- `data/`: de-identified analytic dataset and data README.
- `outputs/tables/`: CSV outputs used to support manuscript tables, supplementary tables, and reviewer-requested analyses.
- `outputs/figures/`: diagnostic plot outputs generated by the script.
- `figures/`: manuscript-ready TIFF/PNG figure files.
- `docs/`: codebook, data dictionary, repository revision notes, reproducibility checklist, and manuscript–repository alignment checklist.
- `archive/`: reserved for previous submission materials or versioned source files, if needed.

The recommended citation/version for this revised submission is `v2.0-major-revision`.
