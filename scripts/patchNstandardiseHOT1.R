# patch HOT1

# Patch metadata for HOT1

# https://github.com/merenlab/public-marine-omics-metadata/issues/2


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

########################## 

## Add sample metadata
## from Data Science publication Table 3
# Biller, S., Berube, P., Dooley, K. et al. Marine microbial metagenomes sampled across space and time. Sci Data 5, 180176 (2018). https://doi.org/10.1038/sdata.2018.176
# Already downloaded with Python, now importing

# Import table (shared between HOT1, BATS and BGT)

metadataDataSciBGT <- read.csv(
  "data/metadataDataSciBGT.csv", 
  stringsAsFactors = FALSE, 
  check.names = FALSE
)
head(metadataDataSciBGT)
dim(metadataDataSciBGT)
#[1] 610  21

# worked :)

# Only keep the HOT1 rows (removing BGT and BATS)
metadataDataSciHOT1_only <- metadataDataSciBGT %>% dplyr::filter(grepl("HOT", `Cruise series`))
dim(metadataDataSciHOT1_only)
# [1] 68  21

# check if same as the one we want to merge it with
dim(HOT1_meta_dataframe_100)
# [1] 33 55


# I want to combine two dataframes. I want to add two columns ("Bottle ID", "Collection Date") 
# from this df metadataDataSciBGT_only to the df HOT1_meta_dataframe_100, to know how to add them, 
#one can match "biosample" (HOT1_meta_dataframe_100 ) = "NCBI BioSample" (metadataDataSciBGT_only)


# Select only the columns of interest from metadataDataSciBGT_only
metadata_subset <- metadataDataSciHOT1_only[, c("NCBI BioSample", "Bottle ID", "Collection Date")]

# Rename the column in metadata_subset to match with HOT1_meta_dataframe_100 and add _pub suffix to the others
colnames(metadata_subset) <- c("biosample", "Bottle ID_pub", "Collection Date_pub")

# Merge the dataframes
HOT1_pub_merged <- merge(HOT1_meta_dataframe_100, metadata_subset, by = "biosample")
dim(HOT1_pub_merged)
# [1]  33 57

# Function to clean and standardize column names
clean_column_names <- function(col_names) {
  col_names <- tolower(col_names) # Convert to lowercase
  col_names <- gsub("[ ]", "_", col_names) # Replace spaces with underscore
  col_names
}

# Apply the cleaning function to the column names
colnames(HOT1_pub_merged) <- clean_column_names(colnames(HOT1_pub_merged)) # for the data added with _pub

# Now we have the `bottle_id_pub` that we can use to combine it with the table from HOT DOG
# HOT1_pub_merged$bottle_id_pub

# ######## Let's do a test
# # Load the necessary libraries
# library(dplyr)
# 
# hotdog_data <- read.csv("data/HOT1_HOTDOG.txt", sep=",")
# 
# # Rename the column in hotdog_data
# colnames(hotdog_data)[colnames(hotdog_data) == "botid"] <- "bottle_id_pub"
# 
# # Add suffix '_dog' to all columns except the key column 'bottle_id_pub'
# colnames(hotdog_data)[colnames(hotdog_data) != "bottle_id_pub"] <- paste0(colnames(hotdog_data)[colnames(hotdog_data) != "bottle_id_pub"], "_dog")
# 
# # Ensure the key columns are of the same type
# HOT1_pub_merged$bottle_id_pub <- as.character(HOT1_pub_merged$bottle_id_pub)
# hotdog_data$bottle_id_pub <- as.character(hotdog_data$bottle_id_pub)
# 
# # Perform a left join to keep all rows from HOT1_pub_merged
# # (doing left join because the merge function removed all the data in the HOT1_pub_merged 
# # dataframe which did not have a corresponding row in hotdog_data. I don't want that. )
# HOT1_ENApubNdog_merged <- left_join(HOT1_pub_merged, hotdog_data, by = "bottle_id_pub")
# 
# # View the colnames of the new dataframe
# colnames(HOT1_ENApubNdog_merged)
# 
# # View the first few rows of the new dataframe
# head(HOT1_ENApubNdog_merged)

##### This worked

######## Let's do the real thing. 
# Load the necessary libraries
library(dplyr)

hotdog_data <- read.csv("data/hotdog20032010.csv", sep=",")
dim(hotdog_data)
# [1] 9913   17

# Rename the column in hotdog_data
colnames(hotdog_data)[colnames(hotdog_data) == "botid"] <- "bottle_id_pub"

# Add suffix '_dog' to all columns except the key column 'bottle_id_pub'
colnames(hotdog_data)[colnames(hotdog_data) != "bottle_id_pub"] <- paste0(colnames(hotdog_data)[colnames(hotdog_data) != "bottle_id_pub"], "_dog")

# Ensure the key columns are of the same type
HOT1_pub_merged$bottle_id_pub <- as.character(HOT1_pub_merged$bottle_id_pub)
hotdog_data$bottle_id_pub <- as.character(hotdog_data$bottle_id_pub)

# Perform a left join to keep all rows from HOT1_pub_merged
# (doing left join because the merge function removed all the data in the HOT1_pub_merged
# dataframe which did not have a corresponding row in hotdog_data. I don't want that. )
HOT1_pubNdog_merged <- left_join(HOT1_pub_merged, hotdog_data, by = "bottle_id_pub")

# View the colnames of the new dataframe
colnames(HOT1_pubNdog_merged)

# View the first few rows of the new dataframe
head(HOT1_pubNdog_merged)

dim(HOT1_pubNdog_merged)
# 33 73

#### for some bottles, there is no information (including both 2009 samples)
# checked, and it's also not in the HOTDOGs file, so not a merger error, more data availability

HOT1_pubNdog_merged$date_dog
HOT1_pubNdog_merged$bottle_id_pub
HOT1_pubNdog_merged$collection_date



#########################################################
# save it

fwrite(HOT1_pubNdog_merged, file = "data/HOT1_patch1.csv")



##########################################################

# latitude longitude
# - make combined lat_lon field from entries in `lat` and `lon` (MIxS compliant)
# 
# date
# - separate date (`collection_date` = 2004-02-24) into year, month, day
# - take `time_dog` " 214957" and format into 21:49:57
# - and make additional column called `local_time_dog` and add the result of 21:49:57 - 10 h in there
# # Info from https://hahana.soest.hawaii.edu/hot/hot-dogs/documentation/example1.html: Date & time are in GMT. Subtract 10 hours to get local time (HST).
# 
# Filtration
# - add filter sizes (get from publication)
# - first note this as `size_frac_low` (0.22) and `size_frac_up` (NA)
# - then concatonate into `size_frac` (MIxS)
# - add `samp_size` with volume of water collected (500 ml)
# - add `samp_vol_we_dna_ext` with volume of water filtered (100 ml)
# 
# environmental metadata
# - rename `temp_dog` to `temperature_dog`
# - rename `bsal_dog` to `salinity_dog` (taking bsal_dog instead of csal_dog because the latter is missing a value and bottle salinity might be more accurate than CTD)


# Load necessary libraries
library(dplyr)
library(tidyr)
library(lubridate)


# Create a new dataframe to keep the original dataframe safe
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged



#### patch with info from publication text

# Add size fraction thresholds and concatenate into size_frac
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
  mutate(size_frac_low = 0.22,
         size_frac_up = NA,
         size_frac = paste(size_frac_low, size_frac_up, sep = "-"))

# Add samp_size and samp_vol_we_dna_ext columns
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
  mutate(samp_size = 500,
         samp_vol_we_dna_ext = 100)

# add layer information
# Convert collection_date to Date type if it is not already
HOT1_pubNdog_merged_patch2$collection_date <- as.Date(HOT1_pubNdog_merged_patch2$collection_date)

# Define the new dataframe with the 'layer' column
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
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
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
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
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
  mutate(lat_lon = paste(latitude, longitude, sep = " "))


# Separate the collection_date into year, month, day
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
  mutate(
    year = year(ymd(collection_date)),
    month = month(ymd(collection_date)),
    day = day(ymd(collection_date))
  )

# Format the time_dog column into HH:MM:SS (will only work for the samples that had data there)
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
  mutate(
    time = format(strptime(time_dog, format="%H%M%S"), format="%H:%M:%S")
  )

# Create the local_time_dog column by subtracting 10 hours from formatted_time_dog
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
  mutate(
    local_time = format(strptime(time, format="%H:%M:%S") - hours(10), format="%H:%M:%S")
  )



# Rename columns for environmental metadata
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
  rename(
    pressure_dbar = press_dog,
    temperature_degC = temp_dog,
    salinity_pss = bsal_dog
    )

# Remove columns with non-values (e.g. -9.00 showing that it was not measured)
# and remove csal_dog because we are using bsal_dog (has more values)
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2 %>%
  select(-csal_dog, -coxy_dog, -boxy_dog, -dic_dog, -ph_dog, -phos_dog, -sil_dog, -doc_dog, -chl_dog, -no2_dog, -X_dog)


# remove any samples that have NA or empty values in `temperature_degC` HOT1_pubNdog_merged_patch2
HOT1_pubNdog_merged_patch2 <- HOT1_pubNdog_merged_patch2[!is.na(HOT1_pubNdog_merged_patch2$temperature_degC) & HOT1_pubNdog_merged_patch2$temperature_degC != "", ]
dim(HOT1_pubNdog_merged_patch2)
# [1] 28 75
# 5 removed

HOT1_pubNdog_merged_patch2$environmental_package <- "water"


######################################
# save it

fwrite(HOT1_pubNdog_merged_patch2, file = "data/HOT1_patch2.csv")

