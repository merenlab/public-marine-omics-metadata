### script to separate BATS and HOT

# Separate BATS and HOT based on the entry in BATSHOT_meta_dataframe$country: 
# `Atlantic Ocean: Sargasso Sea, BATS` or `Pacific Ocean: North Pacific Subtropical Gyre, Station ALOHA`

# Create BATS_meta_dataframe with entries for Sargasso Sea, BATS
BATS_meta_dataframe <- 
  subset(
    BATSHOT_meta_dataframe, 
    geo_loc_name == "Atlantic Ocean: Sargasso Sea, BATS"
  )
dim(BATS_meta_dataframe)

# Create HOT_meta_dataframe with entries for North Pacific Subtropical Gyre, Station ALOHA
HOT1_meta_dataframe <- 
  subset(
    BATSHOT_meta_dataframe, 
    geo_loc_name == "Pacific Ocean: North Pacific Subtropical Gyre, Station ALOHA"
  )

dim(HOT1_meta_dataframe)


####
# Function to count unique entries in a given column
count_unique_entries <- function(df, column) {
  return(length(unique(df[[column]])))
}

# Display unique entries count for both biosample and run columns for each dataframe

cat("BATS PRJNA385855 - biosample:", count_unique_entries(BATS_meta_dataframe, "biosample"), ", run:", count_unique_entries(BATS_meta_dataframe, "run"), "\n")
cat("HOT1 PRJNA385855 - biosample:", count_unique_entries(HOT1_meta_dataframe, "biosample"), ", run:", count_unique_entries(HOT1_meta_dataframe, "run"), "\n")

