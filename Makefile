R := $(shell which Rscript)

deps:
	$(R) -e "if (!require('renv', quietly=TRUE)) install.packages('renv'); renv::restore(prompt = FALSE)"

all: output/arima_results.rds


output/unitroot_results.rds: scripts/02_unitroot.R
	$(R) scripts/02_unitroot.R

output/arima_results.rds: scripts/03_arima_x.R output/unitroot_results.rds
	$(R) scripts/03_arima_x.R

clean:
	rm -rf output/*

.PHONY: all deps clean
