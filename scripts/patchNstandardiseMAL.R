# patch ML

# Patch metadata for Malaspina

# Sánchez, P., Coutinho, F.H., Sebastián, M. et al. Marine picoplankton metagenomes and MAGs from eleven vertical profiles obtained by the Malaspina Expedition. Sci Data 11, 154 (2024). https://doi.org/10.1038/s41597-024-02974-1

# filter sizes (0.2 - 3.0 µm) given in publication
# sampled the marine microbiome in tropical and sub-tropical oceans
# a new metagenomic resource of the ocean picoplankton
# layers: from surface photic layers down to 4,000 m deep, covering the DCM, the mesopelagic and the bathypelagic realm with 3–4 sampling depths // targeting 3 layers from the photic and dark ocean: epipelagic, including surface and DCM, mesopelagic and bathypelagic. // (layer separation shown in Fig 1)
# volume collected: Water samples were collected either with a rosette of Niskin bottles (12 L each) on a frame with a CTD sensor or with a large Niskin bottle (30 L) for the surface samples. // add based on value in sample_collection_device
# volume filtered: For every sample, two 6-L replicates 

# broad_scale_environmental_context gives whether it is coastal or not

# date and time: event_date.time_start
# lat: latitude_start (latitude_end can be different but in all descriptions, when latitude is mentioned, this is the number they note)
# lon: longitude_start (same as for latitude)
####################################
## prep
####################################

# Set working directory
setwd("/Users/rameyer/Documents/_P3/P3dataAnalysis/P3_metadata/public-marine-omics-metadata/")

# Install and load necessary packages
if (!require(readxl)) install.packages("readxl")
library(readxl)

if (!require(dplyr)) install.packages("dplyr")
library(dplyr)

library(data.table)

####################################
## go
####################################

# Add metadata about layers (everything else we need, we already have) from Sánchez et al. Supplementary table sheet 03 (Table 02)

# Define the URL of the Excel file associated with the Malaspina data paper
# https://doi.org/10.1038/s41597-024-02974-1 in the Supplementary material
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41597-024-02974-1/MediaObjects/41597_2024_2974_MOESM1_ESM.xlsx"

# Download the Excel file
download.file(url, destfile = "data/MALpubMetadata.xlsx", mode = "wb")

# Read the third sheet from the Excel file
MAL_pub_metadata <- read_excel("data/MALpubMetadata.xlsx", sheet = 3)
head(MAL_pub_metadata)
dim(MAL_pub_metadata)
# [1] 76 26

# Perform the left join to add the "layer" column from MAL_pub_metadata to MAL_meta_dataframe_100
MAL_pub_merged <- MAL_meta_dataframe_100 %>%
  left_join(select(MAL_pub_metadata, sample_alias, layer), by = c("sample_name" = "sample_alias"))


dim(MAL_meta_dataframe_100)
# [1] 83 83
dim(MAL_pub_merged)
# [1] 83 84


#########################################################
# save it

fwrite(MAL_pub_merged, file = "data/MAL_patch1.csv")




##########################################################
# patch and standardise further


# Create a new dataframe to keep the original dataframe safe
MAL_pub_merged_patch2 <- MAL_pub_merged


# Load necessary libraries
library(dplyr)
library(stringr)


#### patch with info from publication text

# Add a column 'samp_size' based on conditions in 'sample_collection_device'
MAL_pub_merged_patch2 <- MAL_pub_merged_patch2 %>%
  mutate(samp_size = case_when(
    sample_collection_device == 'water-sampler-(large-bottle)' ~ 30000,
    sample_collection_device == 'profile-rosette-ctd-water-sampler-(Niskin)' ~ 12000,
    TRUE ~ NA_real_
  ))

# Create a new column 'samp_vol_we_dna_ext' and add 6000 for all rows
MAL_pub_merged_patch2 <- MAL_pub_merged_patch2 %>%
  mutate(samp_vol_we_dna_ext = 6000)


####### rearrange data

### update the names in `layer` to match with the other dfs
# Replace "DCM" with "deep chlorophyll maximum"
MAL_pub_merged_patch2$layer <- gsub("DCM", "deep chlorophyll maximum", MAL_pub_merged_patch2$layer)

# Replace "epipelagic" with "surface water"
MAL_pub_merged_patch2$layer <- gsub("epipelagic", "surface water", MAL_pub_merged_patch2$layer)

# Concatenate lower and upper filter into size_frac
MAL_pub_merged_patch2 <- MAL_pub_merged_patch2 %>%
  rename(
    size_frac_low = size_fraction_lower_threshold,
    size_frac_up = size_fraction_upper_threshold
  ) %>%
  mutate(size_frac = paste(size_frac_low, size_frac_up, sep = "-"))

# Create new columns 'latitude' and 'longitude' and then concatenate them into 'lat_lon'
MAL_pub_merged_patch2 <- MAL_pub_merged_patch2 %>%
  mutate(latitude = latitude_start,
         longitude = longitude_start,
         lat_lon = paste(latitude, longitude, sep = " "))


# Create a new column 'collection_date' from 'event_date.time_start'
# Split 'collection_date' into 'year', 'month', 'day', and 'time' columns
# if time = 99:99 add NA instead
MAL_pub_merged_patch2 <- MAL_pub_merged_patch2 %>%
  mutate(collection_date = `event_date.time_start`,
         year = str_sub(collection_date, 1, 4),
         month = str_sub(collection_date, 6, 7),
         day = str_sub(collection_date, 9, 10),
         time = ifelse(str_sub(collection_date, 12, 16) == "99:99", NA, str_sub(collection_date, 12, 16)))

# only keep the date in the date
MAL_pub_merged_patch2 <- MAL_pub_merged_patch2 %>%
  mutate(collection_date = str_replace(collection_date, "T.*", ""))



# Rename columns for environmental metadata
MAL_pub_merged_patch2 <- MAL_pub_merged_patch2 %>%
  rename(
    temperature_degC = temperature,
    salinity_pss = salinity_sensor,
    oxygen_umolKg = oxygen_sensor,
    env_biome = broad_scale_environmental_context,
    env_feature = local_environmental_context, 
    env_material = environmental_medium, 
    geo_loc_name = marine_region
  )


colnames(MAL_pub_merged_patch2)
head(MAL_pub_merged_patch2)
dim(MAL_pub_merged_patch2)
# [1] 83 95

# add empty column on local_time
MAL_pub_merged_patch2$local_time <- NA

dim(MAL_pub_merged_patch2)
# [1] 83 96
######################################
# save it

fwrite(MAL_pub_merged_patch2, file = "data/MAL_patch2.csv")


