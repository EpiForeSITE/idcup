library(socialmixr)
library(data.table)

# Read census age data
census_age <- read.csv("data/census_age.csv", stringsAsFactors = FALSE)

# Age group lower limits matching the 5-year bins in census_age.csv
age_limits <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80)

dnames <- sprintf("%dto%d", age_limits[-length(age_limits)], age_limits[-1] - 1)
dnames <- c(dnames, "80plus")

# Retrieving mixing data from epistorm
if (!file.exists(file.path("data", "Total-M-by5_80-matrix.csv"))) {
  download.file(
    url = "https://raw.githubusercontent.com/epistorm/Epistorm-Mix/05966ba49c7b49fb1cd902d6b98b3be0bb2785a8/matrices/M_matrix/Total-M-by5_80-matrix.csv",
    destfile = file.path("data", "Total-M-by5_80-matrix.csv")
  )  
}

# Creating a mixing matrix from epistorm data
mm_epistorm <- fread("data/Total-M-by5_80-matrix.csv")
mm_epistorm <- mm_epistorm[, resp_age_by5_80 := NULL] |> 
  as.matrix()

dimnames(mm_epistorm) <- list(dnames, dnames)


saveRDS(mm_epistorm, "data/mixing_matrix.rds")
