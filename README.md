# Emotion Twister Survey — Connect Cloud

Quarto + R report for Posit Connect Cloud. Follows [Publish a Quarto Document with R](https://docs.posit.co/connect-cloud/how-to/r/quarto-r.html).

## Local render

1. Copy `.Renviron.example` to `.Renviron` and set `SURVEY_API_KEY`.
2. `quarto render emotion_twister_survey_report.qmd`

## Publish to Connect Cloud

1. Sign in at [connect.posit.cloud](https://connect.posit.cloud).
2. **Publish** → **Quarto**.
3. Select this repository and branch `main`.
4. Primary file: `emotion_twister_survey_report.qmd`.
5. Under secrets, add:
   - Name: `SURVEY_API_KEY`
   - Value: the survey export API key (same as local `.Renviron`)
6. Click **Publish**.

Free Connect Cloud accounts can only pull **public** GitHub repositories. Paid plans can use a private repo.

Do not commit `.Renviron`, Excel extracts, or `company_reports/` HTML. Those contain credentials or respondent data.

After a code change, push to GitHub and use **Republish** (or keep auto-publish on push).
