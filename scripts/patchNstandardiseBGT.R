# patchBGT

# Patch metadata for bioGEOTRACERS

# https://github.com/merenlab/public-marine-omics-metadata/issues/1


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

# Import table 

metadataDataSciBGT <- read.csv(
  "data/metadataDataSciBGT.csv", 
  stringsAsFactors = FALSE, 
  check.names = FALSE
)
head(metadataDataSciBGT)
dim(metadataDataSciBGT)
#[1] 610  21

# worked :)

# Only keep the GEOTRACES rows (removing HOT and BATS)
metadataDataSciBGT_only <- metadataDataSciBGT %>% dplyr::filter(grepl("GEOTRACES", `Cruise series`))
dim(metadataDataSciBGT_only)
# [1] 480  21

# check if same as the one we want to merge it with
dim(BGT_meta_dataframe_100)
# [1] 323 57

head(BGT_meta_dataframe_100)

# I want to combine two dataframes. I want to add two columns ("Bottle ID", "Collection Date") 
# from this df metadataDataSciBGT_only to the df BGT_meta_dataframe_100, to know how to add them, 
#one can match "biosample" (BGT_meta_dataframe_100 ) = "NCBI BioSample" (metadataDataSciBGT_only)


# Select only the columns of interest from metadataDataSciBGT_only
metadata_subset <- metadataDataSciBGT_only[, c("NCBI BioSample", "Bottle ID", "Collection Date")]

# Rename the column in metadata_subset to match with BGT_meta_dataframe_100 and add _pub suffix to the others
colnames(metadata_subset) <- c("biosample", "Bottle ID_pub", "Collection Date_pub")

# Merge the dataframes
BGT_pub_merged <- merge(BGT_meta_dataframe_100, metadata_subset, by = "biosample")
dim(BGT_pub_merged)
# [1] 323 59

head(BGT_pub_merged$bottle_id)
# [1] "631397" "631391" "631388" "631829" "631823" "631820"
head(BGT_pub_merged$`Bottle ID_pub`)
# [1] 631397 631391 631388 631829 631823 631820

# Now we have the `Bottle ID` that we can use to combine it with the table from 
# https://www.bodc.ac.uk/geotraces/








## Add env metadata
## from https://www.bodc.ac.uk/geotraces/
# Already downloaded 
# The table has a lot of info on top that explains the variables mentioned in the table
# I removed that manually (up to the `Cruise` column header)
# I also removed all entries that have no metagenome sample accession number attached
# (R would always crash during the upload otherwise)
# I also had to remove the apostrophe in the "operator's.cruise.name"

# Import 
metadataBODC_BGT <- read.table(
  "data/myDataOnlyIDP2021_v2_GEOTRACES_IDP2021_Seawater_Discrete_Sample_Data_v2_nkjMMenH_test.tsv", 
  header = TRUE, 
  sep = "\t", 
  na.strings = "NA", 
  stringsAsFactors = FALSE
)

head(metadataBODC_BGT)
dim(metadataBODC_BGT)
# [1] 480 180

## Check if there are any columns that only have NAs
# Create a logical vector indicating whether each column contains only NAs
columns_with_only_na <- apply(metadataBODC_BGT, 2, function(x) all(is.na(x)))

# Print the names of columns that only contain NA values
na_only_columns <- names(metadataBODC_BGT)[columns_with_only_na]
print(na_only_columns)

# Remove these columns from the data frame
metadataBODC_BGT_clean <- metadataBODC_BGT[, !columns_with_only_na]

# Check dimensions
dim(metadataBODC_BGT_clean)
# [1] 480 138


#### remove all QV:SEADATANET columns
# Print column names to verify the pattern
colnames(metadataBODC_BGT_clean)

# Identify columns that contain "QV:SEADATANET" in their names
cols_to_remove <- grep("QV\\.SEADATANET\\.[0-9]+", colnames(metadataBODC_BGT_clean))

# Print the names of columns to be removed to double-check
print(cols_to_remove)

# Remove these columns from the dataframe
metadataBODC_BGT_clean <- metadataBODC_BGT_clean[, -cols_to_remove]

# Display the dimensions of the modified dataframe
dim(metadataBODC_BGT_clean)
# [1] 480  57

# Print the first few rows to verify
head(metadataBODC_BGT_clean)


##### update the column headers to not be such a mess
colnames(metadataBODC_BGT_clean)
colnames(BGT_pub_merged)


# Function to clean and standardize column names
clean_column_names <- function(col_names) {
  col_names <- tolower(col_names) # Convert to lowercase
  col_names <- gsub("[ ]", "_", col_names) # Replace spaces with underscore
  col_names <- gsub("[.]+", "_", col_names) # Replace multiple dots with underscore
  col_names <- gsub("[:]", "", col_names) # Remove colons
  col_names <- gsub("_+$", "", col_names) # Remove trailing underscores
  col_names
}

# Apply the cleaning function to the column names
colnames(metadataBODC_BGT_clean) <- clean_column_names(colnames(metadataBODC_BGT_clean))
colnames(BGT_pub_merged) <- clean_column_names(colnames(BGT_pub_merged)) # for the data added with _pub


### merge data frames
# Manually rename the columns for merging
colnames(metadataBODC_BGT_clean)[colnames(metadataBODC_BGT_clean) == "bodc_bottle_number"] <- "bottle_id_pub"

# Add a _bodc suffix to all other columns in metadataBODC_BGT_clean
colnames(metadataBODC_BGT_clean) <- ifelse(colnames(metadataBODC_BGT_clean) == "bottle_id_pub",
                                           "bottle_id_pub",
                                           paste0(colnames(metadataBODC_BGT_clean), "_bodc"))

# Merge the dataframes
BGT_pubNbodc_merged <- merge(BGT_pub_merged, metadataBODC_BGT_clean, by = "bottle_id_pub")

# Display the dimensions of the merged dataframe
dim(BGT_pubNbodc_merged)
# [1] 323 115

#########################################################
# save it

fwrite(BGT_pubNbodc_merged, file = "data/BGT_patch1.csv")



##########################################################

# latitude longitude
# - make combined lat_lon field from entries in `lat` and `lon` (MIxS compliant)
# 
# data
# - separate date (`collection_date_pub` = 2010-10-26T06:22:00) into year, month, day, time
# 
# Filtration
# - add filter sizes (get from publication)
# - first note this as `size_frac_low` (0.22) and `size_frac_up` (NA)
# - then concatonate into `size_frac` (MIxS)
# - add `samp_size` with volume of water collected (500 ml) 
# - add `samp_vol_we_dna_ext` with volume of water filtered (100 ml)
# 
# environmental metadata
# - rename `ctdtmp_t_value_sensor_deg_c_bodc` to `temperature_bodc`
# - rename `salinity_d_conc_bottle_bodc` to `salinity_bodc`


# Load necessary libraries
library(dplyr)
library(tidyr)

# Create a new dataframe to keep the original dataframe safe
BGT_pubNbodc_merged_patch2 <- BGT_pubNbodc_merged


### patch with info from publication text

# Add size fraction thresholds and concatenate into size_frac
BGT_pubNbodc_merged_patch2 <- BGT_pubNbodc_merged_patch2 %>%
  mutate(size_frac_low = 0.22,
         size_frac_up = NA,
         size_frac = paste(size_frac_low, size_frac_up, sep = "-"))


# Add samp_size and samp_vol_we_dna_ext columns
BGT_pubNbodc_merged_patch2 <- BGT_pubNbodc_merged_patch2 %>%
  mutate(samp_size = 500,
         samp_vol_we_dna_ext = 100)


#### rearrange data

# Separate lat_lon into latitude and longitude and make into decimal values
BGT_pubNbodc_merged_patch2 <- BGT_pubNbodc_merged_patch2 %>%
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
BGT_pubNbodc_merged_patch2 <- BGT_pubNbodc_merged_patch2 %>%
  mutate(lat_lon = paste(latitude, longitude, sep = " "))



# Separate collection_date_pub into year, month, day, and time
BGT_pubNbodc_merged_patch2 <- BGT_pubNbodc_merged_patch2 %>%
  separate(collection_date_pub, into = c("date", "time"), sep = "T") %>%
  separate(date, into = c("year", "month", "day"), sep = "-")



# Rename columns for environmental metadata
BGT_pubNbodc_merged_patch2 <- BGT_pubNbodc_merged_patch2 %>%
  rename(temperature_degC = ctdtmp_t_value_sensor_deg_c_bodc,
         salinity_pss = ctdsal_d_conc_sensor_pss_78_bodc,
         oxygen_umolKg = ctdoxy_d_conc_sensor_umol_kg_bodc,
         phosphate_umolKg = phosphate_d_conc_bottle_umol_kg_bodc, 
         silicate_umolKg = silicate_d_conc_bottle_umol_kg_bodc,
         nitrate_umolKg = nitrate_d_conc_bottle_umol_kg_bodc,
         nitrite_umolKg = nitrite_d_conc_bottle_umol_kg_bodc, 
         dic_umolKg = dic_d_conc_bottle_umol_kg_bodc,
         doc_umolKg = doc_d_conc_bottle_umol_kg_bodc,
         chla_ngL = chl_a_hplc_tp_conc_bottle_ng_liter_bodc,
         chlb_ngL = chl_b_hplc_tp_conc_bottle_ng_liter_bodc,
         chlc_ngL = chl_c3_hplc_tp_conc_bottle_ng_liter_bodc
         )

# add empty column on layer
BGT_pubNbodc_merged_patch2$layer <- NA

# add empty column on local_time
BGT_pubNbodc_merged_patch2$local_time <- NA

# add column on enviornmental_package
BGT_pubNbodc_merged_patch2$environmental_package <- "water"



######################################
# save it

fwrite(BGT_pubNbodc_merged_patch2, file = "data/BGT_patch2.csv")
