# DIA Proteomics Preprocessing in R

This repository provides a two-stage preprocessing workflow for long-format DIA proteomics reports. It replaces missing or zero protein quantities with a configurable small positive value, filters low-evidence rows, applies a log2 transformation, and median-centers each sample.

The original research data are not included. A small synthetic input is provided to test the complete workflow.

## Workflow

1. Validate the required report columns.
2. Replace missing or zero `PG.Quantity` values with `epsilon` (default `0.01`).
3. Remove single-hit and low-evidence rows using three report fields.
4. Calculate `log2_quantity`.
5. Group by `R.FileName` and subtract the per-sample median to obtain `log2_norm_quantity`.

The imputation value and evidence rules reproduce the original analysis protocol; they are not intended as universal DIA preprocessing defaults.

## Requirements

- R 4.1 or newer
- `dplyr`
- `readr`

Install the dependencies from an R session:

```r
install.packages(c("dplyr", "readr"))
```

## Run the pipeline

Run both stages from the repository root. All paths are supplied through command-line arguments.

```bash
Rscript Step1_Filter_Impute_Log2_V3.R \
  --input path/to/grouped_protein_report.csv \
  --output-dir results/01_transform \
  --epsilon 0.01

Rscript 02_normalize/Step2_Normalization_V5.R \
  --input results/01_transform/01C_log2_transformed_V5.csv \
  --output-dir results/02_normalize
```

Expected input columns are:

- `PG.Quantity`
- `PG.IsSingleHit`
- `PG.NrOfStrippedSequencesIdentified`
- `PG.RunEvidenceCount`
- `R.FileName`

## Synthetic example

```bash
Rscript Step1_Filter_Impute_Log2_V3.R \
  --input examples/synthetic_input.csv \
  --output-dir build/01_transform

Rscript 02_normalize/Step2_Normalization_V5.R \
  --input build/01_transform/01C_log2_transformed_V5.csv \
  --output-dir build/02_normalize
```

The expected normalized values are recorded in `examples/expected_normalized.csv`. These values are synthetic checks, not research results.

## Outputs

Step 1 writes the imputed, filtered, and log2-transformed tables. Step 2 writes the normalized table and a per-sample median check. Each stage also records a short text trace in its output directory.

## Tests

```bash
Rscript tests/test_preprocessing.R
```

The tests cover imputation, evidence filtering, finite transformed values, median centering, the synthetic expected output, and rejection of negative quantities. GitHub Actions runs the same tests and the end-to-end synthetic example.

## Repository structure

```text
.
├── R/preprocessing.R                    # validated preprocessing functions
├── Step1_Filter_Impute_Log2_V3.R        # stage 1 command-line entry point
├── 02_normalize/Step2_Normalization_V5.R# stage 2 command-line entry point
├── examples/                            # synthetic input and expected values
├── tests/                               # lightweight checks
└── .github/workflows/                   # continuous integration
```

## Limitations

This repository covers preprocessing only. It does not perform batch correction, differential testing, multiple-testing correction, or pathway analysis. Filtering thresholds should be reviewed for each experimental design.
