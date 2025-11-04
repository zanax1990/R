# ---
# Step 1 (V3): Filter, Impute & Transform (FINAL - Strict Filtering)
#
# This script applies the *strictest possible interpretation* of Mohan's rules.
#
# 1. (Mohan's Rule B - Literal): We DELETE rows where PG.IsSingleHit == TRUE.
# 2. (Mohan's Rule B - Implied): We ALSO DELETE rows where
#    PG.NrOfStrippedSequencesIdentified <= 1.
# 3. (Impute): We keep exclusive proteins (NA/0) by setting intensity to 0.01.
# 4. (Transform): We log2-transform the data *after* filtering/imputation.
#
# This version ensures NO 1-peptide proteins remain, addressing all feedback.
# ---

# --- 1. Load Required Packages ---
library(dplyr)
library(readr)

# --- 2. Define paths ---
base_dir <- "D:/Project/Mohan/Dataset/11-3-2025"
input_file_name <- "Mohan_Grouped_ByProtein_Condition(Mohan_Grouped_ByProtein_Conditi)(in).csv"
input_file_path <- file.path(base_dir, input_file_name)

dir_out <- file.path(base_dir, "01_transform")
if (!dir.exists(dir_out)) dir.create(dir_out)

output_filtered <- file.path(dir_out, "01_QC_filtered_V3.csv")
output_imputed  <- file.path(dir_out, "01_QC_imputed_raw_V3.csv")
output_log2     <- file.path(dir_out, "01_log2_transformed_V3.csv")
readme_file     <- file.path(dir_out, "README.txt")

# --- 3. Load data ---
cat("Loading data...\n")
dat <- read_csv(input_file_path)
cat("Columns detected:\n"); print(colnames(dat))
original_row_count <- nrow(dat)

# --- 4. QC Filtering (THE CRITICAL FIX from ChatGPT) ---
cat("Applying STRICT QC filter: removing SingleHits AND 1-peptide counts...\n")

dat_filtered <- dat %>%
  filter(
    (PG.IsSingleHit == FALSE | is.na(PG.IsSingleHit)),
    (PG.NrOfStrippedSequencesIdentified > 1 | is.na(PG.NrOfStrippedSequencesIdentified))
  )

rows_removed <- original_row_count - nrow(dat_filtered)
cat("✅ QC filtering done. Rows removed:", rows_removed, "\n")

write_csv(dat_filtered, output_filtered)
cat("✅ Saved filtered dataset at:", output_filtered, "\n")

# --- 5. Imputation (Mohan’s ε rule) ---
epsilon <- 0.01
cat("Applying ε = 0.01 to remaining NA/0 intensity values...\n")

dat_imputed <- dat_filtered %>%
  mutate(PG.Quantity = ifelse(is.na(PG.Quantity) | PG.Quantity == 0, epsilon, PG.Quantity))

write_csv(dat_imputed, output_imputed)
cat("✅ Saved imputed dataset at:", output_imputed, "\n")

# --- 6. Log2 Transformation ---
cat("Applying log2 transformation...\n")

dat_log2 <- dat_imputed %>%
  mutate(log2_quantity = log2(PG.Quantity))

write_csv(dat_log2, output_log2)
cat("✅ Saved log2-transformed dataset at:", output_log2, "\n")

# --- 7. README for traceability (V3) ---
readme_content <- "Mohan Project - Step 1: Transform & Impute (V3 - Final)

Operations:
1. STRICT FILTERING APPLIED:
   - Removed all SingleHit proteins (PG.IsSingleHit == TRUE).
   - Removed all proteins with PG.NrOfStrippedSequencesIdentified <= 1.
2. Applied ε = 0.01 to replace NA or zero intensities (to retain exclusives).
3. Performed log2 transformation after imputation.

This version (V3) ensures all 1-peptide proteins are removed, per
Mohan's combined feedback.
"
writeLines(readme_content, readme_file)
cat("✅ README.txt (V3) saved at:", readme_file, "\n")

# --- 8. Sanity Check ---
cat("Running sanity check...\n")

summary_check <- dat_log2 %>%
  summarise(
    total_rows_final = n(),
    rows_removed_by_filter = rows_removed,
    min_intensity    = min(PG.Quantity, na.rm = TRUE),
    mean_log2        = mean(log2_quantity, na.rm = TRUE),
    min_log2         = min(log2_quantity, na.rm = TRUE)
  )

print(summary_check)
cat("✅ Step 1 (V3) completed successfully.\n")
