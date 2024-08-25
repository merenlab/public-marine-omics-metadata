# patch BATS

# Patch metadata for BATS

# MAKE USE OF THE steps at end of patchNstandardiseBGT and patchNstandardiseHOT1

# https://github.com/merenlab/public-marine-omics-metadata/issues/3

####################################
## prep
####################################

library(dplyr)
library(data.table)

# Set working directory
setwd("/Users/rameyer/Documents/_P3/P3dataAnalysis/P3_metadata/public-marine-omics-metadata/")

####################################
## go
####################################

## use bottle ID given in ENA metadata to match with metadata given on http://bats.bios.edu/
## as said to be done in the associated data publication
## Biller, S., Berube, P., Dooley, K. et al. Marine microbial metagenomes sampled across space and time. Sci Data 5, 180176 (2018). https://doi.org/10.1038/sdata.2018.176

## For how to get the data from http://bats.bios.edu/ see


# read in the .txt file from edu (skipping the first 41 lines)

bats_bottle_data <- read.table("data/bats_bottle.txt", header = TRUE, sep = "\t")

head(bats_bottle_data)
dim(bats_bottle_data)
# [1] 69976    35

dim(BATS_meta_dataframe_100)
# [1] 40 55

# Rename the column in bats_bottle_data
colnames(bats_bottle_data)[colnames(bats_bottle_data) == "Id"] <- "bottle_id"

# Add suffix '_edu' to all columns except the key column 'bottle_id'
colnames(bats_bottle_data)[colnames(bats_bottle_data) != "bottle_id"] <- paste0(colnames(bats_bottle_data)[colnames(bats_bottle_data) != "bottle_id"], "_edu")

# Ensure the key columns are of the same type
BATS_meta_dataframe_100$bottle_id <- as.character(BATS_meta_dataframe_100$bottle_id)
bats_bottle_data$bottle_id <- as.character(bats_bottle_data$bottle_id)

# Perform a left join to keep all rows from BATS_meta_dataframe_100
BATS_edu_merged <- left_join(BATS_meta_dataframe_100, bats_bottle_data, by = "bottle_id")

# View the colnames of the new dataframe
colnames(BATS_edu_merged)

# View the first few rows of the new dataframe
head(BATS_edu_merged)
dim(BATS_edu_merged)
# [1] 40 89


# Info for all bottles is there :) 

#########################################################
# save it

fwrite(BATS_edu_merged, file = "data/BATS_patch1.csv")



##########################################################
# patch and standardise further


# Load necessary libraries
library(dplyr)
library(tidyr)
library(lubridate)


# Create a new dataframe to keep the original dataframe safe
BATS_edu_merged_patch2 <- BATS_edu_merged



#### patch with info from publication text

# Add size fraction thresholds and concatenate into size_frac
BATS_edu_merged_patch2 <- BATS_edu_merged_patch2 %>%
  mutate(size_frac_low = 0.22,
         size_frac_up = NA,
         size_frac = paste(size_frac_low, size_frac_up, sep = "-"))

# Add samp_size and samp_vol_we_dna_ext columns
BATS_edu_merged_patch2 <- BATS_edu_merged_patch2 %>%
  mutate(samp_size = 500,
         samp_vol_we_dna_ext = 100)

# add layer information
# Convert collection_date to Date type if it is not already
BATS_edu_merged_patch2$collection_date <- as.Date(BATS_edu_merged_patch2$collection_date)

# Define the new dataframe with the 'layer' column
BATS_edu_merged_patch2 <- BATS_edu_merged_patch2 %>%
  group_by(collection_date) %>%
  arrange(collection_date, depth) %>%
  mutate(layer = case_when(
    row_number() == 1 ~ "surface water",
    row_number() == 2 ~ "deep chlorophyll maximum",
    row_number() == 3 ~ "bottom of euphotic zone",
    TRUE ~ NA_character_
  )) %>%
  ungroup()


#### rearrange data

# Separate lat_lon into latitude and longitude and make into decimal values
BATS_edu_merged_patch2 <- BATS_edu_merged_patch2 %>%
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
BATS_edu_merged_patch2 <- BATS_edu_merged_patch2 %>%
  mutate(lat_lon = paste(latitude, longitude, sep = " "))


# Separate the collection_date into year, month, day
BATS_edu_merged_patch2 <- BATS_edu_merged_patch2 %>%
  mutate(
    year = year(ymd(collection_date)),
    month = month(ymd(collection_date)),
    day = day(ymd(collection_date))
  )

##########
# Function to format the time
format_time <- function(time) {
  # Convert time to string
  time_str <- as.character(time)
  # Check the number of digits
  if (nchar(time_str) == 3) {
    # If three digits, format as 08:51
    hh <- substr(time_str, 1, 1)
    mm <- substr(time_str, 2, 3)
    hh <- paste0("0", hh)
  } else {
    # If four digits, format as 19:05
    hh <- substr(time_str, 1, 2)
    mm <- substr(time_str, 3, 4)
  }
  # Combine into hh:mm format
  return(paste(hh, mm, sep = ":"))
}

# Apply the function to create the new "time" column
BATS_edu_merged_patch2$time <- sapply(BATS_edu_merged_patch2$time_edu, format_time)


## In _edu columns replace any remaining -999 values with NA
## to avoid confusion later

# Function to replace -999, -999.0, and -999.00 with NA
replace_with_na <- function(x) {
  x[x == -999 | x == -999.0 | x == -999.00] <- NA
  return(x)
}

# Apply the replacement function to columns ending with _edu
BATS_edu_merged_patch2 <- BATS_edu_merged_patch2 %>%
  mutate(across(ends_with("_edu"), replace_with_na))


# Rename columns for environmental metadata
BATS_edu_merged_patch2 <- BATS_edu_merged_patch2 %>%
  rename(
    qualityFlagNiskinBottle_2isGood_edu = QF_edu,
    temperature_degC = Temp_edu,
    salinity_pss = CTD_S_edu,
    oxygen_umolKg = `O2.1._edu`,
    dic_umolKg = CO2_edu, 
    alkalinity_uequiv = Alk_edu, 
    nitrite_umolKG = NO21_edu,
    phosphate_umolKg = PO41_edu, 
    silicate_umolKg = Si1_edu,
    poc_ugKg = POC_edu
  )

# Remove columns where we are using other ones (e.g. using CTD_s_edu, don't need Sal1_edu (which has less values))
# or where the other projects for sure don't have matching ones
# or if they only have non-values (-999 = Missing or bad data)
BATS_edu_merged_patch2 <- BATS_edu_merged_patch2 %>%
  select(-Sal1_edu, -OxFix_edu, -Anom1_edu, -NO31_edu, -PON_edu, -TOC_edu, -TN_edu, -Bact_edu, -POP_edu, -TDP_edu, -SRP_edu, -BSi_edu, -LSi_edu, -Pro_edu, -Syn_edu, -Piceu_edu, -Naneu_edu, -`Sig.th_edu`)

colnames(BATS_edu_merged_patch2)
head(BATS_edu_merged_patch2)
dim(BATS_edu_merged_patch2)
# [1] 40 83



# add empty column on local_time
BATS_edu_merged_patch2$local_time <- NA

# add column on enviornmental_package
BATS_edu_merged_patch2$environmental_package <- "water"

dim(BATS_edu_merged_patch2)
# [1] 40 85
######################################
# save it

fwrite(BATS_edu_merged_patch2, file = "data/BATS_patch2.csv")


# removing any columns that only have -999 = Missing or bad data