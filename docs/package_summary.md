# Package summary

Prepared repository update folder: `acs_late_preterm_repository_update`.

Source data SHA-256: `94780bd7934e34ce9314283f7cce128bb08815c5a5459c32d88403d17559dac6`

Main cohort:
- n = 1012
- ACS = 126
- No ACS = 886

Added reviewer/editor support files:
- `outputs/initial_respiratory_support_modality.csv`
- `outputs/respiratory_support_descriptive_counts.csv`
- `outputs/dose_timing_summary_overall.csv`
- `outputs/outcome_definitions.csv`
- `docs/data_dictionary.csv`
- `docs/CODEBOOK.md`

Run command:
```bash
Rscript code/ACS_late_preterm_statistical_script.R data/ACS_Late_Preterm_deidentified.csv outputs
```
