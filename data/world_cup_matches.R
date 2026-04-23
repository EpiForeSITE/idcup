# R script created by Codex GPT-5.4 with the following prompt:
# Using the R programming language, create an R script called 
# data/world_cup_matches.R that generates data/world_cup_matches.csv.
# The R script should extract the 2026 FIFA World Cup matches data
# from this wikipedia site
# https://en.wikipedia.org/wiki/2026_FIFA_World_Cup#Match_schedule
required_packages <- c("xml2", "rvest")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    sprintf(
      "Missing required package(s): %s",
      paste(missing_packages, collapse = ", ")
    ),
    call. = FALSE
  )
}

source_url <- "https://en.wikipedia.org/wiki/2026_FIFA_World_Cup#Match_schedule"
output_path <- file.path("data", "world_cup_matches.csv")

clean_text <- function(x) {
  if (inherits(x, c("xml_node", "xml_nodeset"))) {
    x <- rvest::html_text2(x)
  }

  x <- gsub("\u00a0", " ", x, fixed = TRUE)
  x <- gsub("[[:space:]]+", " ", x)
  trimws(x)
}

normalize_ascii <- function(x) {
  if (!is.character(x)) {
    return(x)
  }

  converted <- iconv(x, from = "", to = "ASCII//TRANSLIT")
  converted[is.na(converted)] <- x[is.na(converted)]
  converted
}

get_first_text <- function(node, css) {
  child <- rvest::html_element(node, css)

  if (length(child) == 0 || inherits(child, "xml_missing")) {
    return(NA_character_)
  }

  clean_text(child)
}

get_first_attr <- function(node, css, attr) {
  child <- rvest::html_element(node, css)

  if (length(child) == 0 || inherits(child, "xml_missing")) {
    return(NA_character_)
  }

  value <- rvest::html_attr(child, attr)

  if (is.na(value) || !nzchar(value)) {
    return(NA_character_)
  }

  value
}

page <- xml2::read_html(source_url)
article_root <- rvest::html_element(
  page,
  xpath = "//*[@id='mw-content-text']//div[contains(@class, 'mw-parser-output')][1]"
)
article_nodes <- xml2::xml_children(article_root)

current_h2 <- NA_character_
current_h3 <- NA_character_
current_h4 <- NA_character_
matches <- list()

for (node in article_nodes) {
  node_name <- xml2::xml_name(node)
  node_class <- xml2::xml_attr(node, "class")

  if (identical(node_name, "div") && !is.na(node_class) && grepl("\\bmw-heading\\b", node_class)) {
    heading <- rvest::html_element(node, xpath = "./h2 | ./h3 | ./h4")
    heading_level <- xml2::xml_name(heading)
    heading_text <- clean_text(heading)

    if (identical(heading_level, "h2")) {
      current_h2 <- heading_text
      current_h3 <- NA_character_
      current_h4 <- NA_character_
    } else if (identical(heading_level, "h3")) {
      current_h3 <- heading_text
      current_h4 <- NA_character_
    } else if (identical(heading_level, "h4")) {
      current_h4 <- heading_text
    }

    next
  }

  if (!identical(node_name, "div") || is.na(node_class) || !grepl("\\bfootballbox\\b", node_class)) {
    next
  }

  if (!current_h2 %in% c("Group stage", "Knockout stage")) {
    next
  }

  match_label <- get_first_text(node, ".fscore")
  match_number <- suppressWarnings(as.integer(sub("^Match\\s+", "", match_label)))

  location_links <- rvest::html_elements(node, ".fright a")
  venue <- if (length(location_links) >= 1) clean_text(location_links[[1]]) else NA_character_
  city <- if (length(location_links) >= 2) clean_text(location_links[[length(location_links)]]) else NA_character_

  time_text <- get_first_text(node, ".ftime")
  utc_offset <- get_first_text(node, ".ftime a")
  if (!is.na(time_text) && !is.na(utc_offset)) {
    time_text <- trimws(sub(utc_offset, "", time_text, fixed = TRUE))
  }

  section <- if (!is.na(current_h4)) current_h4 else current_h3
  group <- if (!is.na(current_h3) && grepl("^Group\\s", current_h3)) current_h3 else NA_character_
  round <- if (identical(current_h2, "Knockout stage")) section else NA_character_

  matches[[length(matches) + 1L]] <- data.frame(
    match_number = match_number,
    stage = current_h2,
    section = section,
    group = group,
    round = round,
    date = get_first_text(node, ".dtstart"),
    time_local = time_text,
    utc_offset = utc_offset,
    home_team = get_first_text(node, ".fhome"),
    away_team = get_first_text(node, ".faway"),
    venue = venue,
    city = city,
    location = get_first_text(node, ".fright"),
    report_url = get_first_attr(node, ".fgoals a.external", "href"),
    source_url = source_url,
    stringsAsFactors = FALSE
  )
}

matches <- do.call(rbind, matches)

if (nrow(matches) == 0) {
  stop("No matches were parsed from the Wikipedia page.", call. = FALSE)
}

matches <- matches[order(matches$match_number), ]
rownames(matches) <- NULL

if (anyNA(matches$match_number) || anyDuplicated(matches$match_number)) {
  stop("Match numbers are missing or duplicated in the parsed results.", call. = FALSE)
}

expected_matches <- 104L
if (nrow(matches) != expected_matches) {
  stop(
    sprintf(
      "Expected %d matches, but parsed %d. Wikipedia's page structure may have changed.",
      expected_matches,
      nrow(matches)
    ),
    call. = FALSE
  )
}

if (!identical(matches$match_number, seq_len(expected_matches))) {
  stop("Parsed match numbers do not span the full expected range 1:104.", call. = FALSE)
}

character_columns <- vapply(matches, is.character, logical(1))
matches[character_columns] <- lapply(matches[character_columns], normalize_ascii)

# Adding the city, country, and state
library(data.table)
stadiums <- fread("data/stadiums.csv")

# Minor fixes
stadiums[stadium == "GEHA Field at Arrowhead Stadium", stadium := "Arrowhead Stadium"]
stadiums[stadium == "Estadio Banorte", stadium := "Estadio Azteca"]

matches2 <- merge(
  matches, stadiums,
  by.x = "venue",
  by.y = "stadium",
  all = TRUE
  ) |> as.data.table()

matches2[, source_url := NULL][, city.x := NULL]
setnames(matches2, c("city.y"), c("city"))

# Final tweak to match expected data in our analysis code
matches2[city == "New York/New Jersey", city := "New York City"]
matches2[city == "San Francisco Bay Area", city := "San Francisco"]

utils::write.csv(matches2, output_path, row.names = FALSE)
message(sprintf("Wrote %d matches to %s", nrow(matches2), output_path))
