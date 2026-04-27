# Antenatal Corticosteroid Administration in Late Preterm Singleton Pregnancies

Reproducibility package for the major-revision resubmission of:

**Antenatal Corticosteroid Administration in Late Preterm Singleton Pregnancies: A Propensity Score-Weighted Analysis of Neonatal Outcomes**

## Version

`v2.2-ga-sensitivity-update`

This version adds reviewer-requested gestational-age sensitivity analyses to the existing pipeline, alongside AMA-style reference cleanup and updated terminology (PBV → PPV with first-use clarification).

The previous release `v2.1-delivery-mode-sensitivity` added the delivery-mode sensitivity analysis. The current release builds on that by additionally including gestational age in the propensity score model, both as a continuous variable and as a completed-week categorical variable.

## Main analytic cohort

- Source records: 1,091
- Singleton late preterm deliveries: 1,087
- Excluded: ACS before 34 weeks: 75
- Final analytic cohort: 1,012
- ACS exposed: 126
- No ACS: 886

## Primary outcome

The manuscript primary outcome is `oxygen_any`: documented initial respiratory support at birth/early neonatal stabilization, derived from the oxygen-support/neonatal-resuscitation fields. It includes hood oxygen, CPAP, positive-pressure ventilation (PPV; coded as PBV in the source dataset), or intubation.

`resp_any` is diagnosis-based pulmonary morbidity and is **not** the primary outcome.

## Key revised IPTW results

| Outcome | IPTW estimate |
|---|---:|
| Initial respiratory support at birth | OR 1.40, 95% CI 0.90–2.18, P=.130 |
| NICU admission | OR 1.10, 95% CI 0.69–1.75, P=.685 |
| Neonatal hypoglycemia | OR 2.14, 95% CI 0.63–7.28, P=.224 |
| Pulmonary morbidity (`resp_any`) | OR 0.87, 95% CI 0.48–1.56, P=.632 |
| Higher-intensity initial support | OR 0.96, 95% CI 0.59–1.57, P=.877 |
| Hospital-course respiratory support | OR 1.02, 95% CI 0.59–1.76, P=.939 |

## Sensitivity analyses for the primary outcome

| Analysis | n | OR | 95% CI | P |
|---|---:|---:|---:|---:|
| Unadjusted | 1,012 | 1.54 | 1.03–2.29 | .034 |
| Adjusted | 1,012 | 1.34 | 0.87–2.06 | .184 |
| **IPTW (primary)** | **1,012** | **1.40** | **0.90–2.18** | **.130** |
| IPTW + doubly robust | 1,012 | 1.41 | 0.87–2.27 | .159 |
| Include early ACS (IPTW) | 1,087 | 1.37 | 0.89–2.09 | .150 |
| Include early ACS (IPTW + DR) | 1,087 | 1.40 | 0.89–2.21 | .148 |
| Exclude delivery mode from PS (IPTW) | 1,012 | 1.54 | 1.01–2.35 | .046 |
| Exclude delivery mode from PS + DR | 1,012 | 1.57 | 1.02–2.42 | .042 |
| **Include GA in PS (continuous, days)** | **1,012** | **1.28** | **0.82–2.00** | **.282** |
| **Include GA in PS (completed-week category)** | **1,012** | **1.31** | **0.84–2.04** | **.241** |

## Gestational-age sensitivity analyses (new in v2.2)

Gestational age at delivery was not included in the primary propensity score because it may reflect delivery timing after the treatment decision rather than a conventional baseline confounder. Effect modification by gestational age was evaluated separately through completed-week stratified analyses, and sensitivity analyses including gestational age in the propensity score were used to assess robustness.

In response to reviewer feedback, we additionally re-fit the propensity score model with gestational age included, both as a continuous variable in days at birth and as a completed-week categorical variable.

When gestational age was added to the propensity score model:
- IPTW odds ratio attenuated from 1.40 (no GA) to 1.28 (continuous GA) or 1.31 (categorical GA).
- All confidence intervals continued to span the null.
- The qualitative conclusion (no significant association with respiratory support) was unchanged.

This pattern indicates that gestational age at delivery is an influential timing and baseline-risk proxy rather than a conventional baseline confounder, supporting the choice to handle it outside the primary propensity-score model and to assess robustness using completed-week stratification and GA-inclusive sensitivity analyses.

## Delivery-mode sensitivity analysis

Delivery mode was included in the primary propensity score. Because planned versus intrapartum cesarean delivery and absence of labor were unavailable, we also ran a sensitivity analysis excluding delivery mode from the propensity score.

| Sensitivity analysis | Primary outcome estimate |
|---|---:|
| Exclude delivery mode from PS (IPTW) | OR 1.54, 95% CI 1.01–2.35, P=.046 |
| Exclude delivery mode from PS + doubly robust adjustment | OR 1.57, 95% CI 1.02–2.42, P=.042 |

This sensitivity analysis supports delivery mode as an important measured confounder. It does **not** resolve residual confounding from absence of labor, planned versus intrapartum cesarean delivery, or indication severity.

## Run command

From the repository root:

```bash
Rscript code/ACS_late_preterm_statistical_script.R data/ACS_Late_Preterm_deidentified.csv outputs
```

The script will produce all CSVs listed below, plus diagnostic plots in `outputs/plots/`. The new GA sensitivity output is `outputs/ga_sensitivity_analyses.csv`.

## Important output files

- `outputs/outcome_results_main.csv`
- `outputs/outcome_results_continuous_main.csv`
- `outputs/outcome_results_by_gaweek.csv`
- `outputs/table3_gaweek_primary_outcome.csv`
- `outputs/outcome_results_sensitivity_exclude_delivery_mode.csv`
- `outputs/outcome_results_sensitivity_include_early.csv`
- `outputs/ga_sensitivity_analyses.csv` *(new in v2.2)*
- `outputs/dose_timing_summary_overall.csv`
- `outputs/initial_respiratory_support_modality.csv`
- `outputs/respiratory_support_descriptive_counts.csv`
- `outputs/key_manuscript_results.csv`
- `outputs/comparison_to_revised_manuscript_targets_v6.csv`
- `outputs/balance_smd_before_after.csv`
- `outputs/ps_boundary_and_weight_diagnostics_main.csv`

## Figures

The `figures/` folder contains manuscript-ready TIFF files with corrected metadata/captions. Diagnostic plots generated by the R script are in `outputs/plots/`.

In v2.2, **Figure 2 has been relabeled** for publication: variable-code labels (e.g., `bmi`, `gravida`, `type_of_delivery`) replaced with clinical labels (Body mass index, Gravidity, Delivery mode, etc.), and the legend now reads "Before IPTW" and "After IPTW" rather than "Unweighted" and "IPTW".

## Data use

The dataset is de-identified and provided for reproducibility of the associated manuscript. Do not attempt re-identification or linkage to external data sources.
