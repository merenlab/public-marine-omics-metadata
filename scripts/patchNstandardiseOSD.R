# patch OSD

# Patch metadata for OSD Oceans

# https://store.pangaea.de/Projects/OSD_2014/OSD_Handbook_v2_June_2014.pdf
# marine_region as geo_loc_name
# event_date_time in this format: 2014-06-21T11:24:00+00
# latitude_start	longitude_start

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

colnames(OSD_meta_dataframe_100)
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
OSD <- OSD_meta_dataframe_100 %>%
  rename_with(rename_column)



colnames(OSD)


#########################################################
# save it

fwrite(OSD, file = "data/OSD_patch1.csv")


##########################################################
# patch and standardise 


# Load necessary libraries
library(dplyr)
library(tidyr)
library(lubridate)


# Create a new dataframe to keep the original dataframe safe
OSD_patch2 <- OSD


################################################################ 
#### patch with info from publication text

# Add samp_size and samp_vol_we_dna_ext columns
# Range of 10‐20 found in	https://store.pangaea.de/Projects/OSD_2014/OSD_Handbook_v2_June_2014.pdf 

# Add size fraction thresholds and concatenate into size_frac
OSD_patch2 <- OSD_patch2 %>%
  mutate(size_fraction_lower_threshold = 0.22,
         size_fraction_upper_threshold = NA,
         size_frac = paste(size_fraction_lower_threshold, size_fraction_upper_threshold, sep = "-"))




################################################################
#### rearrange data

library(dplyr)
library(stringr)

# Standardize lat lon naming and have them separate and together
OSD_patch2 <- OSD_patch2 %>%
  # Rename columns
  rename(
    latitude = latitude_start,
    longitude = longitude_start
  ) %>%
  # Create `lat_lon` column
  mutate(
    lat_lon = paste(latitude, longitude, sep = " ")
  )


##########
# Format the time
# Separate the `event_date_time` column into separate `year`, `month`, `date`, and `time` columns 
# Have to remove the "Z" for this to run
OSD_patch2 <- OSD_patch2 %>%
  mutate(
    year = substr(event_date_time, 1, 4),
    month = substr(event_date_time, 6, 7),
    day = substr(event_date_time, 9, 10),
    time = substr(event_date_time, 12, 19)
  )
OSD_patch2$time

# create the collection_date column
# only keep the date in the date
OSD_patch2 <- OSD_patch2 %>%
  mutate(collection_date = str_replace(event_date_time, "T.*", ""))

OSD_patch2$collection_date

# make layer column, adding "surface water" for all except run "ERR770998", which notes "deep chlorophyll maximum"
OSD_patch2 <- OSD_patch2 %>%
  mutate(layer = if_else(run == "ERR770998", "deep chlorophyll maximum", "surface water"))
OSD_patch2$layer

## READY
# Rename columns for environmental metadata
OSD_patch2 <- OSD_patch2 %>%
  rename(
    temperature_degC = temperature,
    salinity_pss = salinity,
    env_biome = environment_biome,
    env_feature = environment_feature, 
    env_material = environment_material,
    geo_loc_name = marine_region
  )

# remove rows that are freshwater samples
OSD_patch2 <- OSD_patch2 %>%
  filter(!str_detect(env_material, "freshwater"))

colnames(OSD_patch2)
head(OSD_patch2)
dim(OSD_patch2)
# [1] 149  88

OSD_patch2$local_time <- NA

OSD_patch2$samp_size <- NA

OSD_patch2$samp_vol_we_dna_ext <- NA
dim(OSD_patch2)
# [1] 149  91

######################################
# save it

fwrite(OSD_patch2, file = "data/OSD_patch2.csv")



