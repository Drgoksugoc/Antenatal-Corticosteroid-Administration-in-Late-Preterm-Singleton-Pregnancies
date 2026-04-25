# Suggested upload commands

Use these commands after downloading/unzipping this package locally.

```bash
git clone https://github.com/Drgoksugoc/Antenatal-Corticosteroid-Administration-in-Late-Preterm-Singleton-Pregnancies.git
cd Antenatal-Corticosteroid-Administration-in-Late-Preterm-Singleton-Pregnancies

# Copy the contents of the prepared repository update folder into this git repo.
# Example, if the update folder is next to the cloned repo:
rsync -av ../acs_late_preterm_repository_update/ ./

git status
git add README.md CITATION.cff LICENSE DATA_USE.md .gitignore code/ data/ outputs/ figures/ docs/
git commit -m "Update reproducibility repository for major revision"
git push origin main
```

After pushing, check GitHub in a browser and confirm that:

1. The README renders correctly.
2. The script path shown in the README matches the file in `code/`.
3. The outputs folder includes the new dose/timing and respiratory modality files.
4. The primary outcome definition is shown as `oxygen_any`.
