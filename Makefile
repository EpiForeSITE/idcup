EPIWORLD_TREE ?= master
MEASLES_TREE ?= gvegayon/fast-mixing

help:
	@echo "Available targets:"
	@echo "  data/census_age.csv    Generates the census_age.csv file from the data/census_age.R script"
	@echo "  data/mixing_matrix.rds Generates the mixing_matrix.rds file from the data/mixing_matrix.R script"
	@echo "  update-measles         Updates to the latest version from the UofUEpiBio/measles repository"
	@echo "  scenario               Generates a scenario markdown file for a specified city (default: Miami)"
	@echo "  all                    Generates scenario markdown files for a predefined list of cities"
	@echo "  help                   Displays this help message"

data/census_age.csv: data/census_age.R 
	Rscript --verbose data/census_age.R

data/mixing_matrix.rds: data/mixing_matrix.R data/census_age.csv
	Rscript --verbose data/mixing_matrix.R

data/world_cup_matches.csv: data/world_cup_matches.R
	Rscript --verbose data/world_cup_matches.R

update-measles:
	installGithub.r UofUEpiBio/measles@$(MEASLES_TREE)

CITY ?= Miami
MAX_POP ?= 50000
scenario: scenarios/template.qmd
	cp scenarios/template.qmd "scenarios/$(CITY).qmd"
	quarto render "scenarios/$(CITY).qmd" --to gfm \
		 --output "$(CITY).md" \
		 -P city="$(CITY)" \
		 -P max_pop="$(MAX_POP)" && \
	mv "$(CITY).md" "scenarios/$(CITY).md" && \
	rm "scenarios/$(CITY).qmd"

CITIES ?= "Los Angeles" "San Francisco" "New York City" "Boston" "Houston" "Dallas" "Philadelphia" "Atlanta" "Seattle" "Miami" "Kansas City"
all:
	for city in $(CITIES); do \
		echo "Generating scenario for $$city..."; \
		$(MAKE) scenario CITY="$$city"; \
	done

.PHONY: help update-epiworldr update-measles scenario
