# Batch-render one HTML report per company into company_reports/<slug>/

src_dir <- "C:/Users/chankalong/OneDrive - Baptist Oi Kwan Social Service/KaLong/non_refresh/kt-eap/analysis"
work_dir <- "C:/kteap-render"
tmp_dir  <- "C:/kteap-tmp"
out_root <- file.path(src_dir, "company_reports")
rscript  <- "C:/Users/chankalong/AppData/Local/Programs/R/R-4.4.2/bin/Rscript.exe"

dir.create(work_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(out_root, showWarnings = FALSE, recursive = TRUE)

source(file.path(src_dir, "company_report_jobs.R"), encoding = "UTF-8")

only_slug <- Sys.getenv("KT_ONLY_SLUG", unset = "")
if (nzchar(only_slug)) {
  company_jobs <- Filter(function(j) identical(j$slug, only_slug), company_jobs)
  if (length(company_jobs) == 0) stop("No job matches KT_ONLY_SLUG=", only_slug)
}

file.copy(
  file.path(src_dir, "emotion_twister_survey_report.qmd"),
  file.path(work_dir, "emotion_twister_survey_report.qmd"),
  overwrite = TRUE
)
for (shared in c("_report_body.qmd", "_config_labels.R")) {
  src_f <- file.path(src_dir, shared)
  if (file.exists(src_f)) {
    file.copy(src_f, file.path(work_dir, shared), overwrite = TRUE)
  }
}

Sys.setenv(TMP = tmp_dir, TEMP = tmp_dir, TMPDIR = tmp_dir)

api_cache <- file.path(work_dir, "api_export.json")
cat("Fetching API export...\n")
library(httr2)
api_key <- Sys.getenv("SURVEY_API_KEY", unset = "")
if (!nzchar(api_key)) {
  stop("SURVEY_API_KEY is not set. Add it to .Renviron.", call. = FALSE)
}
resp <- request("https://emotion-twister-survey.vercel.app/api/admin/export-data") |>
  req_headers(`x-api-key` = api_key) |>
  req_perform()
writeLines(resp_body_string(resp), api_cache, useBytes = TRUE)
Sys.setenv(KT_API_CACHE = api_cache)

copy_report <- function(slug) {
  dest <- file.path(out_root, slug)
  if (dir.exists(dest)) unlink(dest, recursive = TRUE, force = TRUE)
  dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  html_src <- file.path(work_dir, "emotion_twister_survey_report.html")
  files_src <- file.path(work_dir, "emotion_twister_survey_report_files")
  xlsx_src <- file.path(work_dir, "emotion_twister_tables.xlsx")
  if (!file.exists(html_src)) stop("Missing HTML for ", slug)
  file.copy(html_src, file.path(dest, "emotion_twister_survey_report.html"), overwrite = TRUE)
  if (dir.exists(files_src)) {
    file.copy(files_src, dest, recursive = TRUE)
  }
  if (file.exists(xlsx_src)) {
    file.copy(xlsx_src, file.path(dest, "emotion_twister_tables.xlsx"), overwrite = TRUE)
  }
}

write_empty_report <- function(job) {
  dest <- file.path(out_root, job$slug)
  dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  html <- paste0(
    "<!DOCTYPE html><html lang='en'><head><meta charset='utf-8'>",
    "<title>", job$company_name, " — no submissions yet</title></head><body>",
    "<h1>", job$company_name, "</h1>",
    "<p>Confirmed window: ", job$confirmed, ".</p>",
    "<p>No survey submissions were in this window at the time of rendering.</p>",
    "</body></html>"
  )
  writeLines(enc2utf8(html), file.path(dest, "emotion_twister_survey_report.html"), useBytes = TRUE)
}

library(jsonlite)

api_json <- fromJSON(api_cache, flatten = TRUE)
api_dates <- as.Date(api_json$submissions$submittedAt)
api_locs  <- as.character(api_json$submissions$locationCode)

count_job <- function(job) {
  keep <- rep(FALSE, length(api_dates))
  for (w in job$windows) {
    ok <- api_dates >= w$start & api_dates <= w$end
    if (!is.null(w$locations) && length(w$locations) > 0) {
      ok <- ok & api_locs %in% as.character(w$locations)
    }
    keep <- keep | ok
  }
  sum(keep, na.rm = TRUE)
}

results <- list()
for (i in seq_along(company_jobs)) {
  job <- company_jobs[[i]]
  cat("\n========== ", i, "/", length(company_jobs), " ", job$slug, " ==========\n", sep = "")
  n_raw <- count_job(job)
  cat("Raw API rows in window: ", n_raw, "\n", sep = "")
  if (n_raw < 1) {
    write_empty_report(job)
    results[[job$slug]] <- list(ok = TRUE, skipped_empty = TRUE, n_raw = 0)
    cat("No data — wrote placeholder HTML\n")
    next
  }
  write_company_config(file.path(work_dir, "_company_config.R"), job)
  cfg <- file.path(work_dir, "_company_config.R")
  cat(paste(readLines(cfg, encoding = "UTF-8"), collapse = "\n"), "\n")

  setwd(work_dir)
  status <- system("quarto render emotion_twister_survey_report.qmd")
  if (status != 0) {
    cat("RENDER FAILED for ", job$slug, " (status ", status, ")\n", sep = "")
    results[[job$slug]] <- list(ok = FALSE, status = status)
    next
  }
  copy_report(job$slug)
  results[[job$slug]] <- list(ok = TRUE, status = 0)
  cat("Copied to ", file.path(out_root, job$slug), "\n", sep = "")
}

cat("\n===== BATCH DONE =====\n")
print(results)
invisible(file.remove(file.path(work_dir, "_company_config.R")))
