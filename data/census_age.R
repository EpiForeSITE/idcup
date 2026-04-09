library(multigroup.vaccine)

# Read population data
population <- read.csv("data/population.csv", comment.char = "#")

# Map each city to its primary county and state for census lookup.
# Note: census data is county-level; the county listed below is the primary
# county associated with each city.
city_info <- data.frame(
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
    "Los Angeles County", "San Francisco County", "New York County",
    "Suffolk County", "Harris County", "Dallas County",
    "Philadelphia County", "Fulton County",
    "King County", "Miami-Dade County", "Jackson County"
  ),
  stringsAsFactors = FALSE
)

# Retain only cities present in population.csv
city_info <- city_info[city_info$city %in% population$city, ]

# Standard 5-year age groups used in epidemiological modeling
age_groups <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85)

# Retrieve census age distribution for each city
census_age <- do.call(rbind, lapply(seq_len(nrow(city_info)), function(i) {
  state_fips <- getStateFIPS(city_info$state[i])

  city_data <- tryCatch(
    getCensusData(
      state_fips  = state_fips,
      county_name = city_info$county[i],
      year        = 2024,
      age_groups  = age_groups
    ),
    error = function(e) {
      stop(sprintf(
        "Failed to retrieve census data for city '%s' (county: '%s', state FIPS: '%s', year: 2024).\nError: %s",
        city_info$city[i], city_info$county[i], state_fips, conditionMessage(e)
      ))
    }
  )

  message(
    sprintf(
      "Got census data for city '%s' (county: '%s', state FIPS: '%s', year: 2024).",
      city_info$city[i], city_info$county[i], state_fips
    )
  )

  data.frame(
    city      = city_info$city[i],
    age_group = city_data$age_labels,
    total     = city_data$age_pops,
    stringsAsFactors = FALSE
  )
}))

write.csv(census_age, "data/census_age.csv", row.names = FALSE)
