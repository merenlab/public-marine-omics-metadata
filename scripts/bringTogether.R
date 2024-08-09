### Bring together

# Display unique entries count for both biosample and run columns for each dataframe
cat("OSD_patch2 - biosample:", count_unique_entries(OSD_patch2, "biosample"), ", run:", count_unique_entries(OSD_patch2, "run"), "\n")
cat("MAL_pub_merged_patch2 - biosample:", count_unique_entries(MAL_pub_merged_patch2, "biosample"), ", run:", count_unique_entries(MAL_pub_merged_patch2, "run"), "\n")
cat("TARA_patch2 - biosample:", count_unique_entries(TARA_patch2, "biosample"), ", run:", count_unique_entries(TARA_patch2, "run"), "\n")
cat("BGS_pub_merged_patch2 - biosample:", count_unique_entries(BGS_pub_merged_patch2, "biosample"), ", run:", count_unique_entries(BGS_pub_merged_patch2, "run"), "\n")
cat("HOT1_pubNdog_merged_patch2 - biosample:", count_unique_entries(HOT1_pubNdog_merged_patch2, "biosample"), ", run:", count_unique_entries(HOT1_pubNdog_merged_patch2, "run"), "\n")
cat("HOT3_patch2 - biosample:", count_unique_entries(HOT3_patch2, "biosample"), ", run:", count_unique_entries(HOT3_patch2, "run"), "\n")
cat("BATS_edu_merged_patch2 - biosample:", count_unique_entries(BATS_edu_merged_patch2, "biosample"), ", run:", count_unique_entries(BATS_edu_merged_patch2, "run"), "\n")
cat("BGT_pubNbodc_merged_patch2 - biosample:", count_unique_entries(BGT_pubNbodc_merged_patch2, "biosample"), ", run:", count_unique_entries(BGT_pubNbodc_merged_patch2, "run"), "\n")

# Step 1: Add 'project' column to each dataframe
BGT_pubNbodc_merged_patch2$project <- "BGT"
HOT1_pubNdog_merged_patch2$project <- "HOT1"
BATS_edu_merged_patch2$project <- "BATS"
MAL_pub_merged_patch2$project <- "MAL"
TARA_patch2$project <- "TARA"
OSD_patch2$project <- "OSD"
BGS_pub_merged_patch2$project <- "BGS"
HOT3_patch2$project <- "HOT3"

# Step 2: Identify common columns (including the new 'project' column)
common_columns <- Reduce(intersect, list(
  colnames(BGT_pubNbodc_merged_patch2),
  colnames(HOT1_pubNdog_merged_patch2),
  colnames(BATS_edu_merged_patch2),
  colnames(MAL_pub_merged_patch2),
  colnames(TARA_patch2),
  colnames(OSD_patch2),
  colnames(BGS_pub_merged_patch2),
  colnames(HOT3_patch2)
))

# Step 3: Define a function to rename non-common columns and keep 'project' column intact
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

# Create copies of the original dataframes and apply renaming
BGT_pubNbodc_copy <- rename_conflicting_columns(BGT_pubNbodc_merged_patch2, common_columns, "BGT")
HOT1_pubNdog_copy <- rename_conflicting_columns(HOT1_pubNdog_merged_patch2, common_columns, "HOT1")
BATS_edu_copy <- rename_conflicting_columns(BATS_edu_merged_patch2, common_columns, "BATS")
MAL_pub_copy <- rename_conflicting_columns(MAL_pub_merged_patch2, common_columns, "MAL")
TARA_copy <- rename_conflicting_columns(TARA_patch2, common_columns, "TARA")
OSD_copy <- rename_conflicting_columns(OSD_patch2, common_columns, "OSD")
BGS_pub_copy <- rename_conflicting_columns(BGS_pub_merged_patch2, common_columns, "BGS")
HOT3_copy <- rename_conflicting_columns(HOT3_patch2, common_columns, "HOT3")

# Step 4: Merge dataframes using full outer join on common columns
all_projects <- Reduce(function(x, y) merge(x, y, by = common_columns, all = TRUE), 
                       list(BGT_pubNbodc_copy, HOT1_pubNdog_copy, 
                            BATS_edu_copy, MAL_pub_copy, 
                            TARA_copy, OSD_copy, BGS_pub_copy, 
                            HOT3_copy))

# Step 5: Reorder columns so that related columns are grouped together
non_common_cols <- setdiff(colnames(all_projects), common_columns)
grouped_cols <- unique(sub("_[^_]+$", "", non_common_cols))
final_order <- c(common_columns, unlist(sapply(grouped_cols, function(col) {
  grep(col, colnames(all_projects), value = TRUE)
})))

# Reorder the dataframe
all_projects <- all_projects[, final_order]

# View the final merged dataframe
head(all_projects)
dim(all_projects)
# [1] 2036  393

write.table(all_projects, "data/all_projects.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# Select only the common columns in the new dataframe
common_all_projects <- all_projects[, common_columns]
dim(common_all_projects)
# [1] 2036   61

write.table(common_all_projects, "data/metagenomes.txt", sep = "\t", row.names = FALSE, quote = FALSE)





################################################################################

## patch further
# add season information based on lat_lon and date

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

# Convert collection_date to Date type
common_all_projects$collection_date <- as.Date(common_all_projects$collection_date)

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




##########################################
## add column containing info on coastal VS open ocean

install.packages("sp")
install.packages("rnaturalearth")
install.packages("rnaturalearthdata")
install.packages("dplyr")
install.packages("sf")

library(sp)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(sf)

##### May redo, because 50 km coastal only  applies sometimes (not sure about HOT)


# Convert to sf object
coordinates <- st_as_sf(common_all_projects, coords = c("longitude", "latitude"), crs = 4326)

# Load natural earth data for coastline
coastline <- ne_download(scale = "medium", type = "coastline", category = "physical", returnclass = "sf")

# Check if points are within a certain distance from the coast (e.g., 50 km)
buffered_coastline <- st_buffer(coastline, dist = 50000) # distance in meters

# Determine if points are within the buffered coastline
common_all_projects$environment <- ifelse(st_intersects(coordinates, buffered_coastline, sparse = FALSE), "Coastal", "Open Ocean")
