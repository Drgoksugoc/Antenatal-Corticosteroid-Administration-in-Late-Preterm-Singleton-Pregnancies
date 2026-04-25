# Repository revision notes

This repository update was prepared after the major-revision analysis.

Main changes included in this package:

1. The README now points to the actual script path: `code/ACS_late_preterm_statistical_script.R`.
2. The default script paths now match the repository layout: `data/ACS_Late_Preterm_deidentified.csv` and `outputs/`.
3. The primary outcome is explicitly identified as `oxygen_any`, defined from `oxygen_support`.
4. The diagnosis-based pulmonary morbidity variable `resp_any` is clearly distinguished from the primary outcome.
5. Added `outputs/outcome_definitions.csv`.
6. Added `outputs/initial_respiratory_support_modality.csv` to answer the reviewer/editor request for modality-specific support counts.
7. Added `outputs/respiratory_support_descriptive_counts.csv` to separate initial respiratory support from hospital-course respiratory support.
8. Added `outputs/dose_timing_summary_overall.csv` to summarize ACS dose completeness and ACS-to-delivery timing.
9. Added `docs/data_dictionary.csv` and `docs/CODEBOOK.md`.
10. Added corrected submission figures, including corrected Figure 2 TIFF metadata/caption.

Important note: `outcome_results_by_gaweek.csv` contains exploratory stratified results for multiple outcomes. The variable `resp_any` in that file is diagnosis-based pulmonary morbidity, not the manuscript primary outcome. For the primary outcome within GA strata, use rows where `outcome == "oxygen_any"`.
