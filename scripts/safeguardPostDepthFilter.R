# safeguard 2
# after depth filtering

library(data.table)


fwrite(TARA_meta_dataframe_100, file = "data/TARA_metadata_save.tsv")
fwrite(OSD_meta_dataframe_100, file = "data/OSD_metadata_save.tsv")
fwrite(BGS_meta_dataframe_100, file = "data/BGS_metadata_save.tsv")
fwrite(BGT_meta_dataframe_100, file = "data/BGT_metadata_save.tsv")
fwrite(MAL_meta_dataframe_100, file = "data/MAL_metadata_save.tsv")
fwrite(HOT1_meta_dataframe_100, file = "data/HOT1_metadata_save.tsv")
fwrite(HOT3_meta_dataframe_100, file = "data/HOT3_metadata_save.tsv")
fwrite(BATS_meta_dataframe_100, file = "data/BATS_metadata_save.tsv")
