# Export the selected run accession numbers for metagenomics data download


####################################
## prep
####################################

# Set the working directory to one level above the script/ directory 
setwd("/Users/rameyer/Documents/_P3/P3dataAnalysis/P3_metadata/public-marine-omics-metadata/")

# Install required packages if not already installed
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}

# Ensure the data/ directory exists
if (!dir.exists("data")) {
  dir.create("data")
}

####################################
## go
####################################

# List of unique projects
projects <- unique(filtered_df_regions$project)

# Create an empty list to hold all HOT run accessions with their respective study accessions
hot_run_accessions <- list()

for (project in projects) {
  # Filter the dataframe by project
  df <- filtered_df_regions[filtered_df_regions$project == project, ]
  
  # Extract the run and bioproject columns
  run_accessions <- df$run
  study_accession <- df$bioproject[1]
  
  # Check for specific projects to combine HOT entries
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
