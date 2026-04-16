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

.PHONY: help update-epiworldr update-measles
