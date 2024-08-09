# script to (0) check depth info availbility (1) patch the missing depth values and (2) filter samples based on depth

################################
######### check depth

################################
######### check depth

# Load necessary library
library(dplyr)

# List of dataframes
dataframes <- list(
  OSD_meta_dataframe_WGS_PAIR,
  BGS_meta_dataframe_WGS_PAIR,
  HOT1_meta_dataframe_WGS_PAIR,
  HOT3_meta_dataframe_WGS_PAIR,
  BATS_meta_dataframe_WGS_PAIR,
  BGT_meta_dataframe_WGS_PAIR,
  TARA_meta_dataframe_WGS_PAIR,
  MAL_meta_dataframe_WGS_PAIR
)

# Function to check if a dataframe has a "depth" column and if all rows in "depth" column have non-missing and non-empty values
check_depth_complete <- function(df) {
  if ("depth" %in% colnames(df)) {
    depth_col <- df$depth
    all(!is.na(depth_col) & depth_col != "")
  } else {
    FALSE
  }
}

# Check each dataframe
results_depth <- sapply(dataframes, check_depth_complete)

# Print the results
names(results_depth) <- c("OSD_meta_dataframe_WGS_PAIR", "BGS_meta_dataframe_WGS_PAIR", 
                          "HOT1_meta_dataframe_WGS_PAIR", "HOT3_meta_dataframe_WGS_PAIR", 
                          "BATS_meta_dataframe_WGS_PAIR", "BGT_meta_dataframe_WGS_PAIR", 
                          "TARA_meta_dataframe_WGS_PAIR", "MAL_meta_dataframe_WGS_PAIR")

print(results_depth)















# Load necessary library
library(dplyr)

# List of dataframes
dataframes <- list(
  OSD_meta_dataframe_WGS_PAIR,
  BGS_meta_dataframe_WGS_PAIR,
  HOT1_meta_dataframe_WGS_PAIR,
  HOT3_meta_dataframe_WGS_PAIR,
  BATS_meta_dataframe_WGS_PAIR,
  BGT_meta_dataframe_WGS_PAIR,
  TARA_meta_dataframe_WGS_PAIR,
  MAL_meta_dataframe_WGS_PAIR
)

# Function to check if a dataframe has a "depth" column and if all rows in "depth" column have non-missing values
check_depth_complete <- function(df) {
  "depth" %in% colnames(df) && all(!is.na(df$depth))
}

# Check each dataframe
results_depth <- sapply(dataframes, check_depth_complete)

# Print the results
names(results_depth) <- c("OSD_meta_dataframe_WGS_PAIR", "BGS_meta_dataframe_WGS_PAIR", 
                          "HOT1_meta_dataframe_WGS_PAIR", "HOT3_meta_dataframe_WGS_PAIR", 
                          "BATS_meta_dataframe_WGS_PAIR", "BGT_meta_dataframe_WGS_PAIR", 
                          "TARA_meta_dataframe_WGS_PAIR", "MAL_meta_dataframe_WGS_PAIR")

print(results_depth)


# BGS is missing depth values




################################
####### Patch depth info to BGS from publication
# Larkin, A.A., Garcia, C.A., Garcia, N. et al. High spatial resolution global ocean metagenomes from Bio-GO-SHIP repeat hydrography transects. Sci Data 8, 107 (2021). https://doi.org/10.1038/s41597-021-00889-9

# Load required package
library(dplyr)

# Add a column called 'depth' with the value 5 to BGS_ENAnMG_merged_clean_no_duplicates
BGS_meta_dataframe_WGS_PAIR_depth <- BGS_meta_dataframe_WGS_PAIR %>%
  mutate(depth = 5)

# Display the first few rows to verify the new column
head(BGS_meta_dataframe_WGS_PAIR_depth$depth)





####### Check the syntax of depth values in all dfs

####### Check the syntax of depth values in all dfs

# Load necessary package
library(dplyr)

# Function to clean depth values
clean_depth <- function(depth_col) {
  # Check if the value has "m" in it and remove it
  depth_col_clean <- gsub("m", "", depth_col)
  
  # Check if the value is a range (e.g., "1-20")
  is_range <- grepl("-", depth_col_clean)
  
  # Calculate the average if it's a range
  depth_col_clean[is_range] <- sapply(depth_col_clean[is_range], function(x) {
    range_vals <- as.numeric(unlist(strsplit(x, "-")))
    mean(range_vals)
  })
  
  # Convert to numeric
  depth_col_numeric <- as.numeric(depth_col_clean)
  return(depth_col_numeric)
}

# List of dataframes to process
dataframes <- list(
  HOT1_meta_dataframe_WGS_PAIR,
  HOT3_meta_dataframe_WGS_PAIR,
  BATS_meta_dataframe_WGS_PAIR,
  BGT_meta_dataframe_WGS_PAIR,
  TARA_meta_dataframe_WGS_PAIR,
  OSD_meta_dataframe_WGS_PAIR,
  MAL_meta_dataframe_WGS_PAIR
)

# Corresponding names for the new dataframes
depth_dataframes_names <- c(
  "HOT1_meta_dataframe_WGS_PAIR_depth",
  "HOT3_meta_dataframe_WGS_PAIR_depth",
  "BATS_meta_dataframe_WGS_PAIR_depth",
  "BGT_meta_dataframe_WGS_PAIR_depth",
  "TARA_meta_dataframe_WGS_PAIR_depth",
  "OSD_meta_dataframe_WGS_PAIR_depth",
  "MAL_meta_dataframe_WGS_PAIR_depth"
)

# Process each dataframe
for (i in seq_along(dataframes)) {
  cat("Processing dataframe:", depth_dataframes_names[i], "\n")
  
  # Check for depth values with 'm' unit or ranges
  if ("depth" %in% colnames(dataframes[[i]])) {
    has_m_unit <- grepl("m", dataframes[[i]]$depth)
    has_range <- grepl("-", dataframes[[i]]$depth)
    
    if (any(has_m_unit) || any(has_range)) {
      if (any(has_m_unit)) {
        cat("Reworking depth values with 'm' unit in dataframe:", depth_dataframes_names[i], "\n")
      }
      if (any(has_range)) {
        cat("Reworking depth values with range in dataframe:", depth_dataframes_names[i], "\n")
        range_indices <- which(has_range)
        for (index in range_indices) {
          cat("Range found in 'run':", dataframes[[i]]$run[index], "with depth:", dataframes[[i]]$depth[index], "\n")
        }
      }
      dataframes[[i]] <- dataframes[[i]] %>%
        mutate(depth = clean_depth(depth))
    } else {
      cat("No depth values with 'm' unit or range found in dataframe:", depth_dataframes_names[i], "\n")
    }
  } else {
    cat("Depth column not found in dataframe:", depth_dataframes_names[i], "\n")
  }
  
  # Assign the new dataframe to a new variable with the _depth suffix
  assign(depth_dataframes_names[i], dataframes[[i]])
}

# Print the first few rows of the new dataframes to verify the changes
head(HOT1_meta_dataframe_WGS_PAIR_depth$depth)
head(HOT3_meta_dataframe_WGS_PAIR_depth$depth)
head(BATS_meta_dataframe_WGS_PAIR_depth$depth)
head(BGT_meta_dataframe_WGS_PAIR_depth$depth)
head(TARA_meta_dataframe_WGS_PAIR_depth$depth)
head(OSD_meta_dataframe_WGS_PAIR_depth$depth)
head(MAL_meta_dataframe_WGS_PAIR_depth$depth)







################################################################
# Filter based on depth

# Load required package
library(dplyr)

# Function to filter dataframe by depth
filter_depth <- function(df) {
  df %>%
    mutate(rounded_depth = floor(depth)) %>%  # Round down the depth values
    filter(rounded_depth <= 100) %>%          # Keep rows with depth <= 100
    select(-rounded_depth)                    # Remove the rounded_depth column if not needed
}

# List of original dataframe names and their new names
dataframes_info <- list(
  "OSD_meta_dataframe_WGS_PAIR_depth" = "OSD_meta_dataframe_100",
  "MAL_meta_dataframe_WGS_PAIR_depth" = "MAL_meta_dataframe_100",
  "TARA_meta_dataframe_WGS_PAIR_depth" = "TARA_meta_dataframe_100",
  "BGS_meta_dataframe_WGS_PAIR_depth" = "BGS_meta_dataframe_100",
  "HOT1_meta_dataframe_WGS_PAIR_depth" = "HOT1_meta_dataframe_100",
  "HOT3_meta_dataframe_WGS_PAIR_depth" = "HOT3_meta_dataframe_100",
  "BATS_meta_dataframe_WGS_PAIR_depth" = "BATS_meta_dataframe_100",
  "BGT_meta_dataframe_WGS_PAIR_depth" = "BGT_meta_dataframe_100"
)

# Loop through dataframes to filter by depth, save as new dataframe with the specified structure, and print dimensions
for (df_name in names(dataframes_info)) {
  df <- get(df_name)
  original_dim <- dim(df)
  filtered_df <- filter_depth(df)
  new_df_name <- dataframes_info[[df_name]]
  assign(new_df_name, filtered_df)
  filtered_dim <- dim(filtered_df)
  cat(df_name, "dimensions before filtering:", original_dim, "\n")
  cat(new_df_name, "dimensions after filtering:", filtered_dim, "\n\n")
}

# Verify the creation of new dataframes
ls(pattern = "_100$")




#################

# Count number of samples and runs


count_unique_entries <- function(df, column) {
  return(length(unique(df[[column]])))
}

# Display unique entries count for both biosample and run columns for each dataframe
cat("OSD_meta_dataframe_100 - biosample:", count_unique_entries(OSD_meta_dataframe_100, "biosample"), ", run:", count_unique_entries(OSD_meta_dataframe_100, "run"), "\n")
cat("MAL_meta_dataframe_100 - biosample:", count_unique_entries(MAL_meta_dataframe_100, "biosample"), ", run:", count_unique_entries(MAL_meta_dataframe_100, "run"), "\n")
cat("TARA_meta_dataframe_100 - biosample:", count_unique_entries(TARA_meta_dataframe_100, "biosample"), ", run:", count_unique_entries(TARA_meta_dataframe_100, "run"), "\n")
cat("BGS_meta_dataframe_100 - biosample:", count_unique_entries(BGS_meta_dataframe_100, "biosample"), ", run:", count_unique_entries(BGS_meta_dataframe_100, "run"), "\n")
cat("HOT1_meta_dataframe_100 - biosample:", count_unique_entries(HOT1_meta_dataframe_100, "biosample"), ", run:", count_unique_entries(HOT1_meta_dataframe_100, "run"), "\n")
cat("HOT3_meta_dataframe_100 - biosample:", count_unique_entries(HOT3_meta_dataframe_100, "biosample"), ", run:", count_unique_entries(HOT3_meta_dataframe_100, "run"), "\n")
cat("BATS_meta_dataframe_100 - biosample:", count_unique_entries(BATS_meta_dataframe_100, "biosample"), ", run:", count_unique_entries(BATS_meta_dataframe_100, "run"), "\n")
cat("BGT_meta_dataframe_100 - biosample:", count_unique_entries(BGT_meta_dataframe_100, "biosample"), ", run:", count_unique_entries(BGT_meta_dataframe_100, "run"), "\n")

