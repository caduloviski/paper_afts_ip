# -------------------------------------------------------------
# 03_arima_x.R
# -------------------------------------------------------------
# PURPOSE  : Estimate a parsimonious ARIMA(1,1,1) model
#            augmented with three level‑shift dummies that
#            correspond to the break dates found in 02_unitroot.R
#            (Dec‑2004, Sep‑2009, Mar‑2015).  Diagnostics and
#            plots are saved to the `output/` folder.
# AUTHOR   : Carlos Eduardo Nóbrega
# CREATED  : 2025-07-15
# LANGUAGE : R 4.5.1 (ucrt, 64-bit)
# -------------------------------------------------------------
# DEPENDS  : scripts/00_setup.R  (environment, checksum, seed)
#            scripts/02_unitroot.R (breakpoint dates)
# -------------------------------------------------------------

# 0. House‑keeping -----------------------------------------------------------
source("scripts/00_setup.R")

if (!requireNamespace("forecast", quietly = TRUE)) {
  install.packages("forecast", repos = "https://cloud.r-project.org")
  library(forecast)
}

# 1. Import series -----------------------------------------------------------
ip_raw <- readr::read_csv("data/pi_brasil_2002_2022.csv", show_col_types = FALSE)
ip_ts  <- ts(ip_raw$valor, start = c(2002, 1), frequency = 12)

# 2. Build dummy regressors --------------------------------------------------
# Breaks: 2004-12, 2009-09, 2015-03
n <- length(ip_ts)

d04 <- rep(0, n); d09 <- d04; d15 <- d04

# Helper to convert year, month to position in ts
pos <- function(y, m) (y - 2002) * 12 + m

d04[pos(2004, 12):n] <- 1

d09[pos(2009,  9):n] <- 1

d15[pos(2015,  3):n] <- 1

xreg <- cbind(d04 = d04, d09 = d09, d15 = d15)

# 3. Estimate ARIMA(1,1,1) with X‑regs --------------------------------------
model <- forecast::Arima(ip_ts, order = c(1, 1, 1), xreg = xreg)
print(summary(model))

# 4. Diagnostics -------------------------------------------------------------
if (!dir.exists("output")) dir.create("output")

# Residual ACF plot
png("output/acf_residuals.png", width = 800, height = 600)
forecast::ggAcf(residuals(model)) + ggplot2::ggtitle("ACF of ARIMA(1,1,1)-X Residuals")
graphics.off()

# Ljung–Box p‑value at lag 12
lb <- Box.test(residuals(model), lag = 12, type = "Ljung")
cat(sprintf("Ljung–Box Q(12) p-value: %.3f\n", lb$p.value))

# Save model object and diagnostics
saveRDS(list(model = model, ljung_box = lb), file = "output/arima_results.rds")
message("ARIMA‑X estimation completed ✔  Output: output/arima_results.rds")
