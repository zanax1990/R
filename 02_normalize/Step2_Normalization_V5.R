suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

script_path <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
script_dir <- if (is.na(script_path)) getwd() else dirname(normalizePath(script_path))
repository_root <- normalizePath(file.path(script_dir, ".."), mustWork = TRUE)
source(file.path(repository_root, "R", "preprocessing.R"))

parse_arguments <- function(args) {
  values <- list(input = NULL, output_dir = "02_normalize")
  index <- 1
  while (index <= length(args)) {
    flag <- args[[index]]
    if (flag == "--help") {
      cat("Usage: Rscript 02_normalize/Step2_Normalization_V5.R --input FILE [--output-dir DIR]\n")
      quit(status = 0)
    }
    if (!flag %in% c("--input", "--output-dir") || index == length(args)) {
      stop(paste("Invalid or incomplete argument:", flag), call. = FALSE)
    }
    key <- gsub("-", "_", sub("^--", "", flag))
    values[[key]] <- args[[index + 1]]
    index <- index + 2
  }
  if (is.null(values$input)) {
    stop("--input is required", call. = FALSE)
  }
  values
}

arguments <- parse_arguments(commandArgs(trailingOnly = TRUE))
input_path <- normalizePath(arguments$input, mustWork = TRUE)
output_dir <- arguments$output_dir
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

data <- read_csv(input_path, show_col_types = FALSE)
normalized <- median_center_by_sample(data)
output_path <- file.path(output_dir, "02_log2_normalized_V5.csv")
write_csv(normalized, output_path)

sample_check <- normalized |>
  group_by(R.FileName) |>
  summarise(median = median(log2_norm_quantity, na.rm = TRUE), .groups = "drop")
write_csv(sample_check, file.path(output_dir, "normalization_check.csv"))
writeLines(
  c(
    "DIA proteomics preprocessing: step 2",
    paste("Input:", input_path),
    "Method: per-sample median centering after log2 transformation",
    paste("Output:", output_path)
  ),
  file.path(output_dir, "README.txt")
)
cat("Step 2 complete:", nrow(normalized), "rows written to", output_path, "\n")
