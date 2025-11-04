
 Step 1 (Data Cleaning & Transformation)
Files: 01A_imputed_V5.csv, 01B_filtered_V5.csv, 01C_log2_transformed_V5.csv
Summary for Dr. Mohan: I completed Step 1 of the JR vs WT proteomics pipeline. All NA and 0 intensity values in PG.Quantity were replaced with 0.01 (ε). Then strict QC filtering was applied to remove all proteins where PG.IsSingleHit == TRUE, PG.NrOfStrippedSequencesIdentified <= 1, or PG.RunEvidenceCount <= 1. Finally, log2 transformation was added as log2_quantity = log2(PG.Quantity). QC check confirms:
No NA or 0 values remain.
All 1-peptide and SingleHit proteins removed.
log2_quantity is correctly computed. Step 1 (V5) is verified and complete.
