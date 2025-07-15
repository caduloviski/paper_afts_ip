# -------------------------------------------------------------
# 00_setup.R
# -------------------------------------------------------------
# PURPOSE  : Load required packages, restore the renv snapshot,
#            verify file checksums, and set the global PRNG seed.
# AUTHOR   : Carlos Eduardo Nóbrega
# CREATED  : 2025-07-15
# LANGUAGE : R 4.5.1 (ucrt, 64-bit)
# -------------------------------------------------------------
# This script is sourced automatically by the Makefile target
# `make all` before any analytical step.  It is *idempotent*:
# running it multiple times changes nothing in the project.
# -------------------------------------------------------------

## 1. Restore renv environment (if the user opted for renv)
if (requireNamespace("renv", quietly = TRUE) &&
    file.exists("renv.lock")) {
  renv::restore(prompt = FALSE)
}

## 2. Load libraries ----------------------------------------------------------
suppressPackageStartupMessages({
  library(readr)       # fast CSV import
  library(zoo)         # yearmon class
  library(urca)        # ADF, Zivot-Andrews, Perron
  library(tseries)     # KPSS
  library(strucchange) # Bai–Perron breakpoints
})

## 3. Verify the checksum of the raw CSV -------------------------------------
expected_hash <- "88346ace0d2e78d9223342e5a56daa0f3948313d01d9960ef10455eda74ee507"
file_path     <- "data/pi_brasil_2002_2022.csv"

actual_hash <- tools::sha256sum(file_path)[[1]]
if (!identical(actual_hash, expected_hash)) {
  stop(sprintf(
    "Checksum mismatch for %s.\nExpected: %s\nActual  : %s",
    file_path, expected_hash, actual_hash
  ))
}

## 4. Set deterministic random-number seed -----------------------------------
set.seed(123)
message("Environment ready — checks passed ✔")
