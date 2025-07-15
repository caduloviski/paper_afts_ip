# -------------------------------------------------------------
# 01_download_data.R
# -------------------------------------------------------------
# PURPOSE  : Ensure that the raw Industrial Production (IP)
#            CSV file is present in the local `data/` directory.
#            If the file does not exist **or** fails the checksum
#            test, the script downloads it from IBGE’s official
#            repository and re‑verifies integrity.
# AUTHOR   : Carlos Eduardo Nóbrega
# CREATED  : 2025‑07‑15
# LANGUAGE : R 4.5.1 (ucrt, 64‑bit)
# -------------------------------------------------------------
# USAGE    : Run standalone or let the Makefile invoke it.
#            The script is idempotent — safe to run multiple
#            times; it only downloads when necessary.
# -------------------------------------------------------------

# ------------------------------
# 1. Parameters
# ------------------------------
url_ibge   <- "https://sidra.ibge.gov.br/tabela/3653"   # <-- replace with real URL
file_path  <- "data/pi_brasil_2002_2022.csv"
expected_sha256 <- "88346ace0d2e78d9223342e5a56daa0f3948313d01d9960ef10455eda74ee507"

download_if_needed <- function(url, dest) {
  if (!dir.exists(dirname(dest))) dir.create(dirname(dest), recursive = TRUE)
  message("Downloading raw data from: ", url)
  utils::download.file(url, destfile = dest, mode = "wb", quiet = TRUE)
}

verify_checksum <- function(path, target_hash) {
  if (!file.exists(path)) return(FALSE)
  actual <- tools::sha256sum(path)[[1]]
  identical(actual, target_hash)
}

# ------------------------------
# 2. Main logic
# ------------------------------
if (verify_checksum(file_path, expected_sha256)) {
  message("Checksum OK — raw CSV already present ✔")
} else {
  if (file.exists(file_path)) {
    warning("Existing file failed checksum. Re‑downloading…")
  }
  download_if_needed(url_ibge, file_path)
  if (!verify_checksum(file_path, expected_sha256)) {
    stop("Download completed but checksum still mismatches. Aborting.")
  } else {
    message("Download complete and checksum verified ✔")
  }
}

# ------------------------------
# 3. Session info (helps debugging)
# ------------------------------
message("01_download_data.R finished successfully.")