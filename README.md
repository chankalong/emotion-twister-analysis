# Emotion Twister Survey — Connect Cloud

Quarto + R reports for Posit Connect Cloud. Follows [Publish a Quarto Document with R](https://docs.posit.co/connect-cloud/how-to/r/quarto-r.html).

Shared analysis lives in `_report_body.qmd`. Each company has its own entrypoint under `companies/`.

## Local render

1. Copy `.Renviron.example` to `.Renviron` and set `SURVEY_API_KEY`.
2. All organisations: `quarto render emotion_twister_survey_report.qmd`
3. One company: `quarto render companies/tdc.qmd`
4. Combined Excel of every company’s tables: `Rscript build_all_companies_xlsx.R` (uses `company_reports/<slug>/emotion_twister_tables.xlsx`)

## Publish each company to Connect Cloud

Publish **once per company**. Same repository and secret each time; only the primary file changes.

1. Sign in at [connect.posit.cloud](https://connect.posit.cloud).
2. **Publish** → **Quarto**.
3. Repository: `chankalong/emotion-twister-analysis`, branch `main`.
4. Primary file: the company `.qmd` from the table below.
5. Secret: `SURVEY_API_KEY` (same value as local `.Renviron`).
6. Click **Publish**. Repeat for the next company.

| Organisation | Primary file |
|---|---|
| All organisations | `emotion_twister_survey_report.qmd` |
| ESG Hong Kong Ltd. | `companies/esg-hong-kong.qmd` |
| TDC | `companies/tdc.qmd` |
| 恆益 | `companies/hang-yick.qmd` |
| 偉邦物業管理 Well Born (Jun–Jul) | `companies/well-born-2026-06-07.qmd` |
| TOPPAN Nexus Holdings Limited | `companies/toppan-nexus.qmd` |
| MTR | `companies/mtr.qmd` |
| YWCA 長青 | `companies/ywca-cheung-ching.qmd` |
| 南豐集團(葵涌廣場物業管理) | `companies/nan-fung-kwai-chung.qmd` |
| 帝豪閣 | `companies/regal-court.qmd` |
| 集友 | `companies/chiyu.qmd` |
| 偉邦物業管理 Well Born (Sep) | `companies/well-born-2026-09.qmd` |
| BCT | `companies/bct.qmd` |

Free Connect Cloud accounts can only pull **public** GitHub repositories. Paid plans can use a private repo.

Do not commit `.Renviron`, Excel extracts, or `company_reports/` HTML. Those contain credentials or respondent data.

After a code change, push to GitHub and **Republish** each content item (or keep auto-publish on push).
