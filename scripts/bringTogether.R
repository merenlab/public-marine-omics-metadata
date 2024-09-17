### A script to bring the metadata from the different together

###########################################################
# This script combines the marine metadata datasets by:
# 1. Checking for required R packages, installing them if necessary, and loading them.
# 2. Counting unique entries for specific columns across several dataframes.
### Here is where it properly starts:
# 3. Ensuring each dataframe contains specific environmental columns, adding missing ones with NA values.
# 4. Identifying and cleaning "weird" sensor data values (e.g., sequences of 9s).
# 5. Merging several datasets, harmonizing column names, and preserving common columns.
# 6. Adding project metadata and geographical information such as marine regions, seasons, and environment types.
# 7. Performing last filtering based on information added in 6. (remove samples classified as "land")
# 8. Saving the cleaned and merged dataset to a file for further analysis.
###########################################################

####################################
## prep
####################################

# Set working directory
setwd("/Users/rameyer/Documents/_P3/P3dataAnalysis/P3_metadata/public-marine-omics-metadata/")

### Check if a package is installed, install it if not, and then load it
install_and_load <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

### Check, install, and load required packages
install_and_load("dplyr")
install_and_load("mregions2")
install_and_load("leaflet")
install_and_load("leaflet.extras2")
install_and_load("sf")
install_and_load("stringr")
install_and_load("tidyr")

####################################
## go
####################################

# Function to count unique entries in a given column
count_unique_entries <- function(df, column) {
  return(length(unique(df[[column]])))
}

# Display unique entries count for both biosample and run columns for each dataframe
cat("OSD_patch2 - biosample:", count_unique_entries(OSD_patch2, "biosample"), ", run:", count_unique_entries(OSD_patch2, "run"), "\n")
cat("MAL_pub_merged_patch2 - biosample:", count_unique_entries(MAL_pub_merged_patch2, "biosample"), ", run:", count_unique_entries(MAL_pub_merged_patch2, "run"), "\n")
cat("TARA_patch2 - biosample:", count_unique_entries(TARA_patch2, "biosample"), ", run:", count_unique_entries(TARA_patch2, "run"), "\n")
cat("BGS_pub_merged_patch2 - biosample:", count_unique_entries(BGS_pub_merged_patch2, "biosample"), ", run:", count_unique_entries(BGS_pub_merged_patch2, "run"), "\n")
cat("HOT1_pubNdog_merged_patch2 - biosample:", count_unique_entries(HOT1_pubNdog_merged_patch2, "biosample"), ", run:", count_unique_entries(HOT1_pubNdog_merged_patch2, "run"), "\n")
cat("HOT3_patch2 - biosample:", count_unique_entries(HOT3_patch2, "biosample"), ", run:", count_unique_entries(HOT3_patch2, "run"), "\n")
cat("BATS_edu_merged_patch2 - biosample:", count_unique_entries(BATS_edu_merged_patch2, "biosample"), ", run:", count_unique_entries(BATS_edu_merged_patch2, "run"), "\n")
cat("BGT_pubNbodc_merged_patch2 - biosample:", count_unique_entries(BGT_pubNbodc_merged_patch2, "biosample"), ", run:", count_unique_entries(BGT_pubNbodc_merged_patch2, "run"), "\n")

#############################################################

# make sure all dfs have these columns in addition to the ones I already know they have
# "pressure_dbar", "salinity_pss", "oxygen_umolKg", "phosphate_umolKg", 
# "silicate_umolKg", "nitrate_umolKg", "nitrite_umolKg", "dic_umolKg", 
# "doc_umolKg", "chlorophyll", "chla_ngL", "chlb_ngL", "chlc_ngL"

# List of required columns to be present in each dataframe
required_columns <- c(
  "pressure_dbar", "salinity_pss", "oxygen_umolKg", "phosphate_umolKg", 
  "silicate_umolKg", "nitrate_umolKg", "nitrite_umolKg", "dic_umolKg", 
  "doc_umolKg", "chlorophyll", "chla_ngL", "chlb_ngL", "chlc_ngL"
)

# Let's define some functions for that:

# Function to ensure all required columns are present in each dataframe
# If any required column is missing, it will be added with NA values
ensure_columns <- function(df, required_columns) {
  missing_cols <- setdiff(required_columns, colnames(df)) # Identify missing columns
  df[missing_cols] <- NA  # Add missing columns with NA values
  return(df)  # Return the updated dataframe
}

# Function to identify "weird" values in numeric columns (e.g., values consisting entirely of 9s)
# Returns a dataframe marking weird values, while leaving other values as NA for easy filtering
find_weird_values <- function(df) {
  df_weird <- df  # Create a copy of the dataframe to store weird value marks
  for (col in colnames(df)) {
    if (is.numeric(df[[col]])) {  # Only process numeric columns
      # Flag values that are a sequence of 9s (like 999, 9999) as "weird"
      df_weird[[col]] <- ifelse(grepl("^9{2,}$", as.character(df[[col]])), df[[col]], NA)
    } else {
      df_weird[[col]] <- NA  # Set non-numeric columns to NA in this operation
    }
  }
  return(df_weird)  # Return the dataframe marking weird values
}

# Function to clean "weird" values by replacing them with NA
# Useful for cases where sensor data might have faulty measurements represented by 9s
remove_weird_values <- function(df) {
  df_clean <- df  # Create a copy of the dataframe to clean
  for (col in colnames(df)) {
    if (is.numeric(df[[col]])) {  # Only process numeric columns
      # Replace weird values (those consisting of only 9s) with NA
      df_clean[[col]] <- ifelse(grepl("^9{2,}$", as.character(df[[col]])), NA, df[[col]])
    }
  }
  return(df_clean)  # Return the cleaned dataframe
}

# Step 1: Rename the dataframes to follow the structure [PROJECT_ACRONYM]_toBeCombined
BGT_toBeCombined <- BGT_pubNbodc_merged_patch2
HOT1_toBeCombined <- HOT1_pubNdog_merged_patch2
BATS_toBeCombined <- BATS_edu_merged_patch2
MAL_toBeCombined <- MAL_pub_merged_patch2
TARA_toBeCombined <- TARA_patch2
OSD_toBeCombined <- OSD_patch2
BGS_toBeCombined <- BGS_pub_merged_patch2
HOT3_toBeCombined <- HOT3_patch2

# Step 2: Add 'project' column to each dataframe
BGT_toBeCombined$project <- "BGT"
HOT1_toBeCombined$project <- "HOT1"
BATS_toBeCombined$project <- "BATS"
MAL_toBeCombined$project <- "MAL"
TARA_toBeCombined$project <- "TARA"
OSD_toBeCombined$project <- "OSD"
BGS_toBeCombined$project <- "BGS"
HOT3_toBeCombined$project <- "HOT3"

# Step 2.5: Ensure that each dataframe contains all required columns and clean weird values
# For each dataframe:
# - Ensure the required columns are present (add missing ones as NA)
# - Remove any weird values (e.g., bunches of 9s) by setting them to NA
BGT_toBeCombined <- remove_weird_values(ensure_columns(BGT_toBeCombined, required_columns))
HOT1_toBeCombined <- remove_weird_values(ensure_columns(HOT1_toBeCombined, required_columns))
BATS_toBeCombined <- remove_weird_values(ensure_columns(BATS_toBeCombined, required_columns))
MAL_toBeCombined <- remove_weird_values(ensure_columns(MAL_toBeCombined, required_columns))
TARA_toBeCombined <- remove_weird_values(ensure_columns(TARA_toBeCombined, required_columns))
OSD_toBeCombined <- remove_weird_values(ensure_columns(OSD_toBeCombined, required_columns))
BGS_toBeCombined <- remove_weird_values(ensure_columns(BGS_toBeCombined, required_columns))
HOT3_toBeCombined <- remove_weird_values(ensure_columns(HOT3_toBeCombined, required_columns))

# Step 3: Identify common columns (including the new 'project' column)
common_columns <- Reduce(intersect, list(
  colnames(BGT_toBeCombined),
  colnames(HOT1_toBeCombined),
  colnames(BATS_toBeCombined),
  colnames(MAL_toBeCombined),
  colnames(TARA_toBeCombined),
  colnames(OSD_toBeCombined),
  colnames(BGS_toBeCombined),
  colnames(HOT3_toBeCombined)
))

# Step 4: Define a function to rename non-common columns and keep 'project' column intact
rename_conflicting_columns <- function(df, common_cols, df_name) {
  df_copy <- df  # Create a copy to keep the original dataframe safe
  
  colnames(df_copy) <- sapply(colnames(df_copy), function(col_name) {
    if (col_name %in% common_cols) {
      return(col_name)
    } else {
      return(paste0(col_name, "_", df_name))
    }
  })
  return(df_copy)
}

# Step 5: Apply the renaming to the newly named dataframes
BGT_toBeCombined <- rename_conflicting_columns(BGT_toBeCombined, common_columns, "BGT")
HOT1_toBeCombined <- rename_conflicting_columns(HOT1_toBeCombined, common_columns, "HOT1")
BATS_toBeCombined <- rename_conflicting_columns(BATS_toBeCombined, common_columns, "BATS")
MAL_toBeCombined <- rename_conflicting_columns(MAL_toBeCombined, common_columns, "MAL")
TARA_toBeCombined <- rename_conflicting_columns(TARA_toBeCombined, common_columns, "TARA")
OSD_toBeCombined <- rename_conflicting_columns(OSD_toBeCombined, common_columns, "OSD")
BGS_toBeCombined <- rename_conflicting_columns(BGS_toBeCombined, common_columns, "BGS")
HOT3_toBeCombined <- rename_conflicting_columns(HOT3_toBeCombined, common_columns, "HOT3")

# Step between 5 and 6: Convert 'collection_date' to character in all data frames
# (some were seen as date and that created issues with the upcoming merge)
BGT_toBeCombined$collection_date <- as.character(BGT_toBeCombined$collection_date)
HOT1_toBeCombined$collection_date <- as.character(HOT1_toBeCombined$collection_date)
BATS_toBeCombined$collection_date <- as.character(BATS_toBeCombined$collection_date)
MAL_toBeCombined$collection_date <- as.character(MAL_toBeCombined$collection_date)
TARA_toBeCombined$collection_date <- as.character(TARA_toBeCombined$collection_date)
OSD_toBeCombined$collection_date <- as.character(OSD_toBeCombined$collection_date)
BGS_toBeCombined$collection_date <- as.character(BGS_toBeCombined$collection_date)
HOT3_toBeCombined$collection_date <- as.character(HOT3_toBeCombined$collection_date)

# Step 6: Merge dataframes using full outer join on common columns
all_projects <- Reduce(function(x, y) merge(x, y, by = common_columns, all = TRUE), 
                       list(BGT_toBeCombined, HOT1_toBeCombined, 
                            BATS_toBeCombined, MAL_toBeCombined, 
                            TARA_toBeCombined, OSD_toBeCombined, 
                            BGS_toBeCombined, HOT3_toBeCombined))

dim(all_projects)

# Step 7: Reorder columns so that related columns are grouped together
non_common_cols <- setdiff(colnames(all_projects), common_columns)
grouped_cols <- unique(sub("_[^_]+$", "", non_common_cols))
final_order <- c(common_columns, unlist(sapply(grouped_cols, function(col) {
  grep(col, colnames(all_projects), value = TRUE)
})))

# Reorder the dataframe
all_projects <- all_projects[, final_order]
all_projects
# View the final merged dataframe
head(all_projects)
dim(all_projects)
# [1] 2031  320 /299

write.table(all_projects, "data/all_projects.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# Select only the common columns in the new dataframe
common_all_projects <- all_projects[, common_columns]
dim(common_all_projects)
# [1] 2031   68 / 80

write.table(common_all_projects, "data/metagenomes.txt", sep = "\t", row.names = FALSE, quote = FALSE)

################################################################################

## patch further

####################
# add layer = `surface water` for any that do not have a value in there yet, since 
# none of those mention any specific layer sampling (e.g. of DCM)

library(dplyr)

common_all_projects <- common_all_projects %>%
  mutate(layer = ifelse(layer %in% c("deep chlorophyll maximum", "surface water"), 
                        layer, 
                        "surface water"))

####################
# add season information based on lat_lon and date

# Convert collection_date to Date type
common_all_projects$collection_date <- as.Date(common_all_projects$collection_date)

sum(is.na(common_all_projects$collection_date))

# Check if the format matches the expected "YYYY-MM-DD" pattern
correct_format <- grepl("^\\d{4}-\\d{2}-\\d{2}$", common_all_projects$collection_date)

# Output the rows where the format is incorrect
incorrect_dates <- common_all_projects$collection_date[!correct_format]

# Print invalid date formats
if (length(incorrect_dates) > 0) {
  print("These dates do not match the expected format YYYY-MM-DD:")
  print(incorrect_dates)
} else {
  print("All dates are in the correct format.")
}

## Determine the Hemisphere:
# If the latitude is positive, the location is in the Northern Hemisphere.
# If the latitude is negative, the location is in the Southern Hemisphere.

## Determine the Season Based on Date:
# For the Northern Hemisphere:
#   Spring: March 20th to June 20th
# Summer: June 21st to September 22nd
# Fall: September 23rd to December 21st
# Winter: December 22nd to March 19th
# For the Southern Hemisphere:
#   Spring: September 23rd to December 21st
# Summer: December 22nd to March 19th
# Fall: March 20th to June 20th
# Winter: June 21st to September 22nd


# Define a function to determine the season
getSeason <- function(date) {
  # Check if the date is NA
  if (is.na(date)) {
    return(NA)
  }
  
  # Extract month and day from the date
  month <- as.numeric(format(date, "%m"))
  day <- as.numeric(format(date, "%d"))
  
  # Determine the season
  if ((month == 3 & day >= 20) | (month > 3 & month < 6) | (month == 6 & day <= 20)) {
    return("Spring")
  } else if ((month == 6 & day >= 21) | (month > 6 & month < 9) | (month == 9 & day <= 22)) {
    return("Summer")
  } else if ((month == 9 & day >= 23) | (month > 9 & month < 12) | (month == 12 & day <= 21)) {
    return("Fall")
  } else {
    return("Winter")
  }
}

# Apply the function to each date
common_all_projects$season <- sapply(common_all_projects$collection_date, getSeason)
common_all_projects$season

common_all_projects$collection_date <- as.character(common_all_projects$collection_date)
write.table(common_all_projects, "data/metagenomes.txt", sep = "\t", row.names = FALSE, quote = FALSE)

#####################
# Add info on marine region

# Install mregions2 
# install.packages("mregions2", repos = "https://ropensci.r-universe.dev")
# 
# install.packages("leaflet") # needed by mrp_view
# install.packages("leaflet.extras2") # needed by mrp_view
# 
# install.packages("sf")
# install.packages("dplyr")

# Load the mregions2 library
library(mregions2)
library(leaflet)
library(leaflet.extras2)
library(sf)
library(dplyr)

# get overview of marine regions data products
#View(mrp_list)
mrp_ontology

# ## decide which list to use
# mrp_view("lme")
# mrp_view("ecs") # for continental shelfs
# mrp_view("iho") # this is more detailed than goas
# mrp_view("goas")
# mrp_view("longhurst") # super detailed / Global Biogeochemical Provinces (Longhurst)
# mrp_view("seavox_v18") # has north west atlantic, might be good compromise
# mrp_view("high_seas")
# mrp_view("ecoregions")

################################

# Download the SeaVoX v18 dataset
seavox_layer <- mrp_get(layer = "seavox_v18")

# Convert the downloaded data to an sf object
seavox_sf <- st_as_sf(seavox_layer)

common_all_projects <- common_all_projects %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# make the world flat (https://github.com/r-spatial/sf/issues/2366)
sf_use_s2(FALSE)

# Perform spatial join to assign marine regions to your data points
common_all_projects_seavox_regions <- st_join(common_all_projects, seavox_sf, join = st_intersects)

# View the result
head(common_all_projects_seavox_regions)
colnames(common_all_projects_seavox_regions)
#View(common_all_projects_seavox_regions)

# Select all columns up to and including 'region'
common_all_projects_seavox_regions <- common_all_projects_seavox_regions[, 1:which(names(common_all_projects_seavox_regions) == "region")]

# Add the suffix '_seavox' to the specified columns
cols_to_rename <- c("sub_region", "region")
names(common_all_projects_seavox_regions)[names(common_all_projects_seavox_regions) %in% cols_to_rename] <- paste0(cols_to_rename, "_seavox")
colnames(common_all_projects_seavox_regions)

############################################
# and add longhurst

# Download the longhurst dataset
longhurst_layer <- mrp_get(layer = "longhurst")

# Convert the downloaded data to an sf object
longhurst_sf <- st_as_sf(longhurst_layer)

common_all_projects_seavox_regions <- common_all_projects_seavox_regions %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

sf_use_s2(FALSE)

# Perform spatial join to assign marine regions to your data points
common_all_projects_seavoxNlonghurst_regions <- st_join(common_all_projects_seavox_regions, longhurst_sf, join = st_intersects)

# View the result
head(common_all_projects_seavoxNlonghurst_regions)
colnames(common_all_projects_seavoxNlonghurst_regions)

# Select all columns up to and including 'provdescr'
common_all_projects_seavoxNlonghurst_regions <- common_all_projects_seavoxNlonghurst_regions[, 1:which(names(common_all_projects_seavoxNlonghurst_regions) == "provdescr")]

# Add the suffix '_longhurst' to the 'provcode' and 'provdescr' columns
cols_to_rename <- c("provcode", "provdescr")
names(common_all_projects_seavoxNlonghurst_regions)[names(common_all_projects_seavoxNlonghurst_regions) %in% cols_to_rename] <- paste0(cols_to_rename, "_longhurst")
colnames(common_all_projects_seavoxNlonghurst_regions)

#View(common_all_projects_seavoxNlonghurst_regions)

######################
# Some samples are missing info, two of which we need

# Check if there are any NAs in the last 5 columns
any(is.na(common_all_projects_seavoxNlonghurst_regions[, (ncol(common_all_projects_seavoxNlonghurst_regions)-4):ncol(common_all_projects_seavoxNlonghurst_regions)]))
# Count NAs in each of the last 5 columns
colSums(is.na(common_all_projects_seavoxNlonghurst_regions[, (ncol(common_all_projects_seavoxNlonghurst_regions)-4):ncol(common_all_projects_seavoxNlonghurst_regions)]))


# For 'biosample' SAMEA2619802, add "Land" in the columns sub_region_seavox	region_seavox	provcode_longhurst	provdescr_longhurst
# For 'biosample' SAMEA2620756, add "MOZAMBIQUE CHANNEL" in sub_region_seavox and "INDIAN OCEAN" in region_seavox

common_all_projects_seavoxNlonghurst_regions <- common_all_projects_seavoxNlonghurst_regions %>%
  mutate(
    sub_region_seavox = case_when(
      biosample == "SAMEA2619802" ~ "Land",
      biosample == "SAMEA2620756" ~ "MOZAMBIQUE CHANNEL",
      TRUE ~ sub_region_seavox
    ),
    region_seavox = case_when(
      biosample == "SAMEA2619802" ~ "Land",
      biosample == "SAMEA2620756" ~ "INDIAN OCEAN",
      TRUE ~ region_seavox
    ),
    provcode_longhurst = ifelse(biosample == "SAMEA2619802", "Land", provcode_longhurst),
    provdescr_longhurst = ifelse(biosample == "SAMEA2619802", "Land", provdescr_longhurst)
  )

######### remove samples which say "Land" or "... MAINLAND"
# Filter rows where 'region_seavox' contains "land" (case-insensitive, as part of any word)
land_rows <- common_all_projects_seavoxNlonghurst_regions[
  grepl("land", common_all_projects_seavoxNlonghurst_regions$region_seavox, ignore.case = TRUE),
]

# Display the filtered rows
land_rows

# Remove rows where 'region_seavox' contains "land" (case-insensitive)
filtered_df <- common_all_projects_seavoxNlonghurst_regions[
  !grepl("land", common_all_projects_seavoxNlonghurst_regions$region_seavox, ignore.case = TRUE),
]

dim(common_all_projects_seavoxNlonghurst_regions)
#[1] 2031   72 /84
dim(filtered_df)
#[1] 2007   72 /84

###################

# Add Coastal VS not coastal info based on provdescr_longhurst

library(dplyr)
library(stringr)

# str_trim ensures we don't have the trailing spaces
filtered_df_regions <- filtered_df %>%
  mutate(environment = str_trim(str_extract(provdescr_longhurst, "^[^\\-]+")))

filtered_df_regions$environment

#########################################

# re-add the latitude and longitude information that was eaten up by the location assignment

filtered_df_regions <- filtered_df_regions %>%
  separate(lat_lon, into = c("latitude", "longitude"), sep = " ", remove = FALSE)

#########################################

# include lat info as distance from equator

# make sure latitude is numeric
filtered_df_regions$latitude <- as.numeric(as.character(filtered_df_regions$latitude))

# The Earth's radius is approximately 6,371 km
# formula is distance (km) = Earth's Radious (km) * (pi / 180) * absolute latitude
filtered_df_regions$distance_from_equator <- 6371 * pi / 180 * abs(filtered_df_regions$latitude)

# View the updated dataframe
head(filtered_df_regions)


####################################

#### check number of samples per project after metadata filtering
result <- filtered_df_regions %>%
  group_by(project) %>%
  summarise(unique_biosamples = n_distinct(biosample))

print(result)


#########################################
# save it

# R stores dates as the number of days since January 1, 1970, which is known as 
# the "epoch" in Unix time. For example, "2003-02-21" is stored internally as 12472, 
# which is the number of days from January 1, 1970, to February 21, 2003.
# Automatic Conversion: When you pass a Date object to the write.table function, 
# it automatically converts the date to this numeric format (i.e., the number of 
# days since the epoch) rather than keeping it as a formatted date string like "2003-02-21."
# to avoid that, we are storing it as characters

filtered_df_regions$collection_date <- as.character(filtered_df_regions$collection_date)
write.table(filtered_df_regions, "data/metagenomes.txt", sep = "\t", row.names = FALSE, quote = FALSE)
