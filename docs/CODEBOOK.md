# Codebook

This codebook describes the de-identified source dataset and the key derived variables used in the R script.

## Source variables

| Variable | Role | Type | Description | Observed values/range | Missing |
|---|---|---|---|---|---|
| ID_deidentified | identifier | string | Pseudonymized participant/record identifier. Direct identifiers and dates are not included. | Pt273 (1); Pt421 (1); Pt777 (1); Pt438 (1); Pt533 (1); Pt793 (1); Pt819 (1); Pt894 (1); Pt60 (1); Pt19 (1); Pt370 (1); Pt215 (1) | 0 |
| conception_type | covariate | categorical | Conception type; collapsed in analysis as spontaneous versus assisted. | spontaneus (1006); ıvf (84); IUI (1) | 0 |
| maternal_disease | covariate | categorical | Maternal disease/comorbidity recorded in the source chart; collapsed into comorbidity groups for the propensity score. | No (739); hypo-hyperthyroidia (91); DM (74); other (40); preeclampsi (38); ht (18); 3.4 (18); asthma (14); 2.3 (12); cholestasis (11); mi... | 0 |
| medication_use | covariate | categorical | Medication group recorded in the source chart; collapsed into medication-use groups for the propensity score. | no (833); thyroid (83); anticoagülan (43); antihipertansive (39); insulin + OAD (34); 2.6 (12); 2.4 (11); 1.6 (9); 4.6 (8); cholestasis (... | 0 |
| age | covariate | numeric | Maternal age in years. | numeric; min=17, max=45 | 0 |
| bmi | covariate | numeric | Maternal body mass index, kg/m². | numeric; min=0.0, max=46.6 | 0 |
| gravida | covariate | integer | Number of pregnancies. | numeric; min=1, max=10 | 0 |
| parity | covariate | integer | Number of prior births/parity. | numeric; min=0, max=5 | 0 |
| ga_weeks_at_birth | eligibility/covariate | integer | Completed gestational weeks at birth. | numeric; min=32, max=37 | 0 |
| ga_days_at_birth | eligibility/covariate | integer | Additional gestational days at birth. | numeric; min=0, max=6 | 0 |
| type_of_delivery | covariate | categorical | Mode of delivery: cesarean or vaginal birth. | Cesarean (675); vaginal birth (416) | 0 |
| indication_for_delivery | covariate | categorical | Primary indication for delivery; collapsed into groups for the propensity score. | preterm eylem (712); PROM (155); placental anomalia (67); fetal distress (59); preeclampsia (57); oligohidramniosis (12); none (10); 3.4 ... | 0 |
| acs_under_34w | exclusion/exposure | categorical | Whether antenatal corticosteroids were administered before 34 weeks. These pregnancies were excluded from the main cohort. | no (1008); yes (77); none (6) | 0 |
| acs_under_34w_dose | exclusion/exposure | categorical | Dose/course information for ACS administered before 34 weeks. | no (1008); 2 doses 24hrs  interval (61); single dose (14); none (6); 1.4 (2) | 0 |
| acs_34w_to_37w | exposure | categorical | Exposure indicator for ACS administration in the late preterm window, 34+0 to 36+6 weeks. | no (952); yes (139) | 0 |
| acs_34w_to_37w_dose | exposure | categorical | Dose completeness for late-preterm ACS exposure: single dose or double dose. | no (952); single dose (108); double dose (21); rescue (10) | 0 |
| as_to_delivery_time | exposure | categorical | Time from ACS administration to delivery. | 0 to 6 hrs (922); >7 days (55); 6 to 24 hrs (49); 2 to 7 days (35); 24 to 48 hrs (28); none (1); 6 (1) | 0 |
| fetal_gender | covariate | categorical | Fetal/neonatal sex. | male (577); female (514) | 0 |
| fetal_weight | neonatal characteristic | numeric | Birthweight in grams. | numeric; min=1345, max=4200 | 0 |
| fetal_height | neonatal characteristic | numeric | Neonatal length/height. | numeric; min=0.0, max=55.0 | 0 |
| fetal_head_circumf | neonatal characteristic | numeric | Neonatal head circumference. | numeric; min=0.0, max=365.0 | 0 |
| apgar_1_min | outcome | numeric | Apgar score at 1 minute. | numeric; min=0, max=10 | 0 |
| apgar_5_min | outcome | numeric | Apgar score at 5 minutes. | numeric; min=0, max=10 | 0 |
| nicu_days | outcome | numeric | Length of NICU stay in days; NICU admission derived as nicu_days > 0. | numeric; min=0, max=140 | 0 |
| neonatal_hypoglycemia | outcome | categorical | Neonatal hypoglycemia indicator. | no (1013); none (63); yes (15) | 0 |
| maternal_infection | covariate | categorical | Maternal infection indicator. | no (1010); none (44); yes (37) | 0 |
| neonatal_resusitation | outcome | categorical | Neonatal resuscitation/initial support indicator; retained but not separately reported due overlap with oxygen_support. | no (744); yes (298); none (49) | 0 |
| oxygen_support | primary outcome | categorical | Initial respiratory support modality: none, hood only, CPAP, PBV/positive-pressure ventilation, or intubation. | none (793); cpap (202); hood only (59); pbv (30); intubation (7) | 0 |
| neonatal_sepsis | outcome | categorical | Neonatal sepsis indicator/category. | no (1063); early (14); late (14) | 0 |
| indication_of_nicu_admission | outcome/descriptor | categorical | Indication for NICU admission. | none (830); resp. distress (227); others (22); Hyperbilirubinemia (6); sepsis (2); asfiksia (2); hypoglycemia (1);   (1) | 0 |
| respiratory_morbidity | outcome | categorical | Diagnosis-based respiratory morbidity field; used for pulmonary morbidity, not the primary support-at-birth outcome. | none (920); TTN (134); pneumonia (15); Pneumothorax (6); RDS (5); RDS + Pneumonia (4); Pneumothorax + Pulm HT (2); RDS + Pneumothorax (2)... | 0 |
| invasive_mechanic_ventilation_days | outcome | numeric | Days of invasive mechanical ventilation. | numeric; min=0, max=31 | 0 |
| nasal_mv_days | outcome | numeric | Days of nasal/non-invasive mechanical ventilation. | numeric; min=0, max=24 | 0 |
| o2_days_total | outcome | numeric | Total oxygen support days. | numeric; min=0, max=64 | 0 |
| preterm_complications | outcome | categorical | Composite preterm complications field. | NONE (1065); Ha PDA (19); IVK (4); NEC (1); Ha PDA + NEC (1); IVK + BPD (1) | 0 |
| neonatal_death | outcome | categorical | Neonatal death indicator. | no (1080); yes (10); none (1) | 0 |

## Key derived variables created by the R script

| Derived variable | Definition |
|---|---|
| `ga_birth_days` | `ga_weeks_at_birth * 7 + ga_days_at_birth` |
| `ga_birth_weeks` | `ga_birth_days / 7` |
| `treat` | `acs_34w_to_37w == "yes"` |
| `acs_under_34w_bin` | `acs_under_34w == "yes"` |
| `oxygen_any` | Primary outcome; `oxygen_support` not missing and not `none` |
| `support_modality` | Categorical initial respiratory support modality from `oxygen_support` |
| `high_intensity_initial_support` | CPAP, PBV/positive-pressure ventilation, or intubation |
| `hospital_course_respiratory_support` | Any of `o2_days_total`, `nasal_mv_days`, or `invasive_mechanic_ventilation_days` > 0 |
| `resp_any` | Diagnosis-based pulmonary morbidity: `respiratory_morbidity` not equal to `none` |
| `nicu_admit` | `nicu_days > 0` |
| `hypoglycemia` | `neonatal_hypoglycemia == "yes"` |
| `sepsis_any` | `neonatal_sepsis` not equal to `no` |
| `preterm_comp_any` | `preterm_complications` not equal to `none` |
| `death` | `neonatal_death == "yes"` |
