# Manuscript–Repository Alignment: v2.2

This repository package corresponds to the revised manuscript using the v2.2 rerun outputs (which include the new gestational-age sensitivity analyses on top of the v2.1 delivery-mode sensitivity).

The manuscript should report:

- Primary outcome IPTW OR 1.40, 95% CI 0.90–2.18, P=.130.
- Hypoglycemia IPTW OR 2.14, 95% CI 0.63–7.28, P=.224.
- NICU admission IPTW OR 1.10, 95% CI 0.69–1.75, P=.685.
- Pulmonary morbidity IPTW OR 0.87, 95% CI 0.48–1.56, P=.632.
- Table 3 primary outcome:
  - 34 weeks: OR 0.62, 95% CI 0.25–1.53, P=.305.
  - 35 weeks: OR 0.69, 95% CI 0.29–1.62, P=.391.
  - 36 weeks: OR 2.25, 95% CI 1.07–4.72, P=.033.
- Sensitivity excluding delivery mode from PS:
  - IPTW OR 1.54, 95% CI 1.01–2.35, P=.046.
  - Doubly robust OR 1.57, 95% CI 1.02–2.42, P=.042.
- Sensitivity including gestational age in PS *(new in v2.2)*:
  - GA continuous (days): IPTW OR 1.28, 95% CI 0.82–2.00, P=.282.
  - GA completed-week category: IPTW OR 1.31, 95% CI 0.84–2.04, P=.241.

## Interpretive guidance for the manuscript

- The delivery-mode exclusion result should be described as evidence that delivery mode is an important measured confounder — not as evidence of ACS-related harm.
- The gestational-age inclusion result should be described as showing that adding GA to the PS attenuates the IPTW odds ratio toward the null. Gestational age at delivery is best framed as an influential timing and baseline-risk proxy that may reflect delivery timing after the treatment decision rather than a conventional baseline confounder. The qualitative finding (no significant association) is unchanged across all three PS specifications.
- All three sensitivity rows have CIs that span 1, so the manuscript's overall conclusion that late-preterm ACS exposure was not associated with lower odds of initial respiratory support remains supported.

## What is new in v2.2 vs v2.1

- New output: `outputs/ga_sensitivity_analyses.csv` with three rows (primary, GA continuous, GA categorical).
- New code block in `code/ACS_late_preterm_statistical_script.R` (lines ~685–789) implementing the two GA-inclusive PS models.
- Manuscript Methods updated to describe the GA sensitivity analyses.
- Manuscript Results updated to report the GA sensitivity numbers.
- Manuscript Discussion (Gestational Age-Stratified Findings subsection) updated to describe gestational age at delivery as an influential timing and baseline-risk proxy.
- Manuscript Limitations updated to reference Supplementary Table S2.
- Supplementary Table S2 expanded from 9 to 11 rows to include the two GA sensitivities.
- Figure 2 relabeled with clinical variable names and "Before/After IPTW" legend.
- Reference list cleaned to AMA/Index Medicus style (no trailing periods, refs 11 and 43 trimmed to 3 authors + et al, ref 41 page prefix corrected to F250–F255).
- PBV terminology globally replaced with PPV, with first-use clarification "positive-pressure ventilation (PPV; coded as PBV in the source dataset)".
