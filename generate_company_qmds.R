# Generate companies/<slug>.qmd entrypoints for Connect Cloud.

src_dir <- if (file.exists("company_report_jobs.R")) {
  getwd()
} else {
  "C:/Users/chankalong/OneDrive - Baptist Oi Kwan Social Service/KaLong/non_refresh/kt-eap/analysis"
}
setwd(src_dir)
source("company_report_jobs.R", encoding = "UTF-8")

out_dir <- file.path(src_dir, "companies")
dir.create(out_dir, showWarnings = FALSE)
for (job in company_jobs) {
  path <- file.path(out_dir, paste0(job$slug, ".qmd"))
  write_company_qmd(path, job)
  cat("Wrote ", path, "\n", sep = "")
}
