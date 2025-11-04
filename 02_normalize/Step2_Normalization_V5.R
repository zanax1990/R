Step 2 — Normalization (V5 – Long Format)
Overview

This step performs per-sample median-centering normalization on the long-format proteomics data output from Step 1.
It corrects for technical variation between samples after the log₂ transform and ensures all samples are centered on zero for fair downstream comparison.

Logic & Rules

Jen’s Rule: Normalize after log₂ transform.

Method: Group by R.FileName (sample identifier) and subtract each sample’s own median from its log₂ intensity values (log2_quantity).

Outcome: Every sample’s median intensity ≈ 0 — enabling direct comparison across all JR/WT replicates.

Operations
Step	Action
1	Load clean, log₂-transformed CSV from Step 1 (01C_log2_transformed_V5.csv)
2	Group data by R.FileName
3	Compute median of log2_quantity for each sample
4	Subtract the median from all protein values of that sample
5	Save the normalized file and generate a README.txt log
Input / Output
File	Description
Input	01C_log2_transformed_V5.csv (output from Step 1)
Output	02_log2_normalized_V5.csv
README	Auto-generated summary of normalization logic
Notes

The new column log2_norm_quantity represents the normalized intensity.

Each sample’s post-normalization median should be ~0 (check printed summary).

Folders used:

01_transform/ → input source

02_normalize/ → output destination

Validation

A sanity check is run automatically:

Final median check (all values should be ~0):


If all medians print near 0, normalization succeeded.
