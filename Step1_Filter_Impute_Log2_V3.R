suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

script_path <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
script_dir <- if (is.na(script_path)) getwd() else dirname(normalizePath(script_path))
source(file.path(script_dir, "R", "preprocessing.R"))

parse_arguments <- function(args) {
  values <- list(input = NULL, output_dir = "01_transform", epsilon = 0.01)
  index <- 1
  while (index <= length(args)) {
    flag <- args[[index]]
    if (flag == "--help") {
      cat("Usage: Rscript Step1_Filter_Impute_Log2_V3.R --input FILE [--output-dir DIR] [--epsilon VALUE]\n")
      quit(status = 0)
    }
    if (!flag %in% c("--input", "--output-dir", "--epsilon") || index == length(args)) {
      stop(paste("Invalid or incomplete argument:", flag), call. = FALSE)
    }
    key <- sub("^--", "", flag)
    key <- gsub("-", "_", key)
    values[[key]] <- args[[index + 1]]
    index <- index + 2
  }
  if (is.null(values$input)) {
    stop("--input is required", call. = FALSE)
  }
  values$epsilon <- as.numeric(values$epsilon)
  values
}

arguments <- parse_arguments(commandArgs(trailingOnly = TRUE))
input_path <- normalizePath(arguments$input, mustWork = TRUE)
output_dir <- arguments$output_dir
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

data <- read_csv(input_path, show_col_types = FALSE)
result <- impute_filter_log2(data, epsilon = arguments$epsilon)

write_csv(result$imputed, file.path(output_dir, "01A_imputed_V5.csv"))
write_csv(result$filtered, file.path(output_dir, "01B_filtered_V5.csv"))
write_csv(result$transformed, file.path(output_dir, "01C_log2_transformed_V5.csv"))

trace <- c(
  "DIA proteomics preprocessing: step 1",
  paste("Input:", input_path),
  paste("Epsilon:", arguments$epsilon),
  paste("Input rows:", nrow(data)),
  paste("Rows after filtering:", nrow(result$filtered)),
  "Order: replace missing/zero quantities, filter evidence, apply log2"
)
writeLines(trace, file.path(output_dir, "README.txt"))
cat("Step 1 complete:", nrow(result$transformed), "rows written to", output_dir, "\n")
