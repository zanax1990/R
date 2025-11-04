# ---
# Step 1 (V5): Impute THEN Filter (FINAL - Bulletproof Logic)
#
# This script applies the *safest* interpretation of Mohan's conflicting rules.
# The order is critical: Impute *before* Filtering.
#
# 1. (Mohan's Rule A - Impute FIRST): We find *all* NA/0 intensity values
#    and replace them with 0.01. This ensures exclusives are captured.
# 2. (Mohan's Rule B - Filter SECOND): *After* imputation, we apply the
#    STRICTEST filter to DELETE all 1-peptide proteins based on ALL
#    three known 1-peptide columns.
# 3. (Transform): We log2-transform the final, clean data.
#
# This version (V5) is bulletproof to any future complaints about 1-peptides.
# ---

# --- 1. Load Required Packages ---
library(dplyr)
library(readr)

# --- 2. Define paths (V5) ---
base_dir <- "D:/Project/Mohan/Dataset/11-3-2025"
input_file_name <- "Mohan_Grouped_ByProtein_Condition(Mohan_Grouped_ByProtein_Conditi)(in).csv"
input_file_path <- file.path(base_dir, input_file_name)

dir_out <- file.path(base_dir, "01_transform")
if (!dir.exists(dir_out)) dir.create(dir_out)

output_imputed  <- file.path(dir_out, "01A_imputed_V5.csv") # Intermediate
output_filtered <- file.path(dir_out, "01B_filtered_V5.csv")  # Intermediate
output_log2     <- file.path(dir_out, "01C_log2_transformed_V5.csv") # Final
readme_file     <- file.path(dir_out, "README.txt")

# --- 3. Load data ---
cat("Loading data...\n")
dat <- read_csv(input_file_path)
original_row_count <- nrow(dat)

# --- 4. Imputation FIRST (Mohan’s ε rule) ---
epsilon <- 0.01
cat("Step 4: Applying ε = 0.01 to NA/0 intensity values (BEFORE filtering)...\n")

dat_imputed <- dat %>%
  mutate(
    # Use PG.Quantity as the primary intensity column
    PG.Quantity = ifelse(is.na(PG.Quantity) | PG.Quantity == 0, epsilon, PG.Quantity)
  )

write_csv(dat_imputed, output_imputed)
cat("✅ Saved imputed dataset at:", output_imputed, "\n")

# --- 5. QC Filtering SECOND (Mohan's Rule B - Bulletproof) ---
cat("Step 5: Applying STRICT QC filter (AFTER imputation)...\n")

dat_filtered <- dat_imputed %>%
  filter(
    # Rule 1: The official flag
    (PG.IsSingleHit == FALSE | is.na(PG.IsSingleHit)),
    
    # Rule 2: The column Mohan was *actually* looking at
    (PG.NrOfStrippedSequencesIdentified > 1 | is.na(PG.NrOfStrippedSequencesIdentified)),
    
    # Rule 3: The other 1-peptide column (just in case)
    (PG.RunEvidenceCount > 1 | is.na(PG.RunEvidenceCount))
  )

rows_removed <- original_row_count - nrow(dat_filtered)
cat("✅ QC filtering done. Total rows removed:", rows_removed, "\n")

write_csv(dat_filtered, output_filtered)
cat("✅ Saved filtered dataset at:", output_filtered, "\n")

# --- 6. Log2 Transformation ---
cat("Step 6: Applying log2 transformation...\n")

dat_log2 <- dat_filtered %>%
  mutate(log2_quantity = log2(PG.Quantity)) # Use the imputed/filtered PG.Quantity

write_csv(dat_log2, output_log2)
cat("✅ Saved log2-transformed dataset at:", output_log2, "\n")

# --- 7. README for traceability (V5) ---
readme_content <- "Mohan Project - Step 1: Impute THEN Filter (V5 - Final)

Operations:
1. Imputation FIRST: Applied ε = 0.01 to replace NA/0 intensities.
   (Saved in 01A_imputed_V5.csv)
2. Filtering SECOND: Applied strict 1-peptide filter based on THREE columns:
   - PG.IsSingleHit (Removed FALSE)
   - PG.NrOfStrippedSequencesIdentified (Removed <= 1)
   - PG.RunEvidenceCount (Removed <= 1)
   (Saved in 01B_filtered_V5.csv)
3. Log2 Transform: Performed log2 transformation on final clean data.
   (Saved in 01C_log2_transformed_V5.csv)

This V5 order (Impute -> Filter) is the safest interpretation
of all combined feedback.
"
writeLines(readme_content, readme_file)
cat("✅ README.txt (V5) saved at:", readme_file, "\n")

# --- 8. Sanity Check ---
cat("Step 8: Running final sanity check...\n")

summary_check <- dat_log2 %>%
  summarise(
    total_rows_final = n(),
    rows_removed_by_filter = rows_removed,
    min_intensity    = min(PG.Quantity, na.rm = TRUE), # Should be 0.01 if any exclusives survived
    mean_log2        = mean(log2_quantity, na.rm = TRUE),
    min_log2         = min(log2_quantity, na.rm = TRUE) # Should be -6.64 if any exclusives survived
  )

print(summary_check)
cat("✅ Step 1 (V5) completed successfully.\n")
