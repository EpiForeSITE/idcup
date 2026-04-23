library(data.table)

source_url <- "https://raw.githubusercontent.com/CSSEGISandData/measles_data/refs/heads/main/measles_county_all_updates_detailed.csv"
output_path <- file.path("data", "measles_cases.csv")

# City-to-county mapping aligned with data/census_age.R so we use the same
# geographic units across the project. Filtering on county FIPS avoids pulling
# state-level rows or similarly named counties from the wrong state.
city_lookup <- data.table(
  city = c(
    "Los Angeles", "San Francisco", "New York City", "Boston",
    "Houston", "Dallas", "Philadelphia", "Atlanta",
    "Seattle", "Miami", "Kansas City"
  ),
  state = c(
    "California", "California", "New York", "Massachusetts",
    "Texas", "Texas", "Pennsylvania", "Georgia",
    "Washington", "Florida", "Missouri"
  ),
  county = c(
    "Los Angeles", "San Francisco", "New York", "Suffolk",
    "Harris", "Dallas", "Philadelphia", "Fulton",
    "King", "Miami-Dade", "Jackson"
  ),
  location_id = c(
    6037L, 6075L, 36061L, 25025L,
    48201L, 48113L, 42101L, 13121L,
    53033L, 12086L, 29095L
  )
)

cases <- fread(source_url)

required_columns <- c(
  "location_name",
  "location_id",
  "location_type",
  "date",
  "outcome_type",
  "value"
)

missing_columns <- setdiff(required_columns, names(cases))
if (length(missing_columns) > 0) {
  stop(
    sprintf(
      "The measles source is missing expected column(s): %s",
      paste(missing_columns, collapse = ", ")
    ),
    call. = FALSE
  )
}

cases <- cases[
  location_type == "county" &
  location_id %in% city_lookup$location_id
]

cases <- merge(
  cases,
  city_lookup,
  by = "location_id",
  all.x = TRUE,
  sort = FALSE
)

if (cases[, any(is.na(city))]) {
  stop("Some filtered measles rows could not be mapped back to a project city.", call. = FALSE)
}

setcolorder(
  cases,
  c(
    "city",
    "state",
    "county",
    "location_name",
    "location_id",
    "location_type",
    "date",
    "outcome_type",
    "value"
  )
)

setorder(cases, city, date, outcome_type)
fwrite(cases, output_path)

message(sprintf("Wrote %d rows to %s", nrow(cases), output_path))
