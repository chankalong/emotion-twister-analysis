format_window <- function(w) {
  loc <- if (!is.null(w$locations) && length(w$locations) > 0) {
    paste0(" (location ", paste(w$locations, collapse = ", "), ")")
  } else {
    ""
  }
  paste0(format(as.Date(w$start), "%d %B %Y"), " to ", format(as.Date(w$end), "%d %B %Y"), loc)
}

if (!isTRUE(use_all_dates) && length(include_windows) > 0) {
  start_date <- min(as.Date(vapply(include_windows, function(w) as.character(w$start), character(1))))
  end_date   <- max(as.Date(vapply(include_windows, function(w) as.character(w$end), character(1))))
}

period_cover_lab <- if (isTRUE(use_all_dates)) {
  "all available submission dates"
} else if (length(include_windows) > 0) {
  paste(vapply(include_windows, format_window, character(1)), collapse = "; ")
} else {
  paste(format(start_date, "%d %B %Y"), "to", format(end_date, "%d %B %Y"))
}

data_source_lab <- if (isTRUE(include_hk_forms)) {
  "The sample combines the live survey export with the Microsoft Forms Excel file (same instruments)."
} else {
  "The sample uses the live survey export for this organisation’s confirmed fieldwork window. The Hong Kong Forms Excel file is not mixed into company-specific reports."
}
