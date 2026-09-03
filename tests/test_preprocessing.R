suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})
source("R/preprocessing.R")

data <- read_csv("examples/synthetic_input.csv", show_col_types = FALSE)
result <- impute_filter_log2(data)
stopifnot(nrow(result$imputed) == 5)
stopifnot(nrow(result$filtered) == 4)
stopifnot(all(is.finite(result$transformed$log2_quantity)))
stopifnot(sum(result$imputed$PG.Quantity == 0.01) == 2)

normalized <- median_center_by_sample(result$transformed)
medians <- normalized |>
  group_by(R.FileName) |>
  summarise(value = median(log2_norm_quantity), .groups = "drop")
stopifnot(all(abs(medians$value) < 1e-10))

expected <- read_csv("examples/expected_normalized.csv", show_col_types = FALSE)
observed <- normalized |>
  select(PG.ProteinAccessions, R.FileName, log2_norm_quantity) |>
  arrange(PG.ProteinAccessions)
expected <- expected |> arrange(PG.ProteinAccessions)
stopifnot(all(observed$PG.ProteinAccessions == expected$PG.ProteinAccessions))
stopifnot(max(abs(observed$log2_norm_quantity - expected$log2_norm_quantity)) < 1e-8)

invalid <- data
invalid$PG.Quantity[[1]] <- -1
stopifnot(inherits(try(impute_filter_log2(invalid), silent = TRUE), "try-error"))
cat("All preprocessing tests passed.\n")
