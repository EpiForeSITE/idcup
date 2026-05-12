# MMR Coverage from other Sources


In this document, we explore existing school-level MMR coverage data to
see if we can find more recent or more granular data than the CDC’s
state-level estimates. We use data from InsightNet tools, particularly,
epiENGAGE’s school-level MMR coverage data, which is available for
download from their GitHub repository. The single file is downloaded
from ForeSITE’s GitHub repository, which contains the same information
but in a single file.

``` r
mmr_schools <- file.path("data", "mmr_schools.csv")

if (!file.exists(mmr_schools)) {
  download.file(
    url = "https://github.com/UofUEpiBio/epiworldRShiny/raw/6a4205c35d647764da2266f6857551de1c291a41/inst/extdata/schools_measles.csv",
    destfile = mmr_schools
  )
}

library(data.table)
mmr_schools <- fread(mmr_schools)
mmr_schools <- mmr_schools[, .(state, county, vaccination_rate)]
mmr_schools <- mmr_schools[, county:= tolower(county)]
```

``` r
city_lookup <- data.table(
  city = c(
    "Los Angeles", "San Francisco", "New York City", "Boston",
    "Houston", "Dallas", "Philadelphia", "Atlanta",
    "Seattle", "Miami", "Kansas City"
  ),
  state = c(
    "CA", "CA", "NY", "MA",
    "TX", "TX", "PA", "GA",
    "WA", "FL", "MO"
  ),
  state_full = c(
    "California", "California", "New York", "Massachusetts",
    "Texas", "Texas", "Pennsylvania", "Georgia",
    "Washington", "Florida", "Missouri"
  ),
  county = c(
    "Los Angeles", "San Francisco", "New York", "Suffolk",
    "Harris", "Dallas", "Philadelphia", "Fulton",
    "King", "Miami-Dade", "Jackson"
  ) |> tolower()
)
```

Let’s now verify which states are covered by this dataset, and which are
not. For those that are not, we are accessing new data.

``` r
# States that have the MMR data
city_lookup[
  which(
    (city_lookup$county %in% unique(mmr_schools$county)) &
      (city_lookup$state %in% unique(mmr_schools$state))
    )
]
```

                city  state    state_full        county
              <char> <char>        <char>        <char>
    1:   Los Angeles     CA    California   los angeles
    2: San Francisco     CA    California san francisco
    3: New York City     NY      New York      new york
    4:        Boston     MA Massachusetts       suffolk
    5:       Houston     TX         Texas        harris
    6:        Dallas     TX         Texas        dallas
    7:  Philadelphia     PA  Pennsylvania  philadelphia
    8:       Seattle     WA    Washington          king

``` r
# States that do not have the MMR data
city_lookup[
  which(!(
    (city_lookup$county %in% unique(mmr_schools$county)) &
      (city_lookup$state %in% unique(mmr_schools$state))
  ))
]
```

              city  state state_full     county
            <char> <char>     <char>     <char>
    1:     Atlanta     GA    Georgia     fulton
    2:       Miami     FL    Florida miami-dade
    3: Kansas City     MO   Missouri    jackson

We now compute the average MMR coverage for the states that have data:

``` r
mmr_schools <- mmr_schools[, .(avg_mmr = mean(vaccination_rate)), by = .(state, county)]

mmr_new <- merge(
  city_lookup,
  mmr_schools,
  by.x = c("state", "county"),
  by.y = c("state", "county"),
  all.y = FALSE
)
```

Comparing with CDC

``` r
mmr_cdc <- fread("data/mmr.csv")

mmr_cdc[, .(city, vacc_rate)] |>
  knitr::kable(digits = 2)
```

| city          | vacc_rate |
|:--------------|----------:|
| Los Angeles   |      96.2 |
| San Francisco |      96.2 |
| New York City |      96.7 |
| Boston        |      96.3 |
| Houston       |      93.6 |
| Dallas        |      94.3 |
| Philadelphia  |      93.5 |
| Atlanta       |      88.4 |
| Seattle       |      91.3 |
| Miami         |      88.1 |
| Kansas City   |      90.4 |

``` r
mmr_new[, .(city, avg_mmr = avg_mmr*100)] |>
  knitr::kable(digits = 2)
```

| city          | avg_mmr |
|:--------------|--------:|
| Los Angeles   |   95.67 |
| San Francisco |   95.85 |
| Boston        |   93.29 |
| New York City |   98.54 |
| Philadelphia  |   96.16 |
| Dallas        |   94.83 |
| Houston       |   93.37 |
| Seattle       |   94.79 |

## Immunization in Atlanta, Georgia

The website Immunization reports
([link](https://immunizationstudyreports.s3.us-east-1.amazonaws.com/Child+Report/Child_Report_2023Q1.html#data-by-county))
indicates that the MMR coverage for children aged 19-35 months in Fulton
county Georgia is 89.2% for the January-March 2023 quarter. This is
higher than the 88.4% reported by the CDC for Atlanta, Georgia.

``` r
mmr_new <- rbind(
  mmr_new,
  data.table(
    city = "Atlanta",
    state = "GA",
    state_full = "Georgia",
    county = "Fulton",
    avg_mmr = 0.892
  )
)
```

## Immunization in Miami Dade, Florida

According to the Florida Department of Health, the vaccination coverage
(full schedule) for 7th grade students in Miami-Dade County for the 2026
was 90.2%, and 90.8% for kindergarteners
([link](https://www.flhealthcharts.gov/ChartsDashboards/rdPage.aspx?rdReport=NonVitalIndNoGrp.Dataviewer)).
This is higher than the 88.8% reported by the CDC for Miami, Florida.

``` r
mmr_new <- rbind(
  mmr_new,
  data.table(
    city = "Miami",
    state = "FL",
    state_full = "Florida",
    county = "Miami-Dade",
    avg_mmr = 0.902
  )
)
```

## Immunization in Kansas City, Missouri

In the case of the Jackson county in Missouri, the Missouri Department
of Health and Senior Services reports an MMR coverage of 89.5% for
Kinder, and 96.2% for 8th grade students in the 2024-2025 school year
([link](https://health.mo.gov/living/families/schoolhealth/dashboard.php)).
This is higher than the 88.8% reported by the CDC for Kansas City,
Missouri.

``` r
mmr_new <- rbind(
  mmr_new,
  data.table(
    city = "Kansas City",
    state = "MO",
    state_full = "Missouri",
    county = "Jackson",
    avg_mmr = 0.895
  )
)
```

# Final comparison

``` r
mmr_new[, .(state, county, mmr_new = avg_mmr)]
```

         state        county   mmr_new
        <char>        <char>     <num>
     1:     CA   los angeles 0.9566559
     2:     CA san francisco 0.9585217
     3:     MA       suffolk 0.9328929
     4:     NY      new york 0.9853797
     5:     PA  philadelphia 0.9615546
     6:     TX        dallas 0.9482991
     7:     TX        harris 0.9336985
     8:     WA          king 0.9479256
     9:     GA        Fulton 0.8920000
    10:     FL    Miami-Dade 0.9020000
    11:     MO       Jackson 0.8950000

``` r
mmr_cdc[, .(city, vacc_rate)]
```

                 city vacc_rate
               <char>     <num>
     1:   Los Angeles      96.2
     2: San Francisco      96.2
     3: New York City      96.7
     4:        Boston      96.3
     5:       Houston      93.6
     6:        Dallas      94.3
     7:  Philadelphia      93.5
     8:       Atlanta      88.4
     9:       Seattle      91.3
    10:         Miami      88.1
    11:   Kansas City      90.4

``` r
# Ensuring caps at the beginning of each word
# for the county name
mmr_new[, county := tools::toTitleCase(county)]

fwrite(mmr_new, file = "data/mmr_extra.csv")
```
