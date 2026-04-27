# Changelog

## v2.2-ga-sensitivity-update

Reviewer-response update adding gestational-age sensitivity analyses, AMA-style reference cleanup, and updated terminology.

Changes:
- **Added gestational-age sensitivity analyses** to the primary IPTW pipeline:
  - PS model with gestational age included as continuous (days at birth):
    OR 1.28, 95% CI 0.82–2.00, P=.282
  - PS model with gestational age included as completed-week category:
    OR 1.31, 95% CI 0.84–2.04, P=.241
  - Both confirm the primary qualitative finding (CI crosses 1) and show that
    gestational age at delivery acts as an influential timing and baseline-risk
    proxy in this cohort.
- Added new output file `outputs/ga_sensitivity_analyses.csv` with the three
  comparable estimates (primary + two sensitivities).
- Embedded the GA sensitivity block in the main analysis script
  (`code/ACS_late_preterm_statistical_script.R`) immediately after the
  delivery-mode sensitivity analysis. Script grows from 849 to 954 lines.
- **Manuscript/documentation revisions** reflected in this release:
  - Methods, Results, Discussion, and Limitations text updated to describe and
    reference the new GA sensitivity analyses.
  - Supplementary Table S2 expanded to 11 rows (added 2 GA-sensitivity rows).
  - PBV terminology replaced with PPV throughout, with first-use clarification
    "positive-pressure ventilation (PPV; coded as PBV in the source dataset)".
  - Reference 41 page prefix corrected to F250–F255 (Arch Dis Child Fetal Neonatal Ed).
  - References 11 and 43 trimmed from 6 authors+et al to 3 authors+et al per
    AMA/Index Medicus style.
  - Trailing periods removed from all 44 reference list entries (AMA style).
- **Figure 2 relabeled** for publication: variable-code labels replaced with
  clinical labels (Maternal age, Body mass index, Gravidity, Parity, Assisted
  conception, Maternal comorbidity, Medication use, Maternal infection, Delivery
  indication, Delivery mode, Fetal sex). Legend now reads "Before IPTW" and
  "After IPTW". High-resolution PNG (300 dpi) and LZW-compressed TIFF provided.

## v2.1-delivery-mode-sensitivity

Updated after rerunning the primary IPTW model with the revised R script.

Changes:
- Updated primary IPTW estimate to OR 1.40, 95% CI 0.90–2.18, P=.130.
- Updated secondary and continuous outcome estimates throughout manuscript-facing outputs.
- Updated gestational-age-stratified primary-outcome estimates:
  - 34 weeks: OR 0.62, 95% CI 0.25–1.53, P=.305
  - 35 weeks: OR 0.69, 95% CI 0.29–1.62, P=.391
  - 36 weeks: OR 2.25, 95% CI 1.07–4.72, P=.033
- Added sensitivity analysis excluding delivery mode from the propensity score.
- Added `comparison_to_revised_manuscript_targets_v6.csv`.
- Updated figures from rerun output where applicable.

## v2.0-major-revision

Major revision package with ACS dose/timing summaries, respiratory-support modality counts, updated endpoint definitions, and revised documentation.
