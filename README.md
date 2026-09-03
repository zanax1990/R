# DIA Proteomics Preprocessing in R

This repository contains the first two stages of a long-format DIA proteomics preprocessing workflow:

1. replace missing or zero protein quantities with a small positive value;
2. filter single-hit and low-evidence rows;
3. apply a log2 transformation;
4. median-center each sample after transformation.

The scripts were developed for a specific research dataset. The data are not included.

## Workflow

### Step 1: filtering, imputation, and transformation

`Step1_Filter_Impute_Log2_V3.R` reads the grouped protein report, replaces missing or zero `PG.Quantity` values with `0.01`, applies three evidence filters, and writes intermediate and transformed CSV files.

The filtering logic uses:

- `PG.IsSingleHit`
- `PG.NrOfStrippedSequencesIdentified`
- `PG.RunEvidenceCount`

### Step 2: per-sample normalization

`02_normalize/Step2_Normalization_V5.R` groups rows by `R.FileName`, computes the median `log2_quantity` for each sample, and subtracts that median to produce `log2_norm_quantity`.

## Requirements

- R
- `dplyr`
- `readr`

Install the packages from an R session:

```r
install.packages(c("dplyr", "readr"))
```

## Running the pipeline

The scripts currently use a project-specific `base_dir`. Update that value before running them, then execute the stages in order:

```r
source("Step1_Filter_Impute_Log2_V3.R")
source("02_normalize/Step2_Normalization_V5.R")
```

Expected input columns include `PG.Quantity`, `PG.IsSingleHit`, `PG.NrOfStrippedSequencesIdentified`, `PG.RunEvidenceCount`, and `R.FileName`.

## Outputs

Step 1 writes imputed, filtered, and log2-transformed CSV files. Step 2 writes the median-centered dataset. The scripts also print row counts and normalization checks to the console.

## Limitations

The imputation value and filtering rules are specific to the original analysis protocol. They should not be treated as general defaults for other DIA datasets. File paths and filenames are configured directly in the scripts, and the repository does not include sample data, automated tests, or an environment lockfile.
