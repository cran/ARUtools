# Pattern Docs ----------------------------------------------

#' Create a pattern to match date
#'
#' Helper functions to create regular expression patterns to match different
#' metadata in file paths.
#'
#' By default `create_pattern_aru_id()` matches many common ARU patterns like
#' `BARLT0000`, `S4A0000`, `SM40000`, `SMM0000`, `SMA0000`.
#'
#' `test_pattern()` is a helper function to see what a regular expression
#' pattern will pick out of some example text. Can be used to see if your
#' pattern grabs what you want. This is just a simple wrapper around
#' `stringr::str_extract()`.
#'
#' @param sep Character vector. Expected separator(s) between the pattern parts.
#'   Can be "" for no separator.
#'
#' @return Either a pattern (`create_pattern_xxx()`) or the text extracted by a
#'   pattern (`test_pattern()`)
#'
#' @name create_pattern
NULL

#' @param order Character vector. Expected orders of (y)ear, (m)onth and (d)ate.
#'   Default is "ymd" for Year-Month-Date order. Can have more than one possible
#'   order.
#' @param yr_digits Numeric vector. Number of digits in Year, either 2 or 4.
#'
#' @examples
#' create_pattern_date() # Default matches 2020-01-01 or 2020_01_01 or 20200101
#' # ("-", "_" or "" as separators)
#' create_pattern_date(sep = "") # Matches only 20200101 (no separator allowed)
#'
#' @export
#' @describeIn create_pattern Create a pattern to match a date

create_pattern_date <- function(order = "ymd", sep = c("_", "-", ""), yr_digits = 4) {
  check_text(order, opts = c("ymd", "dmy", "mdy"))
  check_text(sep)
  check_num(yr_digits, opts = c(2, 4))

  sep <- create_pattern_sep(sep, optional = FALSE)


  yr_digits <- rev(sort(yr_digits)) # Ensure long patterns matched first if available

  y <- dplyr::case_when(
    yr_digits == 4 ~ "([12]{1}\\d{3})", # First must be 1 or 2
    yr_digits == 2 ~ "(\\d{2})"
  ) |>
    pat_collapse()

  m <- "(\\d{2})"
  d <- "(\\d{2})"

  dplyr::case_when(
    order == "ymd" ~ paste0(y, sep, m, sep, d),
    order == "mdy" ~ paste0(m, sep, d, sep, y),
    order == "dmy" ~ paste0(d, sep, m, sep, y)
  ) |>
    pat_collapse()
}

#' @param seconds Character. Whether seconds are included. Options are "yes",
#' "no", "maybe".
#'
#' @examples
#' create_pattern_time() # Default matches 23_59_59 (_, -, :, as optional separators)
#' create_pattern_time(sep = "", seconds = "no") # Matches 2359 (no seconds no separators)
#'
#' @export
#'
#' @describeIn create_pattern Create a pattern to match a time
create_pattern_time <- function(sep = c("_", "-", ":", ""), seconds = "yes") {
  check_text(sep)
  check_text(seconds, opts = c("yes", "no", "maybe"), n = 1)


  sep <- create_pattern_sep(sep, optional = FALSE)

  h <- "([0-2]{1}[0-9]{1})"
  m <- "([0-5]{1}[0-9]{1})"

  p <- paste0(h, sep, m)
  if (seconds != "no") p <- paste0(p, "(", sep, "([0-5]{1}[0-9]{1}))")
  if (seconds == "maybe") p <- paste0(p, "?")
  p
}

#' @param optional Logical. Whether the separator should be optional or not.
#'   Allows matching on different date/time patterns.
#'
#' @examples
#' create_pattern_dt_sep() # Default matches 'T' as a required separator
#' create_pattern_dt_sep(optional = TRUE) # 'T' as an optional separator
#' create_pattern_dt_sep(c("T", "_", "-")) # 'T', '_', or '-' as separators
#'
#' @export
#' @describeIn create_pattern Create a pattern to match a date/time separator

create_pattern_dt_sep <- function(sep = "T", optional = FALSE) {
  create_pattern_sep(sep, optional)
}


#' @param arus Character vector. Pattern(s) identifying the ARU prefix (usually
#'   model specific).
#' @param n_digits Numeric vector. Number of digits expected to follow the
#'   `arus` pattern. Can be one or two (a range).
#'
#' @examples
#' create_pattern_aru_id()
#' create_pattern_aru_id(prefix = "CWS")
#' create_pattern_aru_id(n_digits = 12)
#'
#' @export
#' @describeIn create_pattern Create a pattern to match an ARU id
create_pattern_aru_id <- function(arus = c("BARLT", "S\\d(A|U)", "SM\\d", "SMM", "SMA"),
                                  n_digits = c(4, 8),
                                  sep = c("_", "-", ""),
                                  prefix = "",
                                  suffix = "") {
  check_text(arus)
  check_num(n_digits, n = c(1, 2))
  check_text(sep)
  check_text(prefix)
  check_text(suffix)

  sep <- create_pattern_sep(sep, optional = FALSE)
  if (length(n_digits) > 1) {
    n_digits <- paste0("\\d{", n_digits[1], ",", n_digits[2], "}")
  } else {
    n_digits <- paste0("\\d{", n_digits, "}")
  }

  arus <- paste0("(", arus, ")", collapse = "|")
  prefix <- pat_collapse(prefix)
  suffix <- pat_collapse(suffix)

  paste0(prefix, "(", arus, ")", sep, n_digits, suffix)
}

#' @param prefix Character vector. Prefix(es) for site ids.
#' @param p_digits Numeric vector. Number(s) of digits following the `prefix`.
#' @param suffix Character vector. Suffix(es) for site ids.
#' @param s_digits Numeric vector. Number(s) of digits following the `suffix`.
#'
#' @export
#'
#' @examples
#'
#' create_pattern_site_id() # Default matches P00-0
#' create_pattern_site_id(
#'   prefix = "site", p_digits = 3, sep = "",
#'   suffix = c("a", "b", "c"), s_digits = 0
#' ) # Matches site000a
#'
#' @describeIn create_pattern Create a pattern to match a site id
create_pattern_site_id <- function(prefix = c("P", "Q"),
                                   p_digits = 2,
                                   sep = c("_", "-"),
                                   suffix = "",
                                   s_digits = 1) {
  check_text(prefix)
  check_num(p_digits)
  check_text(sep)
  check_text(suffix)
  check_num(s_digits)

  sep <- create_pattern_sep(sep, optional = FALSE)

  # Use reverse sort, to make sure that longer patterns are matched first
  # (otherwise shorter patterns can be matched to what should be a long one)
  prefix <- pat_collapse(prefix)
  if (any(p_digits > 0)) {
    p_digits <- pat_collapse(paste0("\\d{", rev(sort(p_digits)), "}"))
    prefix <- paste0(prefix, p_digits)
  }

  suffix <- pat_collapse(suffix)
  if (any(s_digits > 0)) {
    s_digits <- pat_collapse(paste0("\\d{", rev(sort(s_digits)), "}"))
    suffix <- paste0(suffix, s_digits)
  }
  if (suffix != "") suffix <- paste0(sep, suffix)

  paste0(prefix, suffix)
}

#' Create sep pattern from series of options
#'
#' @param sep Charaacter vector of separators
#' @param optional Whether separators are optional or not
#'
#' @noRd
create_pattern_sep <- function(sep, optional = TRUE) {
  check_text(sep)
  check_logical(optional)

  if (!all(sep == "")) {
    sep <- paste0("(", paste0(sep, collapse = "|"), ")")
    if (optional) sep <- paste0(sep, "?")
  } else {
    sep <- ""
  }
  sep
}


#' Collapse a pattern down
#'
#' Turns a vector of patterns into a regular expression: `(x|x)`
#' Sort the vector in reverse order so that higher numbers (longer patterns) can
#' be matched first (may not be strictly necessary here).
#'
#' @noRd
pat_collapse <- function(x) {
  if (any(x != "")) {
    paste0("(", paste0("(", rev(sort(x)), ")", collapse = "|"), ")")
  } else {
    ""
  }
}




#' @param test Character vector. Examples of text to test.
#' @param pattern Character. Regular expression pattern to test.
#'
#' @export
#'
#' @examples
#' pat <- create_pattern_aru_id(prefix = "CWS")
#' test_pattern("CWS_BARLT1012", pat) # No luck
#' pat <- create_pattern_aru_id(prefix = "CWS_")
#' test_pattern("CWS_BARLT1012", pat) # Ah ha!
#' pat <- create_pattern_site_id()
#'
#' pat <- create_pattern_site_id()
#' test_pattern("P03", pat) # Nope
#' test_pattern("P03-1", pat) # Success!
#'
#' pat <- create_pattern_site_id(prefix = "site", p_digits = 3, sep = "", s_digits = 0)
#' test_pattern("site111", pat)
#' pat <- create_pattern_site_id(
#'   prefix = "site", p_digits = 3, sep = "",
#'   suffix = c("a", "b", "c"), s_digits = 0
#' )
#' test_pattern(c("site9", "site100a"), pat)
#'
#' @describeIn create_pattern Test patterns

test_pattern <- function(test, pattern) {
  check_text(test)
  check_text(pattern, n = 1)
  stringr::str_extract(test, pattern)
}
