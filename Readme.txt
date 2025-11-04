Step 1 (V5): Impute → Filter → Log₂ Transform

Mohan Proteomics Analysis Pipeline

Overview

This script implements the final, bulletproof logic for Step 1 of the JR vs WT proteomics analysis, following Dr. Mohan’s most recent interpretation of the imputation and filtering rules.

The order of operations is critical:
Impute first → Filter second → Log₂ transform last

Processing Steps
1. Imputation (ε = 0.01)

All NA or 0 values in PG.Quantity are replaced with 0.01 to preserve exclusive proteins.

Output: 01A_imputed_V5.csv

2. Strict QC Filtering (1-Peptide Removal)

After imputation, three independent 1-peptide filters are applied:

Column	Condition	Action
PG.IsSingleHit	== TRUE	Remove row
PG.NrOfStrippedSequencesIdentified	<= 1	Remove row
PG.RunEvidenceCount	<= 1	Remove row

Output: 01B_filtered_V5.csv

Metric Logged: Rows removed from original dataset.

3. Log₂ Transformation

PG.Quantity is log₂-transformed to log2_quantity for downstream statistical analysis.

Output: 01C_log2_transformed_V5.csv

Outputs and Artifacts
File	Description
01A_imputed_V5.csv	After ε-imputation (NA → 0.01)
01B_filtered_V5.csv	After strict 1-peptide removal
01C_log2_transformed_V5.csv	Final log₂-transformed data
README.txt	Traceability summary for V5
Console summary	Row counts + log₂ distribution
Key Design Principles

Impute before filtering to avoid losing exclusive proteins.

Filter after imputation using all known 1-peptide columns.

Log₂ transform only the final clean quantities.

Fully traceable: Each stage outputs a CSV + README.

Citation Note

This V5 implementation follows Dr. Mohan’s confirmed rule set (“Remove all SingleHit proteins”) and was reviewed in the 2025-11-03 meeting.
