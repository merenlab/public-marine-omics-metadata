# script to only keep metagenomics and paired end data

# Load necessary package
library(dplyr)

# Define functions to filter dataframe based on library_strategy and library_layout
filter_WGS <- function(df) {
  df %>% filter(library_strategy == "WGS")
}

filter_PAIRED <- function(df) {
  df %>% filter(library_layout == "PAIRED")
}

# List of dataframes
dataframes <- list(
  BATS_meta_dataframe,
  HOT1_meta_dataframe,
  TARA_meta_dataframe,
  OSD_meta_dataframe,
  BGS_meta_dataframe,
  BGT_meta_dataframe,
  MAL_meta_dataframe,
  HOT2_meta_dataframe,
  HOT3_meta_dataframe,
  WCO_meta_dataframe
)

# Corresponding names for the filtered dataframes
filtered_names <- c(
  "BATS_meta_dataframe_WGS_PAIR",
  "HOT1_meta_dataframe_WGS_PAIR",
  "TARA_meta_dataframe_WGS_PAIR",
  "OSD_meta_dataframe_WGS_PAIR",
  "BGS_meta_dataframe_WGS_PAIR",
  "BGT_meta_dataframe_WGS_PAIR",
  "MAL_meta_dataframe_WGS_PAIR",
  "HOT2_meta_dataframe_WGS_PAIR",
  "HOT3_meta_dataframe_WGS_PAIR",
  "WCO_meta_dataframe_WGS_PAIR"
)

# Initialize lists to store the number of samples for each step
initial_samples_count <- list()
samples_count_WGS <- list()
samples_count_PAIRED <- list()

# Apply the filter functions and store the number of samples
for (i in seq_along(dataframes)) {
  # Initial number of samples
  initial_samples_count[[filtered_names[i]]] <- nrow(dataframes[[i]])
  
  # Filter for WGS
  wgs_filtered_df <- filter_WGS(dataframes[[i]])
  samples_count_WGS[[filtered_names[i]]] <- nrow(wgs_filtered_df)
  
  # Further filter for PAIRED
  paired_filtered_df <- filter_PAIRED(wgs_filtered_df)
  assign(filtered_names[i], paired_filtered_df)
  samples_count_PAIRED[[filtered_names[i]]] <- nrow(paired_filtered_df)
}

# Print the number of samples for each step
for (name in filtered_names) {
  cat(name, "had", initial_samples_count[[name]], "samples initially.\n")
  cat(name, "has", samples_count_WGS[[name]], "samples after WGS filtering.\n")
  cat(name, "has", samples_count_PAIRED[[name]], "samples after PAIRED filtering.\n")
}


###############

# Count number of samples and runs

# Function to count unique entries in a given column
count_unique_entries <- function(df, column) {
  return(length(unique(df[[column]])))
}

# Display unique entries count for both biosample and run columns for each dataframe
cat("BATS_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(BATS_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(BATS_meta_dataframe_WGS_PAIR, "run"), "\n")
cat("HOT1_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(HOT1_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(HOT1_meta_dataframe_WGS_PAIR, "run"), "\n")
cat("TARA_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(TARA_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(TARA_meta_dataframe_WGS_PAIR, "run"), "\n")
cat("OSD_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(OSD_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(OSD_meta_dataframe_WGS_PAIR, "run"), "\n")
cat("BGS_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(BGS_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(BGS_meta_dataframe_WGS_PAIR, "run"), "\n")
cat("BGT_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(BGT_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(BGT_meta_dataframe_WGS_PAIR, "run"), "\n")
cat("MAL_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(MAL_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(MAL_meta_dataframe_WGS_PAIR, "run"), "\n")
cat("HOT2_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(HOT2_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(HOT2_meta_dataframe_WGS_PAIR, "run"), "\n")
cat("HOT3_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(HOT3_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(HOT3_meta_dataframe_WGS_PAIR, "run"), "\n")
cat("WCO_meta_dataframe_WGS_PAIR - biosample:", count_unique_entries(WCO_meta_dataframe_WGS_PAIR, "biosample"), ", run:", count_unique_entries(WCO_meta_dataframe_WGS_PAIR, "run"), "\n")

