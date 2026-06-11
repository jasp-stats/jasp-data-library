# The JASP Data Library — website

Source for the site published at <https://jasp-stats.github.io/jasp-data-library/>.

## How it works

[`GenerateMDs.R`](GenerateMDs.R) reads:

- the dataset files in this repository (one folder per data set), and
- the category grouping **and** dataset descriptions from a **jasp-desktop**
  checkout (`Resources/Data Sets/Data Library/` and
  `Resources/Data Sets/index.json`),

and writes one Quarto chapter per category (`myChapters/chapter_*.qmd` — a grid
of download cards with the dataset's friendly name + description) plus
`_quarto.yml` (rendered from [`_quarto.template.yml`](_quarto.template.yml)).
`quarto render` then builds the site into `docs/`.

Edit the **source** — `GenerateMDs.R`, [`theme.scss`](theme.scss),
`_quarto.template.yml`, [`index.qmd`](index.qmd), `assets/`. The generated
files (`_quarto.yml`, `myChapters/`, `docs/`) are git-ignored and rebuilt by CI.

## Build / preview locally

From this folder, with a `jasp-desktop` checkout available:

```bash
export JASP_DESKTOP_DIR=/path/to/jasp-desktop   # DATALIB_DIR defaults to ".."
Rscript -e 'install.packages("jsonlite")'        # once
Rscript GenerateMDs.R
quarto preview
```

## Deployment

[`.github/workflows/deploy-site.yml`](../.github/workflows/deploy-site.yml)
builds the site on every push to `main` (and on demand via *Run workflow*) and
deploys it to GitHub Pages with `actions/deploy-pages`.

> **One-time setting:** the repository's **Settings → Pages → Source** must be
> set to **GitHub Actions** (not "Deploy from a branch"). Until then the deploy
> step will fail.
