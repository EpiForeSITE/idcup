EPIWORLD_TREE ?= gvegayon/globalevent-poly
MEASLES_TREE ? gvegayon/update-language-expose-latent

help:
	@echo "Available targets:"
	@echo "  data/census_age.csv  Generates the census_age.csv file from the data/census_age.R script"
	@echo "  update-epiworldr     Updates to the latest version from the UofUEpiBio/epiworldR repository"
	@echo "  help                 Displays this help message"
data/census_age.csv: data/census_age.R 
	Rscript --verbose data/census_age.R`

update-epiworldr:
	installGithub.r UofUEpiBio/epiworldR@$(EPIWORLD_TREE)

update-measles:
	installGithub.r UofUEpiBio/measles@$(MEASLES_TREE)

.PHONY: help update-epiworldr
