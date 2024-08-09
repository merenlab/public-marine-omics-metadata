# Export

# Set the working directory to one level above the script/ directory 
setwd("/Users/rameyer/Documents/_P3/P3dataAnalysis/P3_metadata/public-marine-omics-metadata/")

# Assuming you have already loaded these dataframes
# TARA_meta_dataframe_100 <- read.csv('data/TARA_metadata_save.tsv')
# Repeat for other dataframes...

# Ensure the data/ directory exists
if (!dir.exists("data")) {
  dir.create("data")
}

# List of dataframes with corresponding project names
dataframes <- list(
  TARA_patch2 = list(dataframe = TARA_patch2, project = "TARA"),
  OSD_patch2 = list(dataframe = OSD_patch2, project = "OSD"),
  BGS_pub_merged_patch2 = list(dataframe = BGS_pub_merged_patch2, project = "BGS"),
  BGT_pubNbodc_merged_patch2 = list(dataframe = BGT_pubNbodc_merged_patch2, project = "BGT"),
  MAL_pub_merged_patch2 = list(dataframe = MAL_pub_merged_patch2, project = "MAL"),
  HOT1_pubNdog_merged_patch2 = list(dataframe = HOT1_pubNdog_merged_patch2, project = "HOT1"),
  HOT3_patch2 = list(dataframe = HOT3_patch2, project = "HOT3"),
  BATS_edu_merged_patch2 = list(dataframe = BATS_edu_merged_patch2, project = "BATS")
)

# Create an empty list to hold all HOT run accessions with their respective study accessions
hot_run_accessions <- list()

for (name in names(dataframes)) {
  df <- dataframes[[name]]$dataframe
  project <- dataframes[[name]]$project
  
  # Extract the run and bioproject columns
  run_accessions <- df$run
  study_accession <- df$bioproject[1]
  
  # Check for specific dataframes to combine HOT entries
  if (project == "HOT1" && study_accession == "PRJNA385855") {
    hot_run_accessions <- c(hot_run_accessions, list(run_accessions))
  } else if (project == "HOT3" && study_accession == "PRJNA352737") {
    hot_run_accessions <- c(hot_run_accessions, list(run_accessions))
  } else {
    # Create the filename with project suffix
    filename <- paste0("data/SRA_accession_", study_accession, "_", project, ".txt")
    write.table(run_accessions, file = filename, row.names = FALSE, col.names = FALSE, quote = FALSE)
  }
}

# Combine HOT run accessions into a single vector
combined_hot_run_accessions <- unlist(hot_run_accessions)

# Save the combined HOT run accessions to a single file
hot_filename <- "data/SRA_accession_PRJNA385855_PRJNA352737_HOT_combined.txt"
write.table(combined_hot_run_accessions, file = hot_filename, row.names = FALSE, col.names = FALSE, quote = FALSE)
