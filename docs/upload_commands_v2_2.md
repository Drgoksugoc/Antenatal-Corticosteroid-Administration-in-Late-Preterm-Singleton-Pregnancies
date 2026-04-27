# Upload commands for v2.2-ga-sensitivity-update

This document provides the commands to apply the v2.2 changes to your GitHub repository and create a new release tag.

## Prerequisites

- Local clone of `Antenatal-Corticosteroid-Administration-in-Late-Preterm-Singleton-Pregnancies` (the GitHub repository).
- Working directory positioned at the repo root.

## Step 1: Pull latest from main branch

```bash
git checkout main
git pull origin main
```

## Step 2: Apply the v2.2 file changes

Copy the contents of the `repository_update_v2.2/` folder over the corresponding files in your local clone:

```bash
# From the location where you have repository_update_v2.2/ extracted:

# Update README, CHANGELOG, CITATION
cp repository_update_v2.2/README.md          /path/to/local/repo/README.md
cp repository_update_v2.2/CHANGELOG.md       /path/to/local/repo/CHANGELOG.md
cp repository_update_v2.2/CITATION.cff       /path/to/local/repo/CITATION.cff

# Update the analysis script
cp repository_update_v2.2/code/ACS_late_preterm_statistical_script.R \
   /path/to/local/repo/code/ACS_late_preterm_statistical_script.R

# Replace Figure 2 (relabeled)
cp repository_update_v2.2/figures/Figure_2.png /path/to/local/repo/figures/Figure_2.png
cp repository_update_v2.2/figures/Figure_2.tif /path/to/local/repo/figures/Figure_2.tif

# Add new GA sensitivity output (will be regenerated when script is rerun, but include it
# so the release is self-consistent without requiring a re-run)
cp repository_update_v2.2/outputs/ga_sensitivity_analyses.csv \
   /path/to/local/repo/outputs/ga_sensitivity_analyses.csv

# Add release notes
cp repository_update_v2.2/docs/release_notes_v2.2.md \
   /path/to/local/repo/docs/release_notes_v2.2.md
```

## Step 3 (optional but recommended): Re-run the analysis script

This regenerates all output CSVs to confirm reproducibility and produces an authoritative `ga_sensitivity_analyses.csv`:

```bash
cd /path/to/local/repo
Rscript code/ACS_late_preterm_statistical_script.R data/ACS_Late_Preterm_deidentified.csv outputs
```

Verify that the console output includes:

```
Sensitivity (PS including GA, continuous days), primary outcome IPTW OR: 1.279 (95% CI 0.817-2.001), P=0.282
Sensitivity (PS including GA, completed-week category), primary outcome IPTW OR: 1.306 (95% CI 0.837-2.038), P=0.241
```

## Step 4: Commit and push

```bash
cd /path/to/local/repo
git add README.md CHANGELOG.md CITATION.cff \
        code/ACS_late_preterm_statistical_script.R \
        figures/Figure_2.png figures/Figure_2.tif \
        outputs/ga_sensitivity_analyses.csv \
        docs/release_notes_v2.2.md

git commit -m "v2.2: add gestational-age sensitivity analyses, AMA reference cleanup, PPV terminology, relabeled Figure 2"
git push origin main
```

## Step 5: Create the v2.2 tag and GitHub release

### Option A: via Git CLI (then create release on GitHub web UI)

```bash
git tag -a v2.2-ga-sensitivity-update -m "v2.2: GA sensitivity analyses and AMA reference cleanup"
git push origin v2.2-ga-sensitivity-update
```

Then go to https://github.com/Drgoksugoc/Antenatal-Corticosteroid-Administration-in-Late-Preterm-Singleton-Pregnancies/releases and click "Draft a new release", select the `v2.2-ga-sensitivity-update` tag, and paste the contents of `docs/release_notes_v2.2.md` into the release description.

### Option B: via GitHub CLI (`gh`) - one-shot release

```bash
gh release create v2.2-ga-sensitivity-update \
  --title "v2.2: GA sensitivity analyses and AMA reference cleanup" \
  --notes-file docs/release_notes_v2.2.md
```

## Step 6: Verify the release on GitHub

After pushing the tag, the release should appear at:

https://github.com/Drgoksugoc/Antenatal-Corticosteroid-Administration-in-Late-Preterm-Singleton-Pregnancies/releases/tag/v2.2-ga-sensitivity-update

The previous release `v2.1-delivery-mode-sensitivity` remains available under the "Releases" tab; v2.2 becomes the latest.

## What does not need updating

- `data/`: the de-identified dataset is unchanged from v2.1. No need to re-upload.
- `LICENSE`: unchanged.
- `DATA_USE.md`: unchanged.
- `figures/Figure_1.*`, `figures/Figure_S1.*`, `figures/Figure_S2.*`: unchanged.

Only the files listed in Step 2 need to be staged.
