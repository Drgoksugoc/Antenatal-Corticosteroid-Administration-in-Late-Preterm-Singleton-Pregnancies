#!/usr/bin/env Rscript

# =============================================================================
# ACS Late Preterm – Advanced, End-to-End Analysis Pipeline (CSV/SAV)
# -----------------------------------------------------------------------------
# What this script does
#   1) Reads the revised dataset (CSV or SPSS .sav)
#   2) Cleans / standardizes categorical fields (fixes common coding quirks)
#   3) Builds an analysis cohort for LATE PRETERM births (34+0 to 36+6 weeks)
#   4) Defines exposure: ACS given 34w–37w (acs_34w_to_37w)
#   5) Fits a propensity score (PS) model and constructs stabilized IPTW weights
#   6) Produces diagnostics: PS overlap, extreme weights, effective sample size,
#      covariate balance (SMD before/after), and plots
#   7) Runs outcomes analysis for multiple neonatal endpoints using:
#        - Crude (unweighted)
#        - Adjusted multivariable (unweighted)
#        - IPTW (weighted)
#        - Doubly robust (IPTW + covariate adjustment)
#      and exports tidy CSV results
#   8) Runs stratified summaries by GA week at birth (34/35/36)
#   9) Optional sensitivity: include early ACS (<34w) as a covariate
#
# How to run (from project root)
#   Rscript scripts/ACS_late_preterm_advanced_pipeline.R "ACS_Late_Preterm.csv" "analysis_outputs"
#
# Outputs (created inside out_dir)
#   - data_cleaned_main.csv
#   - ps_model_variables_used.csv
#   - ps_boundary_and_weight_diagnostics_main.csv
#   - ps_boundary_and_weight_diagnostics_strata.csv
#   - balance_smd_before_after.csv
#   - outcome_results_main.csv
#   - outcome_results_by_gaweek.csv
#   - dose_timing_summary_treated.csv
#   - plots/*.png
#   - session_info.txt
#
# Notes
#   - This script assumes the dataset includes the columns shown in the revised
#     file you uploaded (e.g., acs_34w_to_37w, age, bmi, gravida, parity, etc.).
#   - If your variable names differ, change the "REQUIRED_COLUMNS" block.
# =============================================================================

options(stringsAsFactors = FALSE)
set.seed(20260204)

# ------------------------------- Packages ------------------------------------
pkg_needed <- c(
  "dplyr", "tidyr", "readr", "stringr", "stringi", "janitor", "forcats", "tibble",
  "ggplot2", "broom", "survey", "cobalt", "sandwich", "lmtest", "haven"
)

pkg_install_if_missing <- function(pkgs) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    message("Installing missing packages: ", paste(missing, collapse = ", "))
    install.packages(missing, repos = "https://cloud.r-project.org")
  }
  invisible(TRUE)
}

pkg_install_if_missing(pkg_needed)

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(stringi)
  library(janitor)
  library(forcats)
  library(tibble)
  library(ggplot2)
  library(broom)
  library(survey)
  library(cobalt)
  library(sandwich)
  library(lmtest)
  library(haven)
})

# ------------------------------- I/O -----------------------------------------
args <- commandArgs(trailingOnly = TRUE)
input_path <- if (length(args) >= 1) args[1] else "ACS_Late_Preterm.csv"
out_dir    <- if (length(args) >= 2) args[2] else "analysis_outputs"

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(out_dir, "plots"), showWarnings = FALSE, recursive = TRUE)

# -------------------------- Helper functions ---------------------------------
clean_str <- function(x) {
  # Standardize common text issues (case, whitespace, Turkish characters)
  x <- as.character(x)
  x <- str_trim(x)
  x <- str_to_lower(x)
  # Convert to ASCII where possible (turns ı -> i, ü -> u, etc.)
  x <- stringi::stri_trans_general(x, "Latin-ASCII")
  x <- str_replace_all(x, "\\s+", " ")
  # Treat empty strings as NA
  x[x %in% c("", "na", "n/a")] <- NA_character_
  x
}

recode_yesno <- function(x) {
  x <- clean_str(x)
  x <- case_when(
    x %in% c("yes", "y", "1", "true", "t") ~ "yes",
    x %in% c("no", "n", "0", "false", "f", "none") ~ "no",
    TRUE ~ x
  )
  factor(x, levels = c("no", "yes"))
}

safe_factor <- function(x) {
  # Convert to factor but keep NA
  factor(x)
}

read_input <- function(path) {
  ext <- tolower(tools::file_ext(path))
  if (ext == "csv") {
    readr::read_csv(path, show_col_types = FALSE, progress = FALSE)
  } else if (ext %in% c("sav", "zsav")) {
    haven::read_sav(path) |> as_tibble()
  } else {
    stop("Unsupported input file type: ", ext, " (use .csv or .sav)")
  }
}

# Robust OR/CI helper (works for glm or svyglm)
extract_or <- function(model, term = "treat") {
    if (is.null(model)) {
        return(tibble(term = term, estimate = NA_real_, std.error = NA_real_, statistic = NA_real_,
                      p.value = NA_real_, or = NA_real_, or_lcl = NA_real_, or_ucl = NA_real_))
    }
  s <- summary(model)
  if (!term %in% rownames(s$coefficients)) {
    return(tibble(
      term = term, estimate = NA_real_, std.error = NA_real_, statistic = NA_real_,
      p.value = NA_real_, or = NA_real_, or_lcl = NA_real_, or_ucl = NA_real_
    ))
  }
  b  <- s$coefficients[term, "Estimate"]
  se <- s$coefficients[term, "Std. Error"]
  z  <- s$coefficients[term, "t value"]
  p  <- s$coefficients[term, "Pr(>|t|)"]
  tibble(
    term = term,
    estimate = b,
    std.error = se,
    statistic = z,
    p.value = p,
    or = exp(b),
    or_lcl = exp(b - 1.96 * se),
    or_ucl = exp(b + 1.96 * se)
  )
}

# Robust SE for standard glm (HC0)
coeftest_robust <- function(model) {
    # Robust SE for standard glm:
    # Prefer HC3, but if HC3 is numerically unstable (warning) or fails, fall back to HC2, then HC0.
    vc <- tryCatch(
        sandwich::vcovHC(model, type = "HC3"),
        warning = function(w) {
            tryCatch(
                sandwich::vcovHC(model, type = "HC2"),
                warning = function(w2) sandwich::vcovHC(model, type = "HC0"),
                error   = function(e2) sandwich::vcovHC(model, type = "HC0")
            )
        },
        error = function(e) {
            tryCatch(
                sandwich::vcovHC(model, type = "HC2"),
                warning = function(w2) sandwich::vcovHC(model, type = "HC0"),
                error   = function(e2) sandwich::vcovHC(model, type = "HC0")
            )
        }
    )

    ct <- lmtest::coeftest(model, vcov. = vc)
    tibble(
        term = rownames(ct),
        estimate = ct[, 1],
        std.error = ct[, 2],
        statistic = ct[, 3],
        p.value = ct[, 4]
    )
}


# Safe svyglm wrapper: returns NULL if model fails (e.g., separation)
safe_svyglm <- function(formula, design, family) {
    tryCatch(
        suppressWarnings(survey::svyglm(formula, design = design, family = family, control = stats::glm.control(maxit = 200))),
        error = function(e) NULL
    )
}

# Compute weighted group means & RD/RR for binary outcomes using survey
binary_group_effects <- function(design, outcome, treat_var = "treat") {
  f <- as.formula(paste0("~", outcome))
  byf <- as.formula(paste0("~", treat_var))
  m <- survey::svyby(f, byf, design, survey::svymean, vartype = c("se"), na.rm = TRUE)
  # Expected rows: treat=0 and treat=1
  if (!all(c(0, 1) %in% m[[treat_var]])) {
    return(tibble(
      risk_control = NA_real_, risk_treat = NA_real_,
      rd = NA_real_, rd_se = NA_real_, rd_lcl = NA_real_, rd_ucl = NA_real_,
      rr = NA_real_, rr_lcl = NA_real_, rr_ucl = NA_real_
    ))
  }
  r0 <- m[m[[treat_var]] == 0, outcome][[1]]
  r1 <- m[m[[treat_var]] == 1, outcome][[1]]
  se0 <- m[m[[treat_var]] == 0, paste0(outcome, "se")][[1]]
  se1 <- m[m[[treat_var]] == 1, paste0(outcome, "se")][[1]]

  # Risk difference SE (approx, assumes independence)
  rd <- r1 - r0
  rd_se <- sqrt(se0^2 + se1^2)
  rd_lcl <- rd - 1.96 * rd_se
  rd_ucl <- rd + 1.96 * rd_se

  # Risk ratio using log method (approx)
  rr <- ifelse(r0 > 0, r1 / r0, NA_real_)
  # delta method for log(rr); only defined if both risks are >0
  if (!is.na(rr) && r0 > 0 && r1 > 0) {
    logrr_se <- sqrt((se1^2 / (r1^2)) + (se0^2 / (r0^2)))
    rr_lcl <- exp(log(rr) - 1.96 * logrr_se)
    rr_ucl <- exp(log(rr) + 1.96 * logrr_se)
  } else {
    rr_lcl <- NA_real_
    rr_ucl <- NA_real_
  }

  tibble(
    risk_control = r0,
    risk_treat = r1,
    rd = rd,
    rd_se = rd_se,
    rd_lcl = rd_lcl,
    rd_ucl = rd_ucl,
    rr = rr,
    rr_lcl = rr_lcl,
    rr_ucl = rr_ucl
  )
}

# ----------------------------- Read & clean ----------------------------------
raw <- read_input(input_path) |> janitor::clean_names()

# Required columns check (fail early with a clear message)
REQUIRED_COLUMNS <- c(
  "id_deidentified", "age", "bmi", "gravida", "parity",
  "ga_weeks_at_birth", "ga_days_at_birth",
  "acs_34w_to_37w", "acs_under_34w",
  "conception_type", "maternal_disease", "medication_use",
  "type_of_delivery", "indication_for_delivery", "fetal_gender",
  "apgar_1_min", "apgar_5_min",
  "nicu_days", "respiratory_morbidity", "neonatal_hypoglycemia",
  "maternal_infection", "neonatal_sepsis", "neonatal_resusitation",
  "oxygen_support", "invasive_mechanic_ventilation_days",
  "nasal_mv_days", "o2_days_total", "preterm_complications",
  "neonatal_death",
  "acs_34w_to_37w_dose", "as_to_delivery_time"
)

missing_cols <- setdiff(REQUIRED_COLUMNS, names(raw))
if (length(missing_cols) > 0) {
  stop("Missing required columns in the input dataset:\n  - ",
       paste(missing_cols, collapse = "\n  - "),
       "\n\nCheck your column names or update REQUIRED_COLUMNS in the script.")
}

# Clean all character columns
dat <- raw |> mutate(across(where(is.character), clean_str))

# -------------------------- Derive key variables ------------------------------
dat <- dat |>
  mutate(
    ga_birth_days = ga_weeks_at_birth * 7 + ga_days_at_birth,
    ga_birth_weeks = ga_birth_days / 7,

    # Exposure definitions
    treat = ifelse(acs_34w_to_37w %in% c("yes", "y", "1", "true"), 1L, 0L),
    acs_under_34w_bin = ifelse(acs_under_34w %in% c("yes", "y", "1", "true"), 1L, 0L),

    # Key binary outcomes
    nicu_admit = as.integer(nicu_days > 0),
    resp_any = as.integer(!is.na(respiratory_morbidity) & respiratory_morbidity != "none"),
    hypoglycemia = as.integer(recode_yesno(neonatal_hypoglycemia) == "yes"),
    maternal_infection_bin = as.integer(recode_yesno(maternal_infection) == "yes"),
    sepsis_any = as.integer(!is.na(neonatal_sepsis) & neonatal_sepsis != "no"),
    oxygen_any = as.integer(!is.na(oxygen_support) & oxygen_support != "none"),
    inv_mv_any = as.integer(invasive_mechanic_ventilation_days > 0),
    nasal_mv_any = as.integer(nasal_mv_days > 0),
    o2_any = as.integer(o2_days_total > 0),
    preterm_comp_any = as.integer(!is.na(preterm_complications) & preterm_complications != "none"),
    death = as.integer(recode_yesno(neonatal_death) == "yes")
  )

# ----------------------- Collapsed / analysis-ready covariates ----------------
dat <- dat |>
  mutate(
    # Conception: assisted vs spontaneous
    conception_assisted = case_when(
      conception_type %in% c("ivf", "iui") ~ "assisted",
      conception_type %in% c("spontaneus", "spontaneous") ~ "spontaneous",
      TRUE ~ "other"
    ) |> factor(levels = c("spontaneous", "assisted", "other")),

    maternal_disease_grp = case_when(
      maternal_disease %in% c("no", "none") ~ "none",
      str_detect(maternal_disease, "dm") ~ "diabetes",
      str_detect(maternal_disease, "preeclamp|ht\\b|hypertens") ~ "hypertensive",
      str_detect(maternal_disease, "thyroid|hypo|hyper") ~ "thyroid",
      str_detect(maternal_disease, "asthma") ~ "asthma",
      str_detect(maternal_disease, "cholest") ~ "cholestasis",
      TRUE ~ "other"
    ) |> factor(levels = c("none", "diabetes", "hypertensive", "thyroid", "asthma", "cholestasis", "other")),

    medication_use_grp = case_when(
      medication_use %in% c("no", "none") ~ "none",
      str_detect(medication_use, "thyroid") ~ "thyroid_med",
      str_detect(medication_use, "antico") ~ "anticoagulant",
      str_detect(medication_use, "antihipert|antihyper|antihypert") ~ "antihypertensive",
      str_detect(medication_use, "insulin|oad") ~ "insulin_or_oad",
      str_detect(medication_use, "antiepilep") ~ "antiepileptic",
      str_detect(medication_use, "cholest") ~ "cholestasis",
      TRUE ~ "other"
    ) |> factor(levels = c("none", "thyroid_med", "anticoagulant", "antihypertensive",
                          "insulin_or_oad", "antiepileptic", "cholestasis", "other")),

    indication_delivery_grp = case_when(
      str_detect(indication_for_delivery, "preterm") ~ "preterm_labor",
      str_detect(indication_for_delivery, "prom") ~ "prom",
      str_detect(indication_for_delivery, "fetal distress") ~ "fetal_distress",
      str_detect(indication_for_delivery, "preeclamp") ~ "preeclampsia",
      str_detect(indication_for_delivery, "placent") ~ "placental_anomaly",
      str_detect(indication_for_delivery, "oligo") ~ "oligohydramnios",
      str_detect(indication_for_delivery, "covid") ~ "covid",
      indication_for_delivery %in% c("none", NA_character_) ~ "other_unknown",
      TRUE ~ "other_unknown"
    ) |> factor(levels = c("preterm_labor", "prom", "fetal_distress", "preeclampsia",
                          "placental_anomaly", "oligohydramnios", "covid", "other_unknown")),

    type_of_delivery = factor(type_of_delivery),
    fetal_gender = factor(fetal_gender)
  )

# ------------------------------ Cohort building ------------------------------
# Late preterm = 34+0 to 36+6 weeks inclusive
late_preterm <- dat |>
  filter(ga_birth_days >= (34 * 7) & ga_birth_days <= (36 * 7 + 6))

# Main cohort: exclude anyone with early ACS (<34w) to reduce exposure mixing
cohort_main <- late_preterm |> filter(acs_under_34w_bin == 0)

# Sensitivity cohort: include early ACS, but adjust for it
cohort_sens_all <- late_preterm

# ------------------------------ Save cleaned data -----------------------------
readr::write_csv(cohort_main, file.path(out_dir, "data_cleaned_main.csv"))

# ------------------------------ PS + weights ---------------------------------
# PS model covariates (pre-treatment as much as possible)
ps_covars <- c(
  "age", "bmi", "gravida", "parity",
  "conception_assisted",
  "maternal_disease_grp",
  "medication_use_grp",
  "maternal_infection_bin",
  "indication_delivery_grp",
  "type_of_delivery",
  "fetal_gender"
)

# Verify covariates exist in the main cohort
stopifnot(all(ps_covars %in% names(cohort_main)))

ps_formula <- as.formula(
  paste("treat ~", paste(ps_covars, collapse = " + "))
)

# Fit PS model
ps_fit <- glm(ps_formula, data = cohort_main, family = binomial(), control = glm.control(maxit = 100))

cohort_main <- cohort_main |>
  mutate(
    ps = predict(ps_fit, type = "response")
  )

# Stabilized ATE weights
p_treat <- mean(cohort_main$treat == 1)
cohort_main <- cohort_main |>
  mutate(
    w_raw = ifelse(treat == 1, p_treat / ps, (1 - p_treat) / (1 - ps))
  )

# Trim extreme weights (default: 1st to 99th percentile)
trim_lower <- 0.01
trim_upper <- 0.99
w_lo <- quantile(cohort_main$w_raw, probs = trim_lower, na.rm = TRUE)
w_hi <- quantile(cohort_main$w_raw, probs = trim_upper, na.rm = TRUE)

cohort_main <- cohort_main |>
  mutate(
    w = pmin(pmax(w_raw, w_lo), w_hi),
    w_trimmed = as.integer(w_raw < w_lo | w_raw > w_hi)
  )

# PS variables used (nice for auditing reproducibility)
ps_vars_used <- tibble(
  ps_formula = paste(deparse(ps_formula), collapse = " "),
  covariate = ps_covars
)
readr::write_csv(ps_vars_used, file.path(out_dir, "ps_model_variables_used.csv"))

# ------------------------------ Diagnostics ----------------------------------
ps_diag_main <- cohort_main |>
  summarise(
    n = n(),
    n_treat = sum(treat == 1),
    n_control = sum(treat == 0),

    ps_min = min(ps),
    ps_p01 = quantile(ps, 0.01),
    ps_p05 = quantile(ps, 0.05),
    ps_median = median(ps),
    ps_p95 = quantile(ps, 0.95),
    ps_p99 = quantile(ps, 0.99),
    ps_max = max(ps),

    w_min = min(w),
    w_p01 = quantile(w, 0.01),
    w_p05 = quantile(w, 0.05),
    w_median = median(w),
    w_p95 = quantile(w, 0.95),
    w_p99 = quantile(w, 0.99),
    w_max = max(w),

    trimmed_n = sum(w_trimmed == 1),
    trimmed_pct = mean(w_trimmed == 1),

    ess_total = (sum(w)^2) / sum(w^2),
    ess_treat = (sum(w[treat == 1])^2) / sum(w[treat == 1]^2),
    ess_control = (sum(w[treat == 0])^2) / sum(w[treat == 0]^2)
  )

readr::write_csv(ps_diag_main, file.path(out_dir, "ps_boundary_and_weight_diagnostics_main.csv"))

# Stratified diagnostics by GA week (34/35/36)
ps_diag_strata <- cohort_main |>
  mutate(ga_week = factor(floor(ga_birth_weeks))) |>
  group_by(ga_week) |>
  summarise(
    n = n(),
    n_treat = sum(treat == 1),
    n_control = sum(treat == 0),

    ps_min = min(ps),
    ps_median = median(ps),
    ps_max = max(ps),

    w_min = min(w),
    w_median = median(w),
    w_max = max(w),

    trimmed_pct = mean(w_trimmed == 1),

    ess_total = (sum(w)^2) / sum(w^2),
    .groups = "drop"
  )

readr::write_csv(ps_diag_strata, file.path(out_dir, "ps_boundary_and_weight_diagnostics_strata.csv"))

# ------------------------------ Balance (SMD) --------------------------------
bal <- cobalt::bal.tab(
    ps_formula,
    data = cohort_main,
    weights = cohort_main$w,
    method = "weighting",
    estimand = "ATE",
    s.d.denom = "pooled",
    un = TRUE,
    quick = FALSE
)

bal_df <- bal$Balance |>
  tibble::rownames_to_column("variable") |>
  as_tibble() |>
  transmute(
    variable,
    smd_unweighted = Diff.Un,
    smd_weighted = Diff.Adj
  )

readr::write_csv(bal_df, file.path(out_dir, "balance_smd_before_after.csv"))

# ------------------------------ Plots ----------------------------------------
# PS distribution by treatment
p_ps <- ggplot(cohort_main, aes(x = ps, fill = factor(treat))) +
  geom_density(alpha = 0.4) +
  labs(
    title = "Propensity Score Distribution (Main Cohort)",
    x = "Propensity score", fill = "ACS 34–37w (treat)"
  ) +
  theme_minimal()

ggsave(file.path(out_dir, "plots", "ps_density.png"), p_ps, width = 8, height = 5, dpi = 300)

# Weight histogram
p_w <- ggplot(cohort_main, aes(x = w, fill = factor(treat))) +
  geom_histogram(bins = 40, alpha = 0.5, position = "identity") +
  labs(
    title = "Stabilized IPTW (Trimmed) Distribution (Main Cohort)",
    x = "Weight", fill = "ACS 34–37w (treat)"
  ) +
  theme_minimal()

ggsave(file.path(out_dir, "plots", "weights_hist.png"), p_w, width = 8, height = 5, dpi = 300)

# Love plot (SMD)
png(file.path(out_dir, "plots", "love_plot.png"), width = 1400, height = 900, res = 150)
print(
  cobalt::love.plot(
    bal,
    threshold = 0.1,
    abs = TRUE,
    var.order = "unadjusted",
    stars = "raw"
  ) +
    ggtitle("Covariate Balance (SMD) Before vs After IPTW")
)
dev.off()

# ------------------------------ Outcome analysis -----------------------------
# Create survey designs
design_unw <- survey::svydesign(ids = ~1, weights = ~1, data = cohort_main)
design_w   <- survey::svydesign(ids = ~1, weights = ~w, data = cohort_main)

# Outcomes to analyze
binary_outcomes <- c(
  "nicu_admit", "resp_any", "hypoglycemia", "sepsis_any",
  "oxygen_any", "inv_mv_any", "nasal_mv_any",
  "o2_any", "preterm_comp_any", "death"
)

cont_outcomes <- c(
  "nicu_days", "invasive_mechanic_ventilation_days", "nasal_mv_days", "o2_days_total",
  "apgar_1_min", "apgar_5_min"
)

# Model runner for one binary outcome
run_binary_models <- function(outcome, data, design_unw, design_w, covars) {
  f_crude <- as.formula(paste0(outcome, " ~ treat"))
  f_adj   <- as.formula(paste0(outcome, " ~ treat + ", paste(covars, collapse = " + ")))

  # Crude + robust SE (HC0)
  m_crude <- glm(f_crude, data = data, family = binomial(), control = glm.control(maxit = 100))
  ct_crude <- coeftest_robust(m_crude)
  crude_treat <- ct_crude |> filter(term == "treat") |>
    mutate(or = exp(estimate),
           or_lcl = exp(estimate - 1.96 * std.error),
           or_ucl = exp(estimate + 1.96 * std.error)) |>
    transmute(model = "crude", outcome = outcome, effect = "OR",
              estimate = or, lcl = or_lcl, ucl = or_ucl, p.value = p.value)

  # Adjusted + robust SE (HC0)
  m_adj <- glm(f_adj, data = data, family = binomial(), control = glm.control(maxit = 100))
  ct_adj <- coeftest_robust(m_adj)
  adj_treat <- ct_adj |> filter(term == "treat") |>
    mutate(or = exp(estimate),
           or_lcl = exp(estimate - 1.96 * std.error),
           or_ucl = exp(estimate + 1.96 * std.error)) |>
    transmute(model = "adjusted", outcome = outcome, effect = "OR",
              estimate = or, lcl = or_lcl, ucl = or_ucl, p.value = p.value)

  # IPTW (weighted) – treat only
  m_iptw <- safe_svyglm(f_crude, design_w, quasibinomial())
  iptw_treat <- extract_or(m_iptw, term = "treat") |>
    transmute(model = "iptw", outcome = outcome, effect = "OR",
              estimate = or, lcl = or_lcl, ucl = or_ucl, p.value = p.value)

  # Doubly robust (weighted + covariates)
  m_dr <- safe_svyglm(f_adj, design_w, quasibinomial())
  dr_treat <- extract_or(m_dr, term = "treat") |>
    transmute(model = "doubly_robust", outcome = outcome, effect = "OR",
              estimate = or, lcl = or_lcl, ucl = or_ucl, p.value = p.value)

  # Absolute risks and RD/RR (unweighted and weighted)
  eff_unw <- binary_group_effects(design_unw, outcome) |>
    mutate(model = "crude", outcome = outcome)

  eff_w <- binary_group_effects(design_w, outcome) |>
    mutate(model = "iptw", outcome = outcome)

  rdrr <- bind_rows(eff_unw, eff_w) |>
    transmute(
      model, outcome,
      risk_control, risk_treat,
      rd, rd_lcl, rd_ucl,
      rr, rr_lcl, rr_ucl
    )

  list(or_table = bind_rows(crude_treat, adj_treat, iptw_treat, dr_treat),
       rdrr_table = rdrr)
}

# Model runner for one continuous outcome (mean difference)
run_cont_models <- function(outcome, data, design_unw, design_w, covars) {
  f_crude <- as.formula(paste0(outcome, " ~ treat"))
  f_adj   <- as.formula(paste0(outcome, " ~ treat + ", paste(covars, collapse = " + ")))

  # Crude
  m_crude <- glm(f_crude, data = data)
  ct_crude <- coeftest_robust(m_crude)
  crude_treat <- ct_crude |> filter(term == "treat") |>
    transmute(model = "crude", outcome = outcome, effect = "MD",
              estimate = estimate, lcl = estimate - 1.96 * std.error, ucl = estimate + 1.96 * std.error,
              p.value = p.value)

  # Adjusted
  m_adj <- glm(f_adj, data = data)
  ct_adj <- coeftest_robust(m_adj)
  adj_treat <- ct_adj |> filter(term == "treat") |>
    transmute(model = "adjusted", outcome = outcome, effect = "MD",
              estimate = estimate, lcl = estimate - 1.96 * std.error, ucl = estimate + 1.96 * std.error,
              p.value = p.value)

  # IPTW
  m_iptw <- survey::svyglm(f_crude, design = design_w)
  s_iptw <- summary(m_iptw)$coefficients
  b <- s_iptw["treat", "Estimate"]
  se <- s_iptw["treat", "Std. Error"]
  p <- s_iptw["treat", "Pr(>|t|)"]
  iptw_treat <- tibble(model = "iptw", outcome = outcome, effect = "MD",
                       estimate = b, lcl = b - 1.96 * se, ucl = b + 1.96 * se, p.value = p)

  # Doubly robust
  m_dr <- survey::svyglm(f_adj, design = design_w)
  s_dr <- summary(m_dr)$coefficients
  b2 <- s_dr["treat", "Estimate"]
  se2 <- s_dr["treat", "Std. Error"]
  p2 <- s_dr["treat", "Pr(>|t|)"]
  dr_treat <- tibble(model = "doubly_robust", outcome = outcome, effect = "MD",
                     estimate = b2, lcl = b2 - 1.96 * se2, ucl = b2 + 1.96 * se2, p.value = p2)

  bind_rows(crude_treat, adj_treat, iptw_treat, dr_treat)
}

# Run all outcomes
or_results <- list()
rdrr_results <- list()

for (o in binary_outcomes) {
  tmp <- run_binary_models(o, cohort_main, design_unw, design_w, ps_covars)
  or_results[[o]] <- tmp$or_table
  rdrr_results[[o]] <- tmp$rdrr_table
}

or_results_df <- bind_rows(or_results)
rdrr_results_df <- bind_rows(rdrr_results)

cont_results_df <- bind_rows(lapply(cont_outcomes, run_cont_models,
                                    data = cohort_main, design_unw = design_unw, design_w = design_w,
                                    covars = ps_covars))

# Influence diagnostics (optional): identify high-leverage observations for nicu_days model
# This helps explain HC* warnings and supports sensitivity analysis.
try({
    m_inf <- glm(nicu_days ~ treat + age + bmi + gravida + parity + conception_assisted +
                   maternal_disease_grp + medication_use_grp + maternal_infection_bin +
                   indication_delivery_grp + type_of_delivery + fetal_gender,
                 data = cohort_main)
    inf_df <- tibble(
        row_in_model = seq_len(nrow(model.frame(m_inf))),
        id_deidentified = cohort_main$id_deidentified[as.integer(rownames(model.frame(m_inf)))],
        hat = hatvalues(m_inf),
        cooks = cooks.distance(m_inf),
        resid = residuals(m_inf, type = "pearson")
    ) |> arrange(desc(hat)) |> slice(1:20)
    readr::write_csv(inf_df, file.path(out_dir, "influence_diagnostics_nicu_days_top20.csv"))
}, silent = TRUE)

# Combine OR + RD/RR + MD in one output (kept separate columns for clarity)
outcome_results_main <- or_results_df |>
  left_join(
    rdrr_results_df |> filter(model %in% c("crude", "iptw")),
    by = c("model", "outcome")
  ) |>
  arrange(outcome, factor(model, levels = c("crude", "adjusted", "iptw", "doubly_robust")))

readr::write_csv(outcome_results_main, file.path(out_dir, "outcome_results_main.csv"))
readr::write_csv(cont_results_df, file.path(out_dir, "outcome_results_continuous_main.csv"))

# ------------------------------ Stratified outcomes ---------------------------
# Stratify by GA week at birth (34/35/36)
cohort_main <- cohort_main |> mutate(ga_week = factor(floor(ga_birth_weeks)))

run_stratified <- function(stratum_level) {
  d <- cohort_main |> filter(ga_week == stratum_level)
  if (nrow(d) < 50 || sum(d$treat == 1) < 10 || sum(d$treat == 0) < 10) {
    return(NULL)
  }
  des_unw <- svydesign(ids = ~1, weights = ~1, data = d)
  des_w   <- svydesign(ids = ~1, weights = ~w, data = d)

  # Binary outcomes: only IPTW and DR (more meaningful within strata)
  out <- lapply(binary_outcomes, function(o) {
    f_crude <- as.formula(paste0(o, " ~ treat"))
    f_adj   <- as.formula(paste0(o, " ~ treat + ", paste(ps_covars, collapse = " + ")))

    m_iptw <- safe_svyglm(f_crude, des_w, quasibinomial())
    m_dr   <- safe_svyglm(f_adj, des_w, quasibinomial())

    iptw <- extract_or(m_iptw, "treat") |>
      transmute(ga_week = stratum_level, model = "iptw", outcome = o,
                effect = "OR", estimate = or, lcl = or_lcl, ucl = or_ucl, p.value = p.value)

    dr <- extract_or(m_dr, "treat") |>
      transmute(ga_week = stratum_level, model = "doubly_robust", outcome = o,
                effect = "OR", estimate = or, lcl = or_lcl, ucl = or_ucl, p.value = p.value)

    bind_rows(iptw, dr)
  }) |> bind_rows()

  out
}

strata_levels <- sort(unique(cohort_main$ga_week))
out_by_ga <- bind_rows(lapply(strata_levels, run_stratified))

readr::write_csv(out_by_ga, file.path(out_dir, "outcome_results_by_gaweek.csv"))

# ------------------------------ Treated dose/timing summary -------------------
treated_summary <- cohort_main |>
  filter(treat == 1) |>
  mutate(
    acs_dose = forcats::fct_na_value_to_level(factor(acs_34w_to_37w_dose), level = "missing"),
    timing = forcats::fct_na_value_to_level(factor(as_to_delivery_time), level = "missing")
  ) |>
  count(acs_dose, timing, name = "n") |>
  group_by(acs_dose) |>
  mutate(pct_within_dose = n / sum(n)) |>
  ungroup() |>
  arrange(desc(n))

readr::write_csv(treated_summary, file.path(out_dir, "dose_timing_summary_treated.csv"))

# ------------------------------ Sensitivity (optional) ------------------------
# Include early ACS (<34w) as a covariate and re-run PS + key outcomes.
# This is useful if you prefer not to exclude early-ACS patients.
run_sensitivity_include_early <- TRUE

if (run_sensitivity_include_early) {

  sens_covars <- unique(c(ps_covars, "acs_under_34w_bin"))
  ps_formula_sens <- as.formula(
    paste("treat ~", paste(sens_covars, collapse = " + "))
  )

  ps_fit_sens <- glm(ps_formula_sens, data = cohort_sens_all, family = binomial(), control = glm.control(maxit = 100))
  cohort_sens_all <- cohort_sens_all |>
    mutate(
      ps = predict(ps_fit_sens, type = "response")
    )

  p_treat_s <- mean(cohort_sens_all$treat == 1)
  cohort_sens_all <- cohort_sens_all |>
    mutate(
      w_raw = ifelse(treat == 1, p_treat_s / ps, (1 - p_treat_s) / (1 - ps))
    )

  w_lo_s <- quantile(cohort_sens_all$w_raw, probs = trim_lower, na.rm = TRUE)
  w_hi_s <- quantile(cohort_sens_all$w_raw, probs = trim_upper, na.rm = TRUE)

  cohort_sens_all <- cohort_sens_all |>
    mutate(
      w = pmin(pmax(w_raw, w_lo_s), w_hi_s),
      w_trimmed = as.integer(w_raw < w_lo_s | w_raw > w_hi_s)
    )

  design_unw_s <- svydesign(ids = ~1, weights = ~1, data = cohort_sens_all)
  design_w_s   <- svydesign(ids = ~1, weights = ~w, data = cohort_sens_all)

  # Run a compact sensitivity set on the most common outcomes
  sens_bin_outcomes <- c("nicu_admit", "resp_any", "hypoglycemia", "sepsis_any", "oxygen_any", "death")

  sens_or <- bind_rows(lapply(sens_bin_outcomes, function(o) {
    f_crude <- as.formula(paste0(o, " ~ treat"))
    f_adj   <- as.formula(paste0(o, " ~ treat + ", paste(sens_covars, collapse = " + ")))

    m_iptw <- safe_svyglm(f_crude, design_w_s, quasibinomial())
    m_dr   <- safe_svyglm(f_adj, design_w_s, quasibinomial())

    iptw <- extract_or(m_iptw, "treat") |>
      transmute(cohort = "sensitivity_include_early", model = "iptw", outcome = o,
                estimate = or, lcl = or_lcl, ucl = or_ucl, p.value = p.value)

    dr <- extract_or(m_dr, "treat") |>
      transmute(cohort = "sensitivity_include_early", model = "doubly_robust", outcome = o,
                estimate = or, lcl = or_lcl, ucl = or_ucl, p.value = p.value)

    bind_rows(iptw, dr)
  }))

  readr::write_csv(sens_or, file.path(out_dir, "outcome_results_sensitivity_include_early.csv"))
}

# ------------------------------ Session info ---------------------------------
writeLines(capture.output(sessionInfo()), file.path(out_dir, "session_info.txt"))

# Save warnings (if any) to a text file for audit
wtxt <- capture.output(print(warnings()))
if (length(wtxt) > 0) writeLines(wtxt, file.path(out_dir, "warnings_log.txt"))

message("\nDONE ✅  Outputs written to: ", normalizePath(out_dir))