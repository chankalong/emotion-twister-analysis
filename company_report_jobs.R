# Company report jobs — confirmed fieldwork windows (2026).
# Overlapping dates are split so each organisation is not mixed:
#   handover days go to the campaign that starts that day;
#   concurrent companies are split by survey location code.

w <- function(start, end, locations = NULL) {
  list(start = as.Date(start), end = as.Date(end), locations = locations)
}

company_jobs <- list(
  list(
    slug = "esg-hong-kong",
    company_name = "ESG Hong Kong Ltd.",
    confirmed = "16 Apr – 30 Apr 2026",
    windows = list(w("2026-04-16", "2026-04-30"))
  ),
  list(
    slug = "tdc",
    company_name = "TDC",
    confirmed = "4 May – 8 May 2026 and 8 Jun – 12 Jun 2026",
    windows = list(
      w("2026-05-04", "2026-05-08"),
      w("2026-06-08", "2026-06-12")
    )
  ),
  list(
    slug = "hang-yick",
    company_name = "恆益",
    confirmed = "15 Jun – 30 Jun 2026",
    note = "Jun 30 assigned to Well Born (wave start; @wb.com.hk).",
    windows = list(w("2026-06-15", "2026-06-29"))
  ),
  list(
    slug = "well-born",
    company_name = "偉邦物業管理 Well Born",
    confirmed = "30 Jun – 17 Jul 2026 and 18 Sep – 28 Sep 2026",
    note = "Jul 17 assigned to TOPPAN; Sep wave is location 84669 (84792 on 18 Sep stays with 集友).",
    windows = list(
      w("2026-06-30", "2026-07-16"),
      w("2026-09-18", "2026-09-28", "84669")
    )
  ),
  list(
    slug = "toppan-nexus",
    company_name = "TOPPAN Nexus Holdings Limited",
    confirmed = "17 Jul – 24 Jul 2026",
    windows = list(w("2026-07-17", "2026-07-24"))
  ),
  list(
    slug = "mtr",
    company_name = "MTR",
    confirmed = "13 Aug – 28 Aug 2026",
    note = "84792 from 21 Aug is YWCA; 84817 on 13 Aug excluded as test.",
    windows = list(
      w("2026-08-13", "2026-08-28", "84669"),
      w("2026-08-13", "2026-08-19", "84792")
    )
  ),
  list(
    slug = "ywca-cheung-ching",
    company_name = "YWCA 長青",
    confirmed = "21 Aug – 28 Aug 2026",
    note = "Location 84792 only (MTR used 84669 / earlier 84792).",
    windows = list(w("2026-08-21", "2026-08-28", "84792"))
  ),
  list(
    slug = "nan-fung-kwai-chung",
    company_name = "南豐集團(葵涌廣場物業管理)",
    confirmed = "1 Sep – 8 Sep 2026",
    note = "8 Sep location 84669 assigned to 帝豪閣.",
    windows = list(
      w("2026-09-01", "2026-09-08", c("84817", "84792")),
      w("2026-09-01", "2026-09-07", "84669")
    )
  ),
  list(
    slug = "regal-court",
    company_name = "帝豪閣",
    confirmed = "8 Sep – 18 Sep 2026",
    note = "Location 84669; 84792 in this period is 集友. 18 Sep 84669 assigned to Well Born.",
    windows = list(w("2026-09-08", "2026-09-17", "84669"))
  ),
  list(
    slug = "chiyu",
    company_name = "集友",
    confirmed = "10 Sep – 18 Sep 2026",
    note = "Location 84792 (@chiyubank.com).",
    windows = list(w("2026-09-10", "2026-09-18", "84792"))
  ),
  list(
    slug = "bct",
    company_name = "BCT",
    confirmed = "5 Oct – 16 Oct 2026",
    windows = list(w("2026-10-05", "2026-10-16"))
  )
)

report_yaml_header <- function(title) {
  paste0(
    "---\n",
    sprintf("title: \"%s\"\n", gsub("\"", "\\\\\"", title)),
    "date: today\n",
    "format:\n",
    "  html:\n",
    "    toc: true\n",
    "    toc-depth: 3\n",
    "    toc-title: \"Table of Contents\"\n",
    "    theme: cosmo\n",
    "    code-fold: true\n",
    "    embed-resources: false\n",
    "    fig-width: 8\n",
    "    fig-height: 5\n",
    "execute:\n",
    "  warning: false\n",
    "  message: false\n",
    "include-in-header:\n",
    "  text: |\n",
    "    <style>\n",
    "      a.btn-dl {\n",
    "        display: inline-block;\n",
    "        padding: 0.3rem 0.8rem;\n",
    "        margin: 0.15rem 0.35rem 0.7rem 0;\n",
    "        background: #2c3e50;\n",
    "        color: #fff !important;\n",
    "        text-decoration: none;\n",
    "        border-radius: 4px;\n",
    "        font-size: 0.85rem;\n",
    "      }\n",
    "      a.btn-dl:hover { background: #1a252f; }\n",
    "      .report-table, .report-table .html-widget, .report-table .datatables {\n",
    "        width: 100% !important;\n",
    "        max-width: 100%;\n",
    "        margin-left: 0 !important;\n",
    "        margin-right: 0 !important;\n",
    "      }\n",
    "      .report-table .html-fill-item {\n",
    "        flex: 0 0 auto !important;\n",
    "        min-width: 0 !important;\n",
    "      }\n",
    "      div.dataTables_wrapper {\n",
    "        width: 100% !important;\n",
    "        margin: 0 !important;\n",
    "      }\n",
    "      div.dataTables_wrapper div.dataTables_filter {\n",
    "        float: none;\n",
    "        text-align: left;\n",
    "        margin-bottom: 0.4rem;\n",
    "      }\n",
    "      table.dataTable {\n",
    "        width: 100% !important;\n",
    "        margin: 0 !important;\n",
    "      }\n",
    "    </style>\n",
    "---\n"
  )
}

write_company_qmd <- function(path, job) {
  loc_txt <- function(locs) {
    if (is.null(locs) || length(locs) == 0) return("NULL")
    paste0("c(", paste(sprintf("\"%s\"", locs), collapse = ", "), ")")
  }
  win_txt <- vapply(job$windows, function(w) {
    sprintf(
      "    list(start = as.Date(\"%s\"), end = as.Date(\"%s\"), locations = %s)",
      as.character(w$start), as.character(w$end), loc_txt(w$locations)
    )
  }, character(1))
  title <- paste0("Emotion Twister Survey — ", job$company_name)
  txt <- paste0(
    report_yaml_header(title),
    "\n",
    "::: {.callout-note}\n",
    "This report was generated using AI under general human direction. At the time of generation, the contents have not been comprehensively reviewed by a human analyst.\n",
    ":::\n\n",
    "# Configuration\n\n",
    "> Company-specific Connect Cloud entrypoint. Shared analysis is in `_report_body.qmd`.\n\n",
    "```{r}\n",
    "#| label: config\n\n",
    "if (identical(basename(getwd()), \"companies\")) setwd(\"..\")\n",
    "if (file.exists(\".Renviron\")) readRenviron(\".Renviron\")\n\n",
    sprintf("company_name     <- \"%s\"\n", gsub("\"", "\\\\\"", job$company_name)),
    "use_all_dates    <- FALSE\n",
    "include_hk_forms <- FALSE\n",
    "start_date    <- as.Date(\"", as.character(job$windows[[1]]$start), "\")\n",
    "end_date      <- as.Date(\"", as.character(job$windows[[length(job$windows)]]$end), "\")\n",
    "include_windows <- list(\n",
    paste(win_txt, collapse = ",\n"),
    "\n)\n",
    "exclude_periods <- list()\n",
    "source(\"_config_labels.R\", encoding = \"UTF-8\")\n",
    "```\n\n",
    "{{< include ../_report_body.qmd >}}\n"
  )
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  writeLines(enc2utf8(txt), path, useBytes = TRUE)
}

write_company_config <- function(path, job) {
  loc_txt <- function(locs) {
    if (is.null(locs) || length(locs) == 0) return("NULL")
    paste0("c(", paste(sprintf("\"%s\"", locs), collapse = ", "), ")")
  }
  win_txt <- vapply(job$windows, function(w) {
    sprintf(
      "    list(start = as.Date(\"%s\"), end = as.Date(\"%s\"), locations = %s)",
      as.character(w$start), as.character(w$end), loc_txt(w$locations)
    )
  }, character(1))
  txt <- paste0(
    "# Auto-generated company config — do not edit by hand\n",
    sprintf("company_name <- \"%s\"\n", gsub("\"", "\\\\\"", job$company_name)),
    "use_all_dates <- FALSE\n",
    "include_hk_forms <- FALSE\n",
    "include_windows <- list(\n",
    paste(win_txt, collapse = ",\n"),
    "\n)\n"
  )
  writeLines(enc2utf8(txt), path, useBytes = TRUE)
}
