# patchBGS

# Patch metadata for Bio-GO-SHIP

# Bio-GO-SHIP PRJNA656268	filter lower threshold: 0.22; water filtered: 2–10
# https://doi.org/10.1038/s41597-021-00889-9


####################################
## prep
####################################

# Install and load necessary packages
if (!require(readxl)) install.packages("readxl")
library(readxl)

library(dplyr)

# Set working directory
setwd("/Users/rameyer/Documents/_P3/P3dataAnalysis/P3_metadata/public-marine-omics-metadata/")

####################################
## go
####################################

########################## 

# Define the URL of the Excel file associated with the BGS data paper
# https://doi.org/10.1038/s41597-021-00889-9 in the Supplementary material
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41597-021-00889-9/MediaObjects/41597_2021_889_MOESM1_ESM.xlsx"

# Download the Excel file
download.file(url, destfile = "data/BGSpubMetadata.xlsx", mode = "wb")

# Read the third sheet from the Excel file
BGS_pub_metadata <- read_excel("data/BGSpubMetadata.xlsx", sheet = 1)
head(BGS_pub_metadata)

dim(BGS_pub_metadata)
# [1] 971  19
colnames(BGS_pub_metadata)
colnames(BGS_meta_dataframe_100)

# update column names
# Custom renaming function
rename_column <- function(col_name) {
  col_name %>%
    tolower() %>%               # Convert to lower case
    gsub(" ", "_", .) %>%       # Replace spaces with underscores
    gsub("-", "_", .) %>%       # Replace dashes with underscores
    gsub("\\.", "_", .) %>%     # Replace periods with underscores
    gsub("\\[", "", .) %>%      # Remove opening parentheses
    gsub("\\]", "", .) %>%      # Remove closing parentheses
    gsub("/","_", .) %>%        # Replace slashes with underscores
    gsub("_+", "_", .) %>%      # Replace multiple underscores with a single underscore
    gsub("_+$", "", .)          # Remove trailing underscores
}

# use on the publication table
BGS_pub_metadata <- BGS_pub_metadata %>%
  rename_with(rename_column)
colnames(BGS_pub_metadata)

colnames(BGS_pub_metadata)[colnames(BGS_pub_metadata) != "sra_accession_number"] <- paste0(colnames(BGS_pub_metadata)[colnames(BGS_pub_metadata) != "sra_accession_number"], "_pub")



# Perform the left join between BGS_pub_metadata and BGS_meta_dataframe_100
BGS_pub_merged <- BGS_meta_dataframe_100 %>%
  left_join(BGS_pub_metadata, by = c("biosample" = "sra_accession_number"))

# Remove the depth column I had added in checkNpatchNfilterDepth.R with more accurate depth measurements
BGS_pub_merged <- BGS_pub_merged %>%
  select(-depth) %>%          # Remove the existing 'depth' column
  rename(depth = depth_m_pub) # Rename 'depth_m_pub' to 'depth'
BGS_pub_merged$depth

BGS_pub_merged <- BGS_pub_merged %>%
  filter(depth <= 100)

dim(BGS_meta_dataframe_100)
# [1] 971  57
dim(BGS_pub_merged)
# [1] 969  74
#View(BGS_pub_merged)


cat("BGS_pub_merged - biosample:", count_unique_entries(BGS_pub_merged, "biosample"), ", run:", count_unique_entries(BGS_pub_merged, "run"), "\n")






#########################################################
# save it

fwrite(BGS_pub_merged, file = "data/BGS_patch1.csv")


##########################################################
# patch and standardise 


# Load necessary libraries
library(dplyr)
library(tidyr)
library(lubridate)


# Create a new dataframe to keep the original dataframe safe
BGS_pub_merged_patch2 <- BGS_pub_merged


################################################################ 
#### patch with info from publication text

# Add samp_size and samp_vol_we_dna_ext columns
# Range of 10‐20 found in	https://store.pangaea.de/Projects/OSD_2014/OSD_Handbook_v2_June_2014.pdf 

# Add size fraction thresholds and concatenate into size_frac
BGS_pub_merged_patch2 <- BGS_pub_merged_patch2 %>%
  mutate(size_fraction_lower_threshold = 0.22,
         size_fraction_upper_threshold = NA,
         size_frac = paste(size_fraction_lower_threshold, size_fraction_upper_threshold, sep = "-"))




################################################################
#### rearrange data

library(dplyr)
library(stringr)
# install.packages("tidyverse")
library(tidyverse)


# Separate lat_lon into latitude and longitude and make into decimal values
BGS_pub_merged_patch2 <- BGS_pub_merged_patch2 %>%
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
BGS_pub_merged_patch2 <- BGS_pub_merged_patch2 %>%
  mutate(lat_lon = paste(latitude, longitude, sep = " "))

BGS_pub_merged_patch2$lat_lon

##########
# Format the time
BGS_pub_merged_patch2 <- BGS_pub_merged_patch2 %>%
  mutate(
    year = as.integer(format(as.POSIXct(collection_date, format="%Y-%m-%dT%H:%M:%SZ"), "%Y")),
    month = format(as.POSIXct(collection_date, format="%Y-%m-%dT%H:%M:%SZ"), "%m"),
    day = format(as.POSIXct(collection_date, format="%Y-%m-%dT%H:%M:%SZ"), "%d"),
    time = format(as.POSIXct(collection_date, format="%Y-%m-%dT%H:%M:%SZ"), "%H:%M:%S"),
    collection_date = as.Date(collection_date)
  )
BGS_pub_merged_patch2$year
BGS_pub_merged_patch2$month
BGS_pub_merged_patch2$day
BGS_pub_merged_patch2$time


# create local time
BGS_pub_merged_patch2$local_time <- sprintf("%02d:%02d", BGS_pub_merged_patch2$local_hour_pub, BGS_pub_merged_patch2$local_minute_pub)


# make layer column, adding "surface water" for all 
BGS_pub_merged_patch2 <- BGS_pub_merged_patch2 %>%
  mutate(layer = "surface water")
BGS_pub_merged_patch2$layer


# Rename columns for environmental metadata
BGS_pub_merged_patch2 <- BGS_pub_merged_patch2 %>%
  rename(
    temperature_degC = temperature_deg_c_pub,
    phosphate_umolKg = phosphate_bottle_umol_l_1_pub
  )

# add empty columns to match other dfs
BGS_pub_merged_patch2$samp_size <- NA

BGS_pub_merged_patch2$samp_vol_we_dna_ext <- NA

BGS_pub_merged_patch2$salinity_pss <- NA

BGS_pub_merged_patch2$environmental_package <- "water"

colnames(BGS_pub_merged_patch2)
head(BGS_pub_merged_patch2)
dim(BGS_pub_merged_patch2)
# [1] 969  89

######################################
# save it

fwrite(BGS_pub_merged_patch2, file = "data/BGS_patch2.csv")















# 
# ################################################################################
# ### Get first metadata file as described in https://github.com/merenlab/public-marine-omics-metadata/issues/4
# 
# # CCHDO Citation Information
# # |
# # | Please cite data downloaded from CCHDO as:
# # | [Data providers of the parameter(s) used]. [Year of file access]. [CTD/Bottle] data from cruise [expocode],
# # | [format version used]. Accessed from CCHDO [url of cruise data page]. Access date [date of download].
# # | [Applicable CCHDO cruise DOI if provided].
# # |
# # | For example:
# # | Swift, J. and Becker, S. 2019. CTD data from Cruise 33RR20160321, exchange version. Accessed from CCHDO
# # | https://cchdo.ucsd.edu/cruise/33RR20160321. Access date 2019-08-21. CCHDO cruise DOI: 10.7942/C2008W
# 
# metadataI07N_BGS <- read.csv(
#   "data/33RO20180423_hy1.csv", 
#   stringsAsFactors = FALSE, 
#   check.names = FALSE
# )
# colnames(metadataI07N_BGS)
# head(metadataI07N_BGS)
# dim(metadataI07N_BGS)
# # [1] 3004   65
# 
# # rename column headers on the publication table
# metadataI07N_BGS <- metadataI07N_BGS %>%
#   rename_with(rename_column)
# colnames(metadataI07N_BGS)
# 
# #########################################
# # # Test merge
# # 
# # # Separate the sample_alias into sect_id and sampno
# # BGS_meta_dataframe_100 <- BGS_meta_dataframe_100 %>%
# #   separate(sample_alias, into = c("sect_id_year", "sampno"), sep = "_", convert = TRUE) %>%
# #   mutate(
# #     sect_id = substr(sect_id_year, 1, 3),  # Extract the sect_id
# #     sampno = as.integer(sampno)            # Convert sampno to integer for matching
# #   ) %>%
# #   select(-sect_id_year)  # Remove the temporary column
# # 
# # # Rename columns in metadataI07N_BGS to add suffix
# # metadataI07N_BGS <- metadataI07N_BGS %>%
# #   rename_with(~ paste0(., "_cchdo"), -c(sect_id, sampno))
# # colnames(metadataI07N_BGS)
# # 
# # 
# # # Join the dataframes
# # linked_dataframe <- BGS_meta_dataframe_100 %>%
# #   left_join(metadataI07N_BGS, by = c("sect_id", "sampno"))
# # 
# # colnames(metadataI07N_BGS)
# # colnames(linked_dataframe)
# # head(linked_dataframe)
# # dim(linked_dataframe)
# 
# 
# ###############################################################################
# # Get second metadata frame I09N 33RR20160321_hy1
# # data provider(s), cruise name or cruise ID, data file name(s) CLIVAR and Carbon Hydrographic Data Office, La Jolla, CA, USA, and data file date."" For further information", please contact one of the parties listed above or cchdo@ucsd.edu. Users are also requested to acknowledge the NSF/NOAA-funded U.S. Repeat Hydrography Program in publications resulting from their use. 
# 
# metadataI09N_BGS <- read.csv(
#   "data/33RR20160321_hy1.csv", 
#   stringsAsFactors = FALSE, 
#   check.names = FALSE
# )
# colnames(metadataI09N_BGS)
# head(metadataI09N_BGS)
# dim(metadataI09N_BGS)
# # [1] 4069  127
# 
# # rename column headers on the publication table
# metadataI09N_BGS <- metadataI09N_BGS %>%
#   rename_with(rename_column)
# colnames(metadataI09N_BGS)
# 
# #View(metadataI09N_BGS)
# 
# 
# ################################################################################
# # Get third C13.5*/A13.5  https://doi.org/10.7942/C2894Zs
# 
# ## DOI not found
# 
# 
# ################################################################################
# # Get fourth P18 https://doi.org/10.7942/C21T0F
# 
# # CCHDO Citation Information
# #|
# #| Please cite data downloaded from CCHDO as: 
# #| [Data providers of the parameter(s) used]. [Year of file access]. [CTD/Bottle] data from cruise [expocode], 
# #| [format version used]. Accessed from CCHDO [url of cruise data page]. Access date [date of download].
# #| [Applicable CCHDO cruise DOI if provided].
# #|
# #| For example: 
# #| Swift, J. and Becker, S. 2019. CTD data from Cruise 33RR20160321, exchange version. Accessed from CCHDO 
# #| https://cchdo.ucsd.edu/cruise/33RR20160321. Access date 2019-08-21. CCHDO cruise DOI: 10.7942/C2008W
# 
# 
# metadataP18_BGS <- read.csv(
#   "data/33RO20161119_hy1.csv", 
#   stringsAsFactors = FALSE, 
#   check.names = FALSE
# )
# colnames(metadataP18_BGS)
# head(metadataP18_BGS)
# dim(metadataP18_BGS)
# # [1] 5101   93
# 
# # rename column headers on the publication table
# metadataP18_BGS <- metadataP18_BGS %>%
#   rename_with(rename_column)
# colnames(metadataP18_BGS)
# 
# #View(metadataP18_BGS)
# 
# 
# ################################################################################
# # Get fifth AMT-28 https://doi.org/10/fqkd
# 
# # ( this one is a bit different)
# 
# # Load necessary packages
# library(dplyr)
# #install.packages("readr")
# library(readr)
# 
# 
# # Define the directory containing the files
# directory <- "data/RN-20240730141451_B8C6056ADB747453E0536C86ABC00CE5"
# 
# # Get the list of all .txt files in the directory
# file_list <- list.files(path = directory, pattern = "\\.txt$", full.names = TRUE)
# 
# # Function to read and clean a single file
# clean_file <- function(file_path) {
#   # Read the file
#   lines <- read_lines(file_path)
#   
#   # Find the line number where "Cruise" appears
#   start_line <- grep("^Cruise", lines)
#   
#   # If the "Cruise" line is found, read the data from that line onwards
#   if (length(start_line) > 0) {
#     cleaned_data <- read.table(text = lines[start_line:length(lines)], header = TRUE, sep = "\t")
#     return(cleaned_data)
#   } else {
#     warning(paste("No 'Cruise' line found in", file_path))
#     return(NULL)
#   }
# }
# 
# # Apply the cleaning function to all files and store the results in a list
# cleaned_data_list <- lapply(file_list, clean_file)
# 
# # Combine all cleaned data into a single data frame
# metadataAMT28_BGS <- bind_rows(cleaned_data_list)
# dim(metadataAMT28_BGS)
# # [1] 43117    43
# head(metadataAMT28_BGS)
# 
# 
# # rename column headers 
# metadataAMT28_BGS <- metadataAMT28_BGS %>%
#   rename_with(rename_column)
# colnames(metadataAMT28_BGS)
# 
# 
# # Filter out rows with NA or empty strings in 'Cruise' and 'Station' columns
# metadataAMT28_BGS <- metadataAMT28_BGS %>%
#   filter(!is.na(cruise) & cruise != "" & !is.na(station) & station != "")
# 
# dim(metadataAMT28_BGS)
# # [1] 63 43
# 
# # rename the columns it has in common with the other dfs and that I want to match the others
# metadataAMT28_BGS <- metadataAMT28_BGS %>%
#   rename(
#     ctdprs = pres_z_dbar
#   ) %>%
#   mutate(
#     salnty = p_sal_ctd2_dmnless,
#     ctdsal = p_sal_ctd2_dmnless
#   )
# colnames(metadataAMT28_BGS)
# 
# # make it such that the columns that we will use to map to between dfs are of the same structure and name as those in the dfs above
# # add a column called `sect_id` which adds the value `AMT` and a add a column called `sampno` which takes the part of `station ` that comes after _CTD (so in JR18001_CTD001 that would be 001)
# metadataAMT28_BGS <- metadataAMT28_BGS %>%
#   mutate(
#     sect_id = "AMT",
#     sampno = sub(".*_CTD(.*)", "\\1", station)
#   )
# metadataAMT28_BGS$station
# metadataAMT28_BGS$sect_id
# metadataAMT28_BGS$sampno
# 
# ####### remove all the qv_seadatanet columns
# # Use grepl to identify columns with 'qv_seadatanet' in their names
# cols_to_remove <- grepl("qv_seadatanet", colnames(metadataAMT28_BGS))
# 
# # Subset the dataframe to exclude these columns
# metadataAMT28_BGS <- metadataAMT28_BGS[, !cols_to_remove]
# 
# # Display the column names of the cleaned dataframe
# colnames(metadataAMT28_BGS)
# 
# 
# ################################################################################
# # Get sixth NH1418 https://doi.org/10.26008/1912/bco-dmo.829895.1
# 
# metadataNH1418_BGS <- read.csv(
#   "data/download_NH1418", 
#   stringsAsFactors = FALSE, 
#   sep = "\t",
#   check.names = FALSE
# )
# colnames(metadataNH1418_BGS)
# head(metadataNH1418_BGS)
# dim(metadataNH1418_BGS)
# # [1] 191  35
# 
# # rename column headers on the publication table
# metadataNH1418_BGS <- metadataNH1418_BGS %>%
#   rename_with(rename_column)
# colnames(metadataNH1418_BGS)
# 
# 
# 
# ################################################################################
# # Get seventh AE1319 https://doi.org/10.26008/1912/bco-dmo.829797.1 
# 
# metadataAE1319_BGS <- read.csv(
#   "data/downloadAE1319", 
#   stringsAsFactors = FALSE, 
#   sep = "\t",
#   check.names = FALSE
# )
# colnames(metadataAE1319_BGS)
# head(metadataAE1319_BGS)
# dim(metadataAE1319_BGS)
# # [1] 128  13
# 
# # rename column headers on the publication table
# metadataAE1319_BGS <- metadataAE1319_BGS %>%
#   rename_with(rename_column)
# colnames(metadataAE1319_BGS)
# 
# 
# 
# ################################################################################
# # Get eighth BVAL46 https://doi.org/10.26008/1912/bco-dmo.829843.1 
# 
# 
# metadataBVAL46_BGS <- read.csv(
#   "data/download_BVAL46", 
#   stringsAsFactors = FALSE, 
#   sep = "\t",
#   check.names = FALSE
# )
# colnames(metadataBVAL46_BGS)
# head(metadataBVAL46_BGS)
# dim(metadataBVAL46_BGS)
# # [1] 99 13
# 
# # rename column headers on the publication table
# metadataBVAL46_BGS <- metadataBVAL46_BGS %>%
#   rename_with(rename_column)
# colnames(metadataBVAL46_BGS)
# 
# 
# 
# ################################################################################
# 
# ################################################################################
# 
# ################################################################################
# 
# #### How to combine it all?
# 
# 
# 
# 
# 
# ################################################################################
# # First, combine the dataframes that have similar structure
# 
# #install.packages("dplyr")
# library(dplyr)
# 
# ######################################
# # The first ones
# 
# dim(metadataI07N_BGS)
# # [1] 3004   65
# dim(metadataI09N_BGS)
# # [1] 4069  127
# dim(metadataP18_BGS)
# #[1] 5101   93
# dim(metadataAMT28_BGS)
# # [1] 63 30
# 
# colnames(metadataI07N_BGS)
# colnames(metadataI09N_BGS)
# colnames(metadataP18_BGS)
# colnames(metadataAMT28_BGS)
# 
# 
# 
# # Determine the data frame with the most columns
# max_col_df <- metadataI07N_BGS
# if (ncol(metadataI09N_BGS) > ncol(max_col_df)) max_col_df <- metadataI09N_BGS
# if (ncol(metadataP18_BGS) > ncol(max_col_df)) max_col_df <- metadataP18_BGS
# 
# # Add missing columns with NA values to each data frame
# metadataI07N_BGS[setdiff(names(max_col_df), names(metadataI07N_BGS))] <- NA
# metadataI09N_BGS[setdiff(names(max_col_df), names(metadataI09N_BGS))] <- NA
# metadataP18_BGS[setdiff(names(max_col_df), names(metadataP18_BGS))] <- NA
# 
# # Reorder columns to match the data frame with the most columns
# metadataI07N_BGS <- metadataI07N_BGS[, names(max_col_df)]
# metadataI09N_BGS <- metadataI09N_BGS[, names(max_col_df)]
# metadataP18_BGS <- metadataP18_BGS[, names(max_col_df)]
# 
# # Combining the data frames
# BGS_I07N_I09N_P18_metadata <- rbind(metadataI07N_BGS, metadataI09N_BGS, metadataP18_BGS)
# 
# # View the combined data frame
# dim(BGS_I07N_I09N_P18_metadata)
# # [1] 12174   127
# colnames(BGS_I07N_I09N_P18_metadata)
# 
# 
# # Identify columns in metadataAMT28_BGS that match columns in BGS_I07N_I09N_P18_metadata
# matching_cols <- intersect(names(BGS_I07N_I09N_P18_metadata), names(metadataAMT28_BGS))
# #matching_cols
# 
# # Subset metadataAMT28_BGS to keep only matching columns
# metadataAMT28_BGS_subset <- metadataAMT28_BGS[, matching_cols]
# 
# # Add missing columns with NA values to metadataAMT28_BGS_subset
# metadataAMT28_BGS_subset[setdiff(names(BGS_I07N_I09N_P18_metadata), names(metadataAMT28_BGS_subset))] <- NA
# 
# # Reorder columns in metadataAMT28_BGS_subset to match BGS_I07N_I09N_P18_metadata
# metadataAMT28_BGS_subset <- metadataAMT28_BGS_subset[, names(BGS_I07N_I09N_P18_metadata)]
# 
# # Combine all data frames
# BGS_I07N_I09N_P18_AMT28_metadata <- rbind(BGS_I07N_I09N_P18_metadata, metadataAMT28_BGS_subset)
# dim(BGS_I07N_I09N_P18_AMT28_metadata)
# # [1] 12237   127
# 
# 
# ######################################
# # The last three:
# dim(metadataNH1418_BGS)
# #[1] 191  35
# dim(metadataAE1319_BGS)
# # [1] 128  13
# dim(metadataBVAL46_BGS)
# # [1] 99 13
# 
# colnames(metadataNH1418_BGS)
# colnames(metadataAE1319_BGS)
# colnames(metadataBVAL46_BGS)
# 
# # Renaming columns to have a consistent naming across data frames
# metadataAE1319_BGS <- metadataAE1319_BGS %>%
#   rename(
#     oxygen_concentration = oxygen,
#     chla = ctd_chla
#   )
# 
# metadataBVAL46_BGS <- metadataBVAL46_BGS %>%
#   rename(
#     oxygen_concentration = oxygen,
#     chla = ctd_chla
#   )
# 
# # Adding missing columns with NA values
# missing_cols_AE1319 <- setdiff(colnames(metadataNH1418_BGS), colnames(metadataAE1319_BGS))
# missing_cols_BVAL46 <- setdiff(colnames(metadataNH1418_BGS), colnames(metadataBVAL46_BGS))
# 
# metadataAE1319_BGS[missing_cols_AE1319] <- NA
# metadataBVAL46_BGS[missing_cols_BVAL46] <- NA
# 
# # Reordering columns to match the primary data frame's column order
# metadataAE1319_BGS <- metadataAE1319_BGS[, colnames(metadataNH1418_BGS)]
# metadataBVAL46_BGS <- metadataBVAL46_BGS[, colnames(metadataNH1418_BGS)]
# 
# # Combining the data frames
# BGS_NH1418_AE1319_BVAL46_metadata <- rbind(metadataNH1418_BGS, metadataAE1319_BGS, metadataBVAL46_BGS)
# 
# # View the combined data frame
# head(BGS_NH1418_AE1319_BVAL46_metadata)
# dim(BGS_NH1418_AE1319_BVAL46_metadata)
# # [1] 418  35
# 
# 
# ################################################################################
# # Now standardise names between them 
# 
# ### first one
# colnames(BGS_I07N_I09N_P18_AMT28_metadata)
# head(BGS_I07N_I09N_P18_AMT28_metadata)
# 
# # rename to match our naming scheme
# BGS_I07N_I09N_P18_AMT28_metadata <- BGS_I07N_I09N_P18_AMT28_metadata %>%
#   rename(
#     cruise_id = sect_id,
#     sample_number = sampno,
#     pressure_dbar = ctdprs, 
#     temperature_degC = ctdtmp,
#     salinity_pss_ctd = ctdsal,
#     salinity_pss = salnty,
#     oxygen_umolKg_ctd = ctdoxy, 
#     oxygen_umolKg = oxygen, 
#     silicate_umolKg = silcat, 
#     nitrate_umolKg = nitrat, 
#     nitrite_umolKg = nitrit, 
#     phosphate_umolKg = phspht,
#     alkalinity_umolKg = alkali,
#     ph = ph_tot, 
#     doc_umolKg = doc
#   )
# 
# #keep: cruise_id, sample_number, date, time, latitude, longitude, depth, pressure_dbar, temperature_degC, salinity_pss_ctd, salinity_pss, oxygen_umolKg_ctd, oxygen_umolKg, silicate_umolKg, nitrate_umolKg, nitrite_umolKg, phosphate_umolKg, alkalinity_umolKg, ph, doc_umolKg
# # Select only the specified columns
# BGS_I07N_I09N_P18_AMT28_metadata_selected <- BGS_I07N_I09N_P18_AMT28_metadata %>%
#   select(cruise_id, sample_number, date, time, latitude, longitude, depth, 
#          pressure_dbar, temperature_degC, salinity_pss_ctd, salinity_pss, 
#          oxygen_umolKg_ctd, oxygen_umolKg, silicate_umolKg, nitrate_umolKg, 
#          nitrite_umolKg, phosphate_umolKg, alkalinity_umolKg, ph, doc_umolKg)
# 
# dim(BGS_I07N_I09N_P18_AMT28_metadata_selected)
# # [1] 12237    20
# 
# ### second one
# colnames(BGS_NH1418_AE1319_BVAL46_metadata)
# head(BGS_NH1418_AE1319_BVAL46_metadata)
# 
# 
# BGS_NH1418_AE1319_BVAL46_metadata <- BGS_NH1418_AE1319_BVAL46_metadata %>%
#   rename(
#     cruise_id = cruise,
#     temperature_degC = temperature,
#     salinity_pss = salinity,
#     oxygen_umolKg = oxygen_concentration, 
#     chla_ngL = chla, 
#     silicate_umolKg = nitrite, 
#     date = iso_datetime_utc, 
#     year = yrday_utc
#   )
# 
# colnames(BGS_NH1418_AE1319_BVAL46_metadata)
# BGS_NH1418_AE1319_BVAL46_metadata_selected <- BGS_NH1418_AE1319_BVAL46_metadata %>%
#   select(cruise_id, date, year, station, cast, latitude, longitude, depth, 
#          temperature_degC, salinity_pss, chla_ngL, oxygen_umolKg, silicate_umolKg)
# 
# head(BGS_NH1418_AE1319_BVAL46_metadata_selected)
# dim(BGS_NH1418_AE1319_BVAL46_metadata_selected)
# # [1] 418  13
# 
# 
# ################################################################################
# ### Connect
# 
# ########################################
# # Test merge
# library(dplyr)
# 
# # Separate cruise ID and sample ID in df1
# BGS_pub_merged_prep <- BGS_pub_merged %>%
#   mutate(
#     cruise = sub("(.+)\\d{4}_.+", "\\1", sample_alias),  # Remove last 4 digits before underscore and everything after
#     sample_number = sub(".+_", "", sample_alias)  # Extract sample ID
#   )
# View(BGS_pub_merged)
# 
# BGS_pub_merged_prep$cruise
# BGS_pub_merged_prep$sample_number
# dim(BGS_pub_merged_prep)
# # [1] 969  76
# 
# 
# BGS_I07N_I09N_P18_AMT28_metadata_selected$cruise
# tail(BGS_I07N_I09N_P18_AMT28_metadata_selected$sample_number)
# View(BGS_I07N_I09N_P18_AMT28_metadata_selected)
# # Rename columns in BGS_I07N_I09N_P18_AMT28_metadata_selected to add suffix
# BGS_I07N_I09N_P18_AMT28_metadata_selected_prep <- BGS_I07N_I09N_P18_AMT28_metadata_selected %>%
#   rename_with(~ paste0(., "_doi"), -c(cruise, sample_number))
# colnames(BGS_I07N_I09N_P18_AMT28_metadata_selected_prep)
# 
# 
# # Join the dataframes
# linked_dataframe <- BGS_pub_merged_prep %>%
#   left_join(BGS_I07N_I09N_P18_AMT28_metadata_selected_prep, by = c("cruise", "sample_number"))
# 
# colnames(BGS_I07N_I09N_P18_AMT28_metadata_selected_prep)
# colnames(linked_dataframe)
# head(linked_dataframe)
# dim(linked_dataframe)
# colnames(BGS_pub_merged)
# BGS_pub_merged$section_id_pub
