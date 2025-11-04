Step 1 – Filter, Impute & Log2 Transform (V3 – Final)
Overview

This R script performs strict preprocessing for the Mohan JR-vs-WT proteomics dataset.
It follows Dr. Mohan’s Rule B (confirmed via 11/2025 meeting) and applies a scientifically correct sequence of filtering, imputation, and transformation steps before differential expression analysis.

The logic is derived from both Mohan’s project guidance and Jen’s statistical preprocessing notes (UConn Bioinformatics Core).
It guarantees no 1-peptide proteins remain, ensuring accurate volcano, DE, and GO/KEGG analyses.

Pipeline Summary
Step	Operation	Description
1️⃣	QC Filtering	Removes all proteins with:
• PG.IsSingleHit == TRUE
• PG.NrOfStrippedSequencesIdentified <= 1
2️⃣	Imputation (ε = 0.01)	Replaces missing (NA) or zero (0) intensities with a small constant value (ε = 0.01) to retain exclusive proteins.
3️⃣	Log2 Transformation	Applies log2 scaling on imputed intensity values (PG.Quantity) to stabilize variance before normalization and statistical modeling.
4️⃣	Traceability	Generates three CSV outputs and a detailed README.txt for transparency.
Input File
Mohan_Grouped_ByProtein_Condition(Mohan_Grouped_ByProtein_Conditi)(in).csv


Located in:

D:/Project/Mohan/Dataset/11-3-2025/


This file is the grouped, long-format protein table exported from the DIA analysis software.

Outputs
File	Description
01_QC_filtered_V3.csv	After applying strict filtering (SingleHit + 1-peptide removal)
01_QC_imputed_raw_V3.csv	After imputing NA/0 values with ε = 0.01
01_log2_transformed_V3.csv	Final dataset with log2-transformed intensity values
README.txt	Text summary of operations for audit and traceability
Execution

Run the following inside R or RStudio:

# Load required libraries
library(dplyr)
library(readr)

# Source the script
source("Step1_Filter_Impute_Log2_V3.R")


All outputs will be automatically saved inside:

D:/Project/Mohan/Dataset/11-3-2025/01_transform/

Sanity Check Example

The script automatically performs a final verification and prints:

✅ QC filtering done. Rows removed: 1842
✅ Saved filtered dataset at: 01_QC_filtered_V3.csv
✅ Saved imputed dataset at: 01_QC_imputed_raw_V3.csv
✅ Saved log2-transformed dataset at: 01_log2_transformed_V3.csv

Running sanity check...
# A tibble: 1 × 5
  total_rows_final rows_removed_by_filter min_intensity mean_log2 min_log2
              5871                   1842          0.01     14.56     6.64
✅ Step 1 (V3) completed successfully.

Citation / Credit

Developed by Jahan Ghasemi (UConn School of Computing)
in collaboration with Dr. Royce Mohan (UConn Health) and Jen (UConn Bioinformatics Core)
November 2025
