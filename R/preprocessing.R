required_step1_columns <- c(
  "PG.Quantity",
  "PG.IsSingleHit",
  "PG.NrOfStrippedSequencesIdentified",
  "PG.RunEvidenceCount"
)

validate_columns <- function(data, required_columns) {
  missing_columns <- setdiff(required_columns, colnames(data))
  if (length(missing_columns) > 0) {
    stop(
      paste("Missing required columns:", paste(missing_columns, collapse = ", ")),
      call. = FALSE
    )
  }
}

impute_filter_log2 <- function(data, epsilon = 0.01) {
  validate_columns(data, required_step1_columns)
  if (!is.numeric(epsilon) || length(epsilon) != 1 || !is.finite(epsilon) || epsilon <= 0) {
    stop("epsilon must be one positive finite number", call. = FALSE)
  }
  negative_quantity <- !is.na(data$PG.Quantity) & data$PG.Quantity < 0
  if (any(negative_quantity)) {
    stop("PG.Quantity contains negative values", call. = FALSE)
  }

  imputed <- data |>
    dplyr::mutate(
      PG.Quantity = dplyr::if_else(
        is.na(PG.Quantity) | PG.Quantity == 0,
        epsilon,
        as.numeric(PG.Quantity)
      )
    )

  filtered <- imputed |>
    dplyr::filter(
      PG.IsSingleHit == FALSE | is.na(PG.IsSingleHit),
      PG.NrOfStrippedSequencesIdentified > 1 |
        is.na(PG.NrOfStrippedSequencesIdentified),
      PG.RunEvidenceCount > 1 | is.na(PG.RunEvidenceCount)
    )

  transformed <- filtered |>
    dplyr::mutate(log2_quantity = log2(PG.Quantity))

  list(imputed = imputed, filtered = filtered, transformed = transformed)
}

median_center_by_sample <- function(
    data,
    sample_column = "R.FileName",
    intensity_column = "log2_quantity") {
  validate_columns(data, c(sample_column, intensity_column))
  if (any(is.na(data[[sample_column]]))) {
    stop("Sample identifiers must not be missing", call. = FALSE)
  }

  sample_medians <- data |>
    dplyr::group_by(.data[[sample_column]]) |>
    dplyr::summarise(
      sample_median = stats::median(.data[[intensity_column]], na.rm = TRUE),
      .groups = "drop"
    )

  if (any(!is.finite(sample_medians$sample_median))) {
    stop("At least one sample has no finite intensity values", call. = FALSE)
  }

  data |>
    dplyr::left_join(sample_medians, by = sample_column) |>
    dplyr::mutate(
      log2_norm_quantity = .data[[intensity_column]] - sample_median
    ) |>
    dplyr::select(-sample_median)
}
