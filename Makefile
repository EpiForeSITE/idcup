EPIWORLD_TREE ?= gvegayon/globalevent-poly
MEASLES_TREE ?= gvegayon/update-language-expose-latent

help:
	@echo "Available targets:"
	@echo "  data/census_age.csv    Generates the census_age.csv file from the data/census_age.R script"
	@echo "  data/mixing_matrix.rds Generates the mixing_matrix.rds file from the data/mixing_matrix.R script"
	@echo "  update-epiworldr       Updates to the latest version from the UofUEpiBio/epiworldR repository"
	@echo "  help                   Displays this help message"

data/census_age.csv: data/census_age.R 
	Rscript --verbose data/census_age.R

data/mixing_matrix.rds: data/mixing_matrix.R data/census_age.csv
	Rscript --verbose data/mixing_matrix.R

update-epiworldr:
	installGithub.r UofUEpiBio/epiworldR@$(EPIWORLD_TREE)

update-measles:
	installGithub.r UofUEpiBio/measles@$(MEASLES_TREE)

CITY ?= Miami
scenario: scenarios/template.qmd data/mixing_matrix.rds 
	cp scenarios/template.qmd "scenarios/$(CITY).qmd"
	quarto render "scenarios/$(CITY).qmd" --to gfm \
		 --output "$(CITY).md" \
		 -P city="$(CITY)" \
		 -P max_pop=50000 && \
	mv "$(CITY).md" "scenarios/$(CITY).md" && \
	rm "scenarios/$(CITY).qmd"

.PHONY: help update-epiworldr update-measles scenario
