#!/usr/bin/env Rscript
# =====================================================================
#  GenerateMDs.R  —  build the source for The JASP Data Library website.
#
#  For every category in the JASP-desktop Data Library it writes one
#  Quarto chapter (myChapters/chapter_<n>.qmd) holding a responsive grid
#  of dataset "cards", then writes _quarto.yml from _quarto.template.yml
#  with the generated chapter list injected.
#
#  How datasets are resolved
#  -------------------------
#  jasp-desktop supplies the *grouping + ordering* (one folder per
#  category). The downloadable files live in the data repo (`main`); we
#  build an index of every .jasp actually present there, keyed by file
#  stem, and resolve each dataset's .jasp/.csv/.html from that index.
#  This makes the nested cases (Bain datasets stored under Sesame/, the
#  shared sesame.csv / Distributions.csv) just work — no special-casing.
#
#  Run this from the `website/` folder (the data repo is its parent).
#  Inputs (env vars; the deploy workflow sets these explicitly)
#    DATALIB_DIR       data-sets repo root (this repo)        ..
#    JASP_DESKTOP_DIR  jasp-desktop checkout                  ../../jasp-desktop
#  Requires the 'jsonlite' package (for index.json).
# =====================================================================

datalibDir     <- Sys.getenv("DATALIB_DIR",      "..")
jaspDesktopDir <- Sys.getenv("JASP_DESKTOP_DIR", "../../jasp-desktop")
libraryDir     <- file.path(jaspDesktopDir, "Resources", "Data Sets", "Data Library")
indexJson      <- file.path(jaspDesktopDir, "Resources", "Data Sets", "index.json")
chaptersDir    <- "myChapters"

GH_RAW       <- "https://github.com/jasp-stats/jasp-data-library/raw/main"
GH_RAWUC     <- "https://raw.githubusercontent.com/jasp-stats/jasp-data-library/main"
GH_HTMLVIEW  <- "https://htmlpreview.github.io/?https://github.com/jasp-stats/jasp-data-library/blob/main"

if (!dir.exists(datalibDir)) stop("DATALIB_DIR not found: ", datalibDir)
if (!dir.exists(libraryDir)) stop("Data Library not found: ", libraryDir)

## --- small helpers ---------------------------------------------------
encPath <- function(p) utils::URLencode(p)          # encodes spaces -> %20, keeps "/"
htmlEsc <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;",  x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}
firstFile <- function(dir, pat) {                    # first matching file in dir, or NA
  if (!dir.exists(dir)) return(NA_character_)
  hit <- list.files(dir, pattern = pat)
  if (length(hit)) hit[1] else NA_character_
}

## --- index every dataset in the data repo, keyed by file stem --------
buildIndex <- function() {
  jaspRel <- list.files(datalibDir, pattern = "\\.jasp$", recursive = TRUE)
  idx <- list()
  for (rel in jaspRel) {
    stem   <- sub("\\.jasp$", "", basename(rel))
    relDir <- dirname(rel)                            # "Album Sales" | "Sesame/bainAncova"
    absDir <- file.path(datalibDir, relDir)

    # CSV: <stem>.csv in dir -> any csv in dir -> any csv in parent (shared csv)
    csvRel <- file.path(relDir, paste0(stem, ".csv"))
    if (!file.exists(file.path(datalibDir, csvRel))) {
      hit <- firstFile(absDir, "\\.csv$")
      if (is.na(hit)) {
        parent <- dirname(relDir)
        hitP <- firstFile(file.path(datalibDir, parent), "\\.csv$")
        csvRel <- if (is.na(hitP)) NA_character_ else file.path(parent, hitP)
      } else csvRel <- file.path(relDir, hit)
    }

    # HTML results: underscored stem -> plain stem -> any html in dir
    htmlRel <- NA_character_
    for (cand in c(file.path(relDir, paste0(gsub(" ", "_", stem), ".html")),
                   file.path(relDir, paste0(stem, ".html")))) {
      if (file.exists(file.path(datalibDir, cand))) { htmlRel <- cand; break }
    }
    if (is.na(htmlRel)) {
      hit <- firstFile(absDir, "\\.html$")
      if (!is.na(hit)) htmlRel <- file.path(relDir, hit)
    }

    idx[[stem]] <- list(jasp = rel, csv = csvRel, html = htmlRel)
  }
  idx
}

## --- display names + descriptions from jasp-desktop's index.json -----
## index.json is the data-library catalogue: every leaf (kind "file") carries
## the friendly display name and an HTML blurb, exactly as shown in JASP's
## "Open > Data Library" browser. We key them by the dataset's .jasp stem.
buildDescriptions <- function() {
  map <- new.env(parent = emptyenv())
  if (!file.exists(indexJson)) {
    message("index.json not found (", indexJson, ") — cards will have no descriptions.")
    return(map)
  }
  if (!requireNamespace("jsonlite", quietly = TRUE))
    stop("package 'jsonlite' is required to read index.json")
  walk <- function(node) {
    if (!is.list(node)) return(invisible())
    ch <- node[["children"]]
    if (is.list(ch) && length(ch)) { lapply(ch, walk); return(invisible()) }
    if (identical(node[["kind"]], "file")) {
      p <- node[["path"]]; d <- node[["description"]]
      if (!is.null(p) && !is.null(d) && nzchar(trimws(d))) {
        stem <- sub("\\.jasp$", "", basename(p))
        if (nzchar(stem) && !exists(stem, envir = map, inherits = FALSE))
          assign(stem, list(title = node[["name"]], desc = trimws(d)), envir = map)
      }
    }
    invisible()
  }
  walk(jsonlite::fromJSON(indexJson, simplifyVector = FALSE))
  map
}
lookupMeta <- function(stem)
  if (exists(stem, envir = DESCMAP, inherits = FALSE)) get(stem, envir = DESCMAP) else NULL

## --- render one dataset card (raw HTML) ------------------------------
button <- function(cls, href, icon, label)
  sprintf('<a class="ds-btn %s" href="%s"%s><i class="bi %s"></i> %s</a>',
          cls, href, if (cls == "ds-html") ' target="_blank" rel="noopener"' else ' download',
          icon, label)

renderCard <- function(name, idx) {
  info <- idx[[name]]
  if (is.null(info)) { message("   · no files in data repo for: ", name); return(NULL) }
  meta  <- lookupMeta(name)                       # friendly title + HTML blurb
  title <- if (!is.null(meta)) meta$title else name
  desc  <- if (!is.null(meta)) meta$desc  else ""
  btns <- character(0)
  if (!is.na(info$jasp)) btns <- c(btns, button("ds-jasp", sprintf("%s/%s", GH_RAW,   encPath(info$jasp)), "bi-box-arrow-down", "JASP file"))
  if (!is.na(info$csv))  btns <- c(btns, button("ds-csv",  sprintf("%s/%s", GH_RAWUC, encPath(info$csv)),  "bi-filetype-csv",  "CSV data"))
  if (!is.na(info$html)) btns <- c(btns, button("ds-html", sprintf("%s/%s", GH_HTMLVIEW, encPath(info$html)), "bi-bar-chart-line", "View results"))
  descHtml <- if (nzchar(desc)) sprintf('\n    <p class="dataset-desc">%s</p>', desc) else ""
  sprintf('  <div class="dataset-card">\n    <h3 class="dataset-title">%s</h3>%s\n    <div class="dataset-links">\n      %s\n    </div>\n  </div>',
          htmlEsc(title), descHtml, paste(btns, collapse = "\n      "))
}

## --- render a grid of cards as a raw-HTML block ----------------------
renderGrid <- function(names, idx) {
  cards <- Filter(Negate(is.null), lapply(names, renderCard, idx = idx))
  if (!length(cards)) return(character(0))
  c('```{=html}', '<div class="dataset-grid">', unlist(cards), '</div>', '```', '')
}

## --- categories, ordered by their leading number (Books last) --------
listCategories <- function() {
  entries <- list.files(libraryDir)
  entries <- entries[dir.exists(file.path(libraryDir, entries))]
  ord <- suppressWarnings(as.numeric(sub("^([0-9]+).*", "\\1", entries)))
  entries[order(ord, na.last = TRUE)]
}

## Curated textbook -> datasets mapping for the "Books" category.
## (The jasp-desktop Books/ folder holds only licence files, so this
##  editorial mapping cannot be derived from disk and lives here.)
bookDatasets <- list(
  "Field — Discovering Statistics" = c(
    "Fear of Statistics", "Invisibility Cloak", "Alcohol Attitudes", "Beer Goggles",
    "Bush Tucker Food", "Looks or Personality", "Viagra", "Album Sales",
    "Exam Anxiety", "The Biggest Liar", "Dancing Cats", "Dancing Cats and Dogs"),
  "Moore, McCabe, & Craig — Introduction to the Practice of Statistics" = c(
    "Directed Reading Activities", "Moon and Aggression", "Weight Gain", "Facebook Friends",
    "Heart Rate", "Response to Eye Color", "College Success", "Fidgeting and Fat Gain",
    "Physical Activity and BMI", "Health Habits")
)

## --- main ------------------------------------------------------------
DESCMAP    <- buildDescriptions()
idx        <- buildIndex()
categories <- listCategories()
message("Indexed ", length(idx), " datasets; ", length(categories), " categories; ",
        length(ls(DESCMAP)), " descriptions.")

dir.create(chaptersDir, showWarnings = FALSE)
unlink(list.files(chaptersDir, pattern = "^chapter_\\d+\\.(md|qmd)$", full.names = TRUE))

chapterFiles <- character(0)
for (i in seq_along(categories)) {
  cat_i <- categories[i]
  title <- trimws(sub("^[0-9]+\\.", "", cat_i))         # strip leading "N."
  lines <- c(sprintf("# %s {.unnumbered}", title), "")

  if (title == "Books") {
    for (book in names(bookDatasets))
      lines <- c(lines, sprintf("## %s {.unnumbered}", book), "", renderGrid(bookDatasets[[book]], idx))
  } else {
    names_i <- sub("\\.jasp$", "", list.files(file.path(libraryDir, cat_i), pattern = "\\.jasp$"))
    lines   <- c(lines, renderGrid(names_i, idx))
  }

  f <- file.path(chaptersDir, sprintf("chapter_%d.qmd", i))
  writeLines(lines, f)
  chapterFiles <- c(chapterFiles, f)
  message(sprintf("  chapter_%d.qmd  %s", i, title))
}

## --- write _quarto.yml from the template -----------------------------
tmpl       <- readLines("_quarto.template.yml", warn = FALSE)
chapterYml <- paste(c("  - index.qmd", paste0("  - ", chapterFiles)), collapse = "\n")
tmpl       <- sub("^CHAPTERS_PLACEHOLDER[[:space:]]*$", chapterYml, tmpl)
writeLines(tmpl, "_quarto.yml")
message("Wrote _quarto.yml with ", length(chapterFiles), " chapters.")
