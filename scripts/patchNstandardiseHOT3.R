# patch HOT3

# Patch metadata for HOT3

# Mende, D.R., Bryant, J.A., Aylward, F.O. et al. Environmental drivers of a microbial genomic transition zone in the ocean’s interior. Nat Microbiol 2, 1367–1373 (2017). https://doi.org/10.1038/s41564-017-0008-3

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

head(HOT3_meta_dataframe_100)

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
HOT3 <- HOT3_meta_dataframe_100 %>%
  rename_with(rename_column)



head(HOT3)


#########################################################
# save it

fwrite(HOT3, file = "data/HOT3_patch1.csv")


##########################################################
# patch and standardise 


# Load necessary libraries
library(dplyr)
library(tidyr)
library(lubridate)


# Create a new dataframe to keep the original dataframe safe
HOT3_patch2 <- HOT3


################################################################ 
#### patch with info from publication text

# Add filter thresholds
# Add size fraction thresholds and concatenate into size_frac
HOT3_patch2 <- HOT3_patch2 %>%
  mutate(size_fraction_lower_threshold = 0.22,
         size_fraction_upper_threshold = 1.6,
         size_frac = paste(size_fraction_lower_threshold, size_fraction_upper_threshold, sep = "-"))


################################################################
#### rearrange data

# Separate lat_lon into latitude and longitude and make into decimal values
HOT3_patch2 <- HOT3_patch2 %>%
  # Separate the lat_lon column into individual parts but keep the original column
  separate(lat_lon, into = c("latitude_temp", "lat_direction", "longitude_temp", "lon_direction"), sep = " ") %>%
  # Convert to numeric and adjust for directions
  mutate(
    latitude = as.numeric(latitude_temp) * ifelse(lat_direction == "S", -1, 1),
    longitude = as.numeric(longitude_temp) * ifelse(lon_direction == "E", 1, -1)
  ) %>%
  # Drop the temporary columns
  select(-latitude_temp, -lat_direction, -longitude_temp, -lon_direction)

# then re-create the lat_lon field with decimal values
HOT3_patch2 <- HOT3_patch2 %>%
  mutate(lat_lon = paste(latitude, longitude, sep = " "))

HOT3_patch2$lat_lon

##########
# Format the time

# Split the `collection_date` into separate `year`, `month`, `date`, and `time` columns
HOT3_patch2 <- HOT3_patch2 %>%
  mutate(
    year = year(collection_date),
    month = month(collection_date),
    date = day(collection_date)
  )
HOT3_patch2$year

# Create the time column by adding 10 hours to local_time
HOT3_patch2 <- HOT3_patch2 %>%
  mutate(
    local_datetime = ymd_hms(paste(Sys.Date(), local_time)),
    time = format(local_datetime + hours(10), "%H:%M:%S")
  ) %>%
  select(-local_datetime)  # Remove the intermediate datetime column
HOT3_patch2$time # only given for some

# make layer column
## No info :(

# proactively remove what will be duplictes (empty)
HOT3_patch2 <- HOT3_patch2 %>% 
  select(-c(69, 70, 71))

# Rename columns for environmental metadata
HOT3_patch2 <- HOT3_patch2 %>%
  rename(
    pressure_dbar = pressure,
    temperature_degC = temp,
    salinity_pss = salinity,
    oxygen_umolKg = diss_oxygen,
    silicate_umolKg = silicate,
    phosphate_umolKg = phosphate,
    doc_umolKg = diss_org_carb,
    dic_umolKg = diss_inorg_carb,
    env_biome = env_broad_scale,
    env_feature = env_local_scale, 
    env_material = env_medium
  )

# add empty columns to match other dfs
HOT3_patch2$samp_size <- NA

HOT3_patch2$samp_vol_we_dna_ext <- NA

HOT3_patch2$layer <- NA

HOT3_patch2$environmental_package <- "water"

colnames(HOT3_patch2)
head(HOT3_patch2)
dim(HOT3_patch2)
# [1] 274  84


######################################
# save it

fwrite(HOT3_patch2, file = "data/HOT3_patch2.csv")


