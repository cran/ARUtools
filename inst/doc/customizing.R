## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(ARUtools)
library(dplyr)

## -----------------------------------------------------------------------------
f <- c(
  "site100-a45/2020_05_04_05_25_00_s4a1234.wav",
  "site102-b56/2020_05_04_05_40_00_s4a1111.wav"
)

## -----------------------------------------------------------------------------
clean_metadata(project_files = f)

## -----------------------------------------------------------------------------
m <- clean_metadata(project_files = f, pattern_site_id = "site\\d{3}-(a|b)\\d{2}")
m
m$site_id

## -----------------------------------------------------------------------------
pat_site <- create_pattern_site_id(
  prefix = "site", p_digits = 3,
  sep = "-",
  suffix = c("a", "b"), s_digits = 2
)
pat_site

## -----------------------------------------------------------------------------
m <- clean_metadata(project_files = f, pattern_site_id = pat_site)
m$site_id

## -----------------------------------------------------------------------------
test_pattern(f[1], pat_site)

## -----------------------------------------------------------------------------
pat_aru <- create_pattern_aru_id(arus = "s4a", n_digits = 4)

m <- clean_metadata(
  project_files = f,
  pattern_site_id = pat_site,
  pattern_aru_id = pat_aru,
  pattern_dt_sep = "_"
)
m

## -----------------------------------------------------------------------------
f <- c(
  "P01-1/05042020_052500_S4A1234.wav",
  "P01-1/05042020_054000_S4A1111.wav"
)

## -----------------------------------------------------------------------------
clean_metadata(
  project_files = f,
  pattern_dt_sep = "_",
  pattern_date = create_pattern_date(order = "mdy"),
  order_date = "mdy"
)

## -----------------------------------------------------------------------------
f <- c(
  "P01-1/05042020_052500_S4A1234.wav",
  "P01-1/05042020_054000_S4A1111.wav",
  "Site10/2020-01-01T09:00:00_BARLT100.wav",
  "Site10/2020-01-02T09:00:00_BARLT100.wav"
)

## -----------------------------------------------------------------------------
m1 <- clean_metadata(
  project_files = f,
  pattern_dt_sep = "_",
  pattern_date = create_pattern_date(order = "mdy"),
  order_date = "mdy"
)
m1 <- filter(m1, !is.na(date_time)) # omit ones that didn't work
m1

m2 <- clean_metadata(
  project_files = f,
  pattern_site_id = create_pattern_site_id(prefix = "Site", s_digits = 0),
  pattern_aru_id = create_pattern_aru_id(n_digits = 3)
)
m2 <- filter(m2, !is.na(date_time)) # omit ones that didn't work
m2

m <- bind_rows(m1, m2)
m

## -----------------------------------------------------------------------------
nrow(m)

## -----------------------------------------------------------------------------
m <- clean_metadata(
  project_files = f,
  pattern_dt_sep = c("_", "T"),
  pattern_date = create_pattern_date(order = c("ymd", "mdy")),
  order_date = c("ymd", "mdy"),
  pattern_aru_id = create_pattern_aru_id(n_digits = c(3, 4)),
  pattern_site_id = create_pattern_site_id(
    prefix = c("P", "Site"),
    sep = c("-", ""),
    s_digits = c(1, 0)
  )
)
m

## -----------------------------------------------------------------------------
check_meta(m)
check_meta(m, date = TRUE)
check_problems(m)

unique(m$site_id)
unique(m$aru_id)

## -----------------------------------------------------------------------------
clean_metadata(project_files = example_files, subset = "^a")

## -----------------------------------------------------------------------------
clean_metadata(project_files = example_files, subset = "^a", subset_type = "omit")

## -----------------------------------------------------------------------------
f <- c(
  "a_BARLT10962_P01_1/P01_1_20200502T050000_ARU.mp4",
  "a_BARLT10962_P01_1/P01_1_20200503T052000_ARU.mp4"
)

## ----error = TRUE-------------------------------------------------------------
clean_metadata(project_files = f)

## -----------------------------------------------------------------------------
clean_metadata(project_files = f, file_type = "mp4")

