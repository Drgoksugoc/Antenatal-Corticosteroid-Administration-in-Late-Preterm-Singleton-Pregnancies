# Release Notes: v2.2-ga-sensitivity-update

**Release date:** 2026-04-27

## Summary

This release adds gestational-age sensitivity analyses to the existing IPTW pipeline, in response to reviewer feedback on the major-revision submission. It also incorporates AMA-style reference cleanup and updated terminology (PBV → PPV) in the manuscript and supplementary documents.

## Why this release exists

In the previous resubmission round, a reviewer asked whether the propensity score should explicitly include gestational age at delivery, given the large unweighted GA imbalance between exposure groups (35.5 vs 36.0 weeks). The original pipeline excluded GA from the PS model on the grounds that GA at delivery may reflect delivery timing after the treatment decision rather than a conventional baseline confounder. To address this transparently, this release adds two sensitivity analyses re-fitting the PS model with GA included, allowing readers to see the effect on the primary IPTW estimate.

## Sensitivity analysis results

| Analysis | n | OR | 95% CI | P |
|---|---:|---:|---:|---:|
| Primary (no GA in PS) | 1,012 | 1.40 | 0.90–2.18 | .130 |
| PS with GA continuous (days) | 1,012 | 1.28 | 0.82–2.00 | .282 |
| PS with GA completed-week category | 1,012 | 1.31 | 0.84–2.04 | .241 |

**Interpretation:** Adding GA to the propensity score attenuates the IPTW odds ratio toward the null, but the 95% confidence interval continues to span 1 in all three analyses. The qualitative conclusion (no significant association between late preterm ACS exposure and initial respiratory support at birth) is unchanged across PS specifications. The attenuation pattern is consistent with GA being closer to a post-exposure timing variable than a baseline confounder, which supports the original prespecified decision to evaluate GA effect modification through completed-week stratified analyses rather than including it in the primary PS model.

## What changed in this release

### Code

- `code/ACS_late_preterm_statistical_script.R`: added a 105-line block immediately after the delivery-mode sensitivity analysis. Implements the two GA-inclusive PS models, fits the IPTW outcome model for each, and writes a combined CSV summary.

### Outputs (new)

- `outputs/ga_sensitivity_analyses.csv`: 3-row table with the primary IPTW OR (re-fit for column-comparable presentation) and both GA-inclusive sensitivity ORs.

### Figures

- `figures/Figure_2.png` and `figures/Figure_2.tif`: replaced. Variable-code labels (`bmi`, `gravida`, `type_of_delivery`, etc.) replaced with clinical labels (Body mass index, Gravidity, Delivery mode, etc.). Legend now reads "Before IPTW" and "After IPTW".

### Documentation

- `README.md`: version updated to v2.2; added a section describing the new GA sensitivity analyses; added a consolidated sensitivity-analysis table covering all primary-outcome sensitivities; added the new output CSV to the file index.
- `CHANGELOG.md`: v2.2 entry added at top; v2.1 and v2.0 entries preserved.
- `CITATION.cff`: version bumped to v2.2-ga-sensitivity-update; date-released updated to 2026-04-27.

## What did not change

- `data/ACS_Late_Preterm_deidentified.csv`: unchanged. Same 1,091 source records, same de-identification.
- `code/`: only the analysis script was modified. The script remains a single-file pipeline runnable with `Rscript code/ACS_late_preterm_statistical_script.R data/ACS_Late_Preterm_deidentified.csv outputs`.
- All previously-reported primary, secondary, and continuous-outcome IPTW estimates remain identical (the new code is additive — it does not modify any existing analysis path).
- All previously-existing output CSVs remain identical to v2.1.

## How to verify

After cloning this release, run:

```bash
Rscript code/ACS_late_preterm_statistical_script.R data/ACS_Late_Preterm_deidentified.csv outputs
```

The console output will include three new lines for the GA sensitivities and write `outputs/ga_sensitivity_analyses.csv` with the table above.

The `outputs/key_manuscript_results.csv` and `outputs/comparison_to_revised_manuscript_targets_v6.csv` files should match the v2.1 release exactly, confirming that the GA sensitivity addition does not perturb the primary analysis.
