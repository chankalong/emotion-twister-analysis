# Combine every company_reports/<slug>/emotion_twister_tables.xlsx into one workbook.
# Each original sheet is stacked with Company / slug / Window columns.

src_dir <- if (file.exists("company_report_jobs.R")) {
  getwd()
} else {
  "C:/Users/chankalong/OneDrive - Baptist Oi Kwan Social Service/KaLong/non_refresh/kt-eap/analysis"
}
setwd(src_dir)
source("company_report_jobs.R", encoding = "UTF-8")

library(readxl)
library(writexl)
library(dplyr)

out_root <- file.path(src_dir, "company_reports")
sheet_store <- list()
index_rows <- list()

for (job in company_jobs) {
  xlsx <- file.path(out_root, job$slug, "emotion_twister_tables.xlsx")
  if (!file.exists(xlsx)) {
    index_rows[[job$slug]] <- tibble(
      slug = job$slug,
      Company = job$company_name,
      Window = job$confirmed,
      tables_xlsx = FALSE,
      n_sheets = 0L,
      note = "No emotion_twister_tables.xlsx (empty window or not yet rendered)"
    )
    next
  }
  sheets <- excel_sheets(xlsx)
  index_rows[[job$slug]] <- tibble(
    slug = job$slug,
    Company = job$company_name,
    Window = job$confirmed,
    tables_xlsx = TRUE,
    n_sheets = length(sheets),
    note = NA_character_
  )
  for (sh in sheets) {
    d <- read_xlsx(xlsx, sheet = sh)
    d <- mutate(
      d,
      Company = job$company_name,
      slug = job$slug,
      Window = job$confirmed,
      .before = 1
    )
    if (is.null(sheet_store[[sh]])) {
      sheet_store[[sh]] <- d
    } else {
      sheet_store[[sh]] <- bind_rows(sheet_store[[sh]], d)
    }
  }
}

out <- c(list(`00_companies` = bind_rows(index_rows)), sheet_store)
dest1 <- file.path(out_root, "all_companies_analysis.xlsx")
dest2 <- file.path(src_dir, "all_companies_analysis.xlsx")
dir.create(out_root, showWarnings = FALSE)
writexl::write_xlsx(out, dest1)
file.copy(dest1, dest2, overwrite = TRUE)
cat("Wrote ", dest1, " with ", length(out), " sheets\n", sep = "")
print(out$`00_companies`, n = 50, width = 140)
