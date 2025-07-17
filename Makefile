# -----------------------------------------------------------
# Makefile — Industrial Production Paper  (cross-platform)
# -----------------------------------------------------------

# Detect operating system to choose the right Rscript command
ifeq ($(OS),Windows_NT)            # Windows (cmd or PowerShell)
  R := Rscript.exe                 # assume Rscript.exe is on PATH
  RM := del /Q                     # delete command
else                               # Unix-like (macOS, Linux, WSL)
  R := $(shell which Rscript)
  RM := rm -rf
endif

# ------------ 1. Restore exact package versions -------------
deps:
	$(R) -e "if (!require('renv', quietly=TRUE)) install.packages('renv'); renv::restore(prompt = FALSE)"

# ------------ 2. Main workflow ------------------------------
all: output/arima_results.rds      # final artefact triggers full chain

output/unitroot_results.rds: scripts/02_unitroot.R data/pi_brasil_2002_2022.csv
	$(R) scripts/02_unitroot.R

output/arima_results.rds: scripts/03_arima_x.R output/unitroot_results.rds
	$(R) scripts/03_arima_x.R

# ------------ 3. Clean helper -------------------------------
clean:
	$(RM) output/*

.PHONY: all deps clean
