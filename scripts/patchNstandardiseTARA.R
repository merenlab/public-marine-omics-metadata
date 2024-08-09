# patch TARA

# Patch metadata for TARA Oceans

# no mention of how much water filtered https://www.nature.com/articles/s41579-020-0364-5

# rename temperature to temperature_degC
####################################
## prep
####################################

# Set working directory
setwd("/Users/rameyer/Documents/_P3/P3dataAnalysis/P3_metadata/public-marine-omics-metadata/")

# Install and load necessary packages

if (!require(dplyr)) install.packages("dplyr")
library(dplyr)

####################################
## go
####################################

### standardise names

# Custom renaming function
rename_column <- function(col_name) {
  col_name %>%
    tolower() %>%               # Convert to lower case
    gsub(" ", "_", .) %>%       # Replace spaces with underscores
    gsub("-", "_", .) %>%       # Replace dashes with underscores
    gsub("\\.", "_", .) %>%     # Replace periods with underscores
    gsub("\\(", "", .) %>%      # Remove opening parentheses
    gsub("\\)", "", .) %>%      # Remove closing parentheses
    gsub("/","_", .) %>%        # Replace slashes with underscores
    gsub("_+", "_", .) %>%      # Replace multiple underscores with a single underscore
    gsub("_+$", "", .)          # Remove trailing underscores
}


# also use on the ENA metadata dataframe will will be merging with
TARA <- TARA_meta_dataframe_100 %>%
  rename_with(rename_column)



head(TARA)


#########################################################
# save it

fwrite(TARA, file = "data/TARA_patch1.csv")


##########################################################
# patch and standardise 


# Load necessary libraries
library(dplyr)
library(tidyr)
library(lubridate)


# Create a new dataframe to keep the original dataframe safe
TARA_patch2 <- TARA


################################################################ 
#### patch with info from publication text

# Add samp_size and samp_vol_we_dna_ext columns
# None found


################################################################
#### rearrange data

# Standardize lat lon naming and have them separate and together
TARA_patch2 <- TARA_patch2 %>%
  # Rename columns
  rename(
    latitude = latitude_end,
    longitude = longitude_end
  ) %>%
  # Create `lat_lon` column
  mutate(
    lat_lon = paste(latitude, longitude, sep = " ")
  )

# Add size fraction thresholds and concatenate into size_frac
TARA_patch2 <- TARA_patch2 %>%
  mutate(size_frac = paste(size_fraction_lower_threshold, size_fraction_upper_threshold, sep = "-"))

##########
# Format the time
# Standardize the `event_date.time_start` column and create `collection_date` 
# Have to remove the "Z" for this to run
TARA_patch2 <- TARA_patch2 %>%
  mutate(
    event_date_time_start = gsub("Z$", "", event_date_time_start),  # Remove trailing 'Z'
    event_date_time_start = gsub("T", " ", event_date_time_start),  # Replace 'T' with a space
    event_date_time_start = gsub("^(.{16})$", "\\1:00", event_date_time_start),  # Add seconds if missing
    collection_date = ymd_hms(event_date_time_start)
  )

# Split the `collection_date` into separate `year`, `month`, `date`, and `time` columns
TARA_patch2 <- TARA_patch2 %>%
  mutate(
    year = year(collection_date),
    month = month(collection_date),
    date = day(collection_date),
    time = format(collection_date, "%H:%M:%S")
  )

# only keep the date in the date
TARA_patch2 <- TARA_patch2 %>%
  mutate(collection_date = str_replace(collection_date, " .*", ""))

TARA_patch2$collection_date

# make layer column from environmental_feature information
TARA_patch2 <- TARA_patch2 %>%
  # Extract and clean `layer` from `environment_feature`
  mutate(
    layer = gsub("\\s*\\(.*?\\)", "", environment_feature) %>%
      trimws() # Remove any trailing or leading whitespace
  )
TARA_patch2$layer
# Using gsub to remove the trailing " layer" from each value in the 'layer' column
TARA_patch2$layer <- gsub(" layer$", "", TARA_patch2$layer)



# Rename columns for environmental metadata
TARA_patch2 <- TARA_patch2 %>%
  rename(
    chlorophyll = chlorophyll_sensor,
    temperature_degC = temperature,
    salinity_pss = salinity_sensor,
    oxygen_umolKg = `oxygen_sensor`,
    nitrate_umolKG = nitrate_sensor,
    env_biome = environment_biome,
    env_feature = environment_feature, 
    env_material = environment_material,
    geo_loc_name = marine_region
  )


colnames(TARA_patch2)
head(TARA_patch2)
dim(TARA_patch2)
# [1] 171  98

#### remove samples that do not match the filter sizes I am looking for
# Using the drop method with a condition

TARA_patch2 <- TARA_patch2 %>%
  filter(size_fraction_lower_threshold < 0.23)

dim(TARA_patch2)
# [1] 170  98


# add empty column on local_time
TARA_patch2$local_time <- NA

TARA_patch2$samp_size <- NA

TARA_patch2$samp_vol_we_dna_ext <- NA

dim(TARA_patch2)
# [1] 170  101
######################################
# save it

fwrite(TARA_patch2, file = "data/TARA_patch2.csv")



