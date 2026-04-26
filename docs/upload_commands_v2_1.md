# GitHub upload commands for v2.1

After unzipping this package locally:

```bash
git clone https://github.com/Drgoksugoc/Antenatal-Corticosteroid-Administration-in-Late-Preterm-Singleton-Pregnancies.git
cd Antenatal-Corticosteroid-Administration-in-Late-Preterm-Singleton-Pregnancies

# Copy the updated repository files into the cloned repo.
rsync -av ../repository_update/ ./

git status
git add README.md CHANGELOG.md code/ data/ outputs/ figures/
git commit -m "Final v2.1 update: delivery-mode sensitivity and rerun outputs"
git push origin main
```

Then create a GitHub release:

Tag:
`v2.1-delivery-mode-sensitivity`

Release title:
`v2.1 Delivery-mode sensitivity and final rerun outputs`

Release note:
`This release corresponds to the final resubmission analysis. It updates the primary IPTW results, adds a sensitivity analysis excluding measured delivery mode from the propensity score, and provides revised manuscript-facing outputs, figures, and diagnostic files.`
