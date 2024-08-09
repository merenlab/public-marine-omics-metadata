# Import ENA metadata and standardise headers

# Set the working directory to one level above the script/ directory 
setwd("/Users/rameyer/Documents/_P3/P3dataAnalysis/P3_metadata/public-marine-omics-metadata/")


library(dplyr)

# TARA PRJEB1787
# OSD PRJEB8682
# Bio-GO-SHIP PRJNA656268
# bioGEOTRACERS PRJNA385854
# Malaspina PRJEB52452
# BATS (2003-2004) PRJNA385855
# HOT1 (2003-2004) PRJNA385855
# HOT2 (2007 - 2009) PRJNA16339
# HOT3 (2010-2016) PRJNA352737
# WCO L4 PRJEB2064

# Function to standardize column names
standardize_colnames <- function(df) {
  colnames(df) <- tolower(colnames(df)) # Convert to lowercase
  colnames(df) <- gsub("-", "_", colnames(df)) # Replace hyphens with underscores
  colnames(df) <- gsub(" ", "_", colnames(df)) # Replace spaces with underscores
  colnames(df) <- gsub("\\.", "_", colnames(df)) # Replace periods with underscores
  colnames(df) <- make.names(colnames(df), unique = TRUE) # Ensure unique and valid names
  return(df)
}

# TARA PRJEB1787
TARA_meta_dataframe <- read.csv("data/PRJEB1787_TARA_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
TARA_meta_dataframe <- standardize_colnames(TARA_meta_dataframe)

# OSD PRJEB8682
OSD_meta_dataframe <- read.csv("data/PRJEB8682_OSD_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
OSD_meta_dataframe <- standardize_colnames(OSD_meta_dataframe)

# Bio-GO-SHIP PRJNA656268
BGS_meta_dataframe <- read.csv("data/PRJNA656268_BGS_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
BGS_meta_dataframe <- standardize_colnames(BGS_meta_dataframe)

# bioGEOTRACERS PRJNA385854
BGT_meta_dataframe <- read.csv("data/PRJNA385854_BGT_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
BGT_meta_dataframe <- standardize_colnames(BGT_meta_dataframe)

# Malaspina PRJEB52452
MAL_meta_dataframe <- read.csv("data/PRJEB52452_MAL_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
MAL_meta_dataframe <- standardize_colnames(MAL_meta_dataframe)

#BATS (2003-2004) & HOT1 (2003-2004) PRJNA385855
BATSHOT_meta_dataframe <- read.csv("data/PRJNA385855_BATSnHOT1_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
BATSHOT_meta_dataframe <- standardize_colnames(BATSHOT_meta_dataframe)

#HOT2 (2007 - 2009) PRJNA16339
HOT2_meta_dataframe <- read.csv("data/PRJNA16339_HOT2_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
HOT2_meta_dataframe <- standardize_colnames(HOT2_meta_dataframe)

#HOT3 (2010-2016) PRJNA352737
HOT3_meta_dataframe <- read.csv("data/PRJNA352737_HOT3_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
HOT3_meta_dataframe <- standardize_colnames(HOT3_meta_dataframe)

#WCO L4 PRJEB2064
WCO_meta_dataframe <- read.csv("data/PRJEB2064_WCO_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
WCO_meta_dataframe <- standardize_colnames(WCO_meta_dataframe)


####
# Function to count unique entries in a given column
count_unique_entries <- function(df, column) {
  return(length(unique(df[[column]])))
}

# Display unique entries count for both biosample and run columns for each dataframe
cat("TARA PRJEB1787 - biosample:", count_unique_entries(TARA_meta_dataframe, "biosample"), ", run:", count_unique_entries(TARA_meta_dataframe, "run"), "\n")
cat("OSD PRJEB8682 - biosample:", count_unique_entries(OSD_meta_dataframe, "biosample"), ", run:", count_unique_entries(OSD_meta_dataframe, "run"), "\n")
cat("Bio-GO-SHIP PRJNA656268 - biosample:", count_unique_entries(BGS_meta_dataframe, "biosample"), ", run:", count_unique_entries(BGS_meta_dataframe, "run"), "\n")
cat("bioGEOTRACERS PRJNA385854 - biosample:", count_unique_entries(BGT_meta_dataframe, "biosample"), ", run:", count_unique_entries(BGT_meta_dataframe, "run"), "\n")
cat("Malaspina PRJEB52452 - biosample:", count_unique_entries(MAL_meta_dataframe, "biosample"), ", run:", count_unique_entries(MAL_meta_dataframe, "run"), "\n")
cat("BATS & HOT PRJNA385855 - biosample:", count_unique_entries(BATSHOT_meta_dataframe, "biosample"), ", run:", count_unique_entries(BATSHOT_meta_dataframe, "run"), "\n")
cat("HOT (2007-2009) PRJNA16339 - biosample:", count_unique_entries(HOT2_meta_dataframe, "biosample"), ", run:", count_unique_entries(HOT2_meta_dataframe, "run"), "\n")
cat("HOT (2010-2016) PRJNA352737 - biosample:", count_unique_entries(HOT3_meta_dataframe, "biosample"), ", run:", count_unique_entries(HOT3_meta_dataframe, "run"), "\n")
cat("WCO L4 PRJEB2064 - biosample:", count_unique_entries(WCO_meta_dataframe, "biosample"), ", run:", count_unique_entries(WCO_meta_dataframe, "run"), "\n")

