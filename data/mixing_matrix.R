library(socialmixr)

# Read census age data
census_age <- read.csv("data/census_age.csv", stringsAsFactors = FALSE)

# Age group lower limits matching the 5-year bins in census_age.csv
age_limits <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85)

# Load POLYMOD survey data
data(polymod)

# Build a mixing matrix for each city
cities <- unique(census_age$city)

mixing_matrix <- lapply(cities, function(city_name) {

  city_data <- census_age[census_age$city == city_name, ]

  # Create survey population data frame expected by socialmixr
  survey_pop <- data.frame(
    lower.age.limit = age_limits,
    population      = city_data$total
  )

  # Generate the contact matrix using POLYMOD survey data weighted
  # by the city-specific age distribution
  cm <- contact_matrix(
    polymod,
    survey.pop = survey_pop,
    age.limits = age_limits,
    symmetric  = TRUE
  )

  # Extract the matrix and set row/column names from the census age groups
  mat <- cm$matrix
  dimnames(mat) <- list(city_data$age_group, city_data$age_group)

  # Make row-stochastic (each row sums to 1)
  # mat <- mat / rowSums(mat)

  mat

})

names(mixing_matrix) <- cities

saveRDS(mixing_matrix, "data/mixing_matrix.rds")
