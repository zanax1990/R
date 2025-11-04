# ---
# Step 2: Normalization (V5 - Long Format)
#
# This script applies normalization to the LONG-FORMAT data from Step 1.
#
# 1. (Jen's Rule): We apply normalization *after* log2 transform
#    to correct for technical differences between samples.
# 2. (Method): We use 'Median Centering' *per-sample*.
#    We group the data by the sample identifier (R.FileName) and
#    subtract each sample's *own* median from its values.
#
# This correctly centers all samples on zero for a fair comparison.
# ---
# --- 1. Load Required Packages ---
library(dplyr)
library(readr)

# --- 2. Define paths (V5) ---
base_dir <- "D:/Project/Mohan/Dataset/11-3-2025"
input_dir  <- file.path(base_dir, "01_transform")
output_dir <- file.path(base_dir, "02_normalize")

# Create output folder if it doesn’t exist
if (!dir.exists(output_dir)) dir.create(output_dir)

# Define input and output file names
input_file  <- file.path(input_dir, "01C_log2_transformed_V5.csv")
output_file <- file.path(output_dir, "02_log2_normalized_V5.csv")
readme_file <- file.path(output_dir, "README.txt")

# --- 3. Load data from Step 1 ---
cat("Loading data from Step 1:", input_file, "\n")
dat_log2 <- read_csv(input_file)

# --- 4. Apply Median-Centering (per-sample) ---
cat("Applying Median-Centering Normalization (per-sample)...\n")

# These columns are critical for grouping
sample_id_col <- "R.FileName" # This column identifies (WT1, WT2, etc)
intensity_col <- "log2_quantity" # This is the data we want to normalize

if (!sample_id_col %in% colnames(dat_log2)) {
  stop("FATAL ERROR: Cannot find sample ID column 'R.FileName'. Check your CSV.")
}

# Calculate the median for EACH sample
sample_medians <- dat_log2 %>%
  group_by(!!sym(sample_id_col)) %>%
  summarise(sample_median = median(!!sym(intensity_col), na.rm = TRUE))

cat("Calculated medians for each sample:\n")
print(sample_medians)

# Join the medians back to the main data and subtract
dat_normalized <- dat_log2 %>%
  left_join(sample_medians, by = sample_id_col) %>%
  mutate(
    log2_norm_quantity = !!sym(intensity_col) - sample_median
  ) %>%
  select(-sample_median) # Clean up the median column

cat("✅ Normalization complete.\n")

# --- 5. Save final Step 2 output ---
write_csv(dat_normalized, output_file)
cat("✅ Saved normalized file at:", output_file, "\n")

# --- 6. Write README.txt ---
readme_content <- "Mohan Project - Step 2: Normalization (V5)

Operation:
1. Loaded the clean, filtered, log2-transformed data from Step 1 (01C...V5.csv).
2. Applied PER-SAMPLE Median-Centering Normalization.
3. This process calculates the median log2-intensity for *each sample*
   (grouped by R.FileName) and subtracts it from all proteins in that sample.
4. The result is that all samples are now centered around zero,
   making them directly comparable for statistical analysis.

Input: 01C_log2_transformed_V5.csv
Output: 02_log2_normalized_V5.csv
"
writeLines(readme_content, readme_file)
cat("✅ README.txt (V5) saved at:", readme_file, "\n")

# --- 7. Sanity Check ---
cat("Running sanity check...\n")

# The median of *each sample* in the new column should be (close to) zero
final_check <- dat_normalized %>%
  group_by(!!sym(sample_id_col)) %>%
  summarise(
    new_median = median(log2_norm_quantity, na.rm = TRUE)
  )

cat("Final median check (all values should be ~0):\n")
print(final_check)
cat("✅ Step 2 (V5) completed successfully!\n")
