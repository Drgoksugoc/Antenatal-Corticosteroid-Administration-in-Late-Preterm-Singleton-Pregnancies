# Reproducibility checklist

Before pushing the repository update, verify the following:

- [ ] `data/ACS_Late_Preterm_deidentified.csv` is present and opens as a 1,091-row, 36-column CSV.
- [ ] No direct identifiers or dates are present in the dataset.
- [ ] `code/ACS_late_preterm_statistical_script.R` runs from the repository root.
- [ ] The run command is:

```bash
Rscript code/ACS_late_preterm_statistical_script.R data/ACS_Late_Preterm_deidentified.csv outputs
```

- [ ] `outputs/outcome_results_main.csv` includes the primary outcome `oxygen_any`.
- [ ] `outputs/outcome_definitions.csv` clarifies that `oxygen_any` is the primary outcome.
- [ ] `outputs/initial_respiratory_support_modality.csv` includes no support, hood oxygen only, CPAP, PBV/positive-pressure ventilation, and intubation.
- [ ] `outputs/dose_timing_summary_overall.csv` reports 108 single-dose and 18 double-dose ACS cases in the main treated cohort.
- [ ] `figures/Figure_2.tif` is the corrected figure file.
- [ ] `README.md`, `CITATION.cff`, `LICENSE`, and `DATA_USE.md` are present.
