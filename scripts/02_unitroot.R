# -------------------------------------------------------------
# 02_unitroot.R
# -------------------------------------------------------------
# PURPOSE  : Perform four complementary unit‑root / stationarity
#            tests on Brazilian Industrial Production (IP):
#            • Augmented Dickey–Fuller (ADF)
#            • Kwiatkowski–Phillips–Schmidt–Shin (KPSS)
#            • Zivot–Andrews (ZA) break‑robust test
#            • Bai–Perron visual multiple‑break scan
#            Results are saved to a single RDS file for later
#            consumption by tables, figures or further scripts.
# AUTHOR   : Carlos Eduardo Nóbrega
# CREATED  : 2025‑07‑15
# LANGUAGE : R 4.5.1 (ucrt, 64‑bit)
# -------------------------------------------------------------
# PRECONDITION : scripts/00_setup.R must have verified packages,
#                data integrity and set the global seed.
# -------------------------------------------------------------

# 0. House‑keeping -----------------------------------------------------------
source("scripts/00_setup.R")   # load libraries, verify checksum, seed 123

# 1. Import data -------------------------------------------------------------
message("Reading raw CSV …")
ip_raw <- readr::read_csv("data/pi_brasil_2002_2022.csv",
                         show_col_types = FALSE)

# Convert to yearmon and then to ts ------------------------------------------------
ip_raw$time <- zoo::as.yearmon(ip_raw$data, "%Y-%m")
# Keep only the numeric series in the same order
ip_ts <- stats::ts(ip_raw$valor,
                   start = c(2002, 1), frequency = 12)

# 2. Run unit‑root tests ------------------------------------------------------
message("Running ADF (drift, 12 lags) …")
adf_level <- urca::ur.df(ip_ts, type = "drift", lags = 12)

message("Running KPSS (trend) …")
kpss_level <- tseries::kpss.test(ip_ts)

message("Running Zivot–Andrews (both break types) …")
za_level <- urca::ur.za(ip_ts, model = "both", lag = 12)

message("Detecting breakpoints (Bai–Perron) …")
# Visual scan with constant‑mean model
bp_scan <- strucchange::breakpoints(ip_ts ~ 1)

# 3. Compile tidy output object ----------------------------------------------
unitroot_results <- list(
  adf   = adf_level,
  kpss  = kpss_level,
  za    = za_level,
  bpare = bp_scan,
  meta  = list(dataset = "pi_brasil_2002_2022.csv",
               seed    = 123,
               timestamp = Sys.time())
)

# Ensure output folder exists
if (!dir.exists("output")) dir.create("output")

saveRDS(unitroot_results, file = "output/unitroot_results.rds")
message("All unit‑root tests finished ✔  Results stored in output/unitroot_results.rds")
