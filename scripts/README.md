# A directory for ad-hoc scripts and workflows to acquire metadata

Background information

## scripts

### 1. `ENAmetadataKingfisherDownload.sh`

Here, we are using `Kingfisher` to download metadata from ENA and NCBI.

Woodcroft, B. J., Cunningham, M., Gans, J. D., Bolduc, B. B., & Hodgkins, S. B. (2024). Kingfisher: A utility for procurement of public sequencing data (v0.4.0). Zenodo. https://doi.org/10.5281/zenodo.10525086
Doc: https://wwood.github.io/kingfisher-download/
GitHub: https://github.com/wwood/kingfisher-download

To use it, you need to install Kingfisher and use conda env (see installation guide https://wwood.github.io/kingfisher-download/)
```
conda create -n kingfisher -c conda-forge -c bioconda kingfisher
conda activate kingfisher
```

To run it, give it permissions (because it's an .sh script) and run it
```
chmod +x ENAmetadataKingfisherDownload.sh
./ENAmetadataKingfisherDownload.sh
```

### 2. `cleanKingfisherTARA.py`

Here, we are cleaning up the TARA dataframe. From the ones I downloaded this one seems to be the only one that make trouble.

Trouble: the values for some samples in this project were added using slightly different metadata keys
- the value for theoretically the same key is in different columns, for some the column key is upper case for others it is lowercase (e.g. temperature VS Temperature)
- values for `sample_description` sometimes being given under `sample_description`, other times as `description` (leaving the field under the other key blank)
- values for `sample_title` sometimes given under `sample_title`, other times as `title` (here, `sample_title` has values for all samples, however, whenever the `title` key has values, those are - for those samples - more appropriate than the ones given in `sample_title`, and they are consistent with the other values given in `sample_title`)

To run this script do:
```
python3 cleanKingfisherTARA.py
```

---

**The following scripts will be done in R**

---

### 3. `importENAmetadata.R`

Here, we are importing the metadata tables into R, making sure that the headers are consistenly formatted and check the number of samples and runs in each project.

### 4. `sepBATSandHOT.R`

Here, we are separating the BATS and HOT1 project (both included in the same project accession number on ENA `PRJNA385855`). We are also again checking the number of samples and runs in each project after the split.

### 5. `metagenomicsNpairedOnly.R`

Here, we are filtering our runs to only keep metagenomics data (no amplicon or similar), as well as only keeping paired end sequencing runs (so no 454). This completely excludes the data from the WCO and HOT2, as well as a few runs from TARA. The associated runs/samples will no longer be considered in this metadata standardisatino moving forward.

### 6. `checkNpatchNfilterDepth.R`

Here, we are filtering all samples based on depth because I am only working with samples of depth ≤100 m.

It is notable that one of the TARA samples notes a range in the depth column: `Range found in 'run': ERR599001 with depth: 5-160`. For now, I have taken the average, but may remove this run later because I cannot trust the depth value

### Optionally `safeguardPostDepthFilter.R`

This is an optional step in which we export all the dataframes we will continue working with from R into our `data` directory.
The names follow the structure [project_acronym]_metadata_save.

### Link to metagenomics data download `exportRunAccessionTxt.R`

This script links into the download of the metagenomes from the selected runs and samples. We are exporting a .txt file with the bioproject and run accession numbers of those samples we wish to continue with.

---

From here on, we are focusing on patching the metadata of the individual projects 

---

Information we are aiming for:

Essential
- latitude and longitude (needed to see latitudinal gradient) - given either in lat_lon, latitude + longitude,
   - need this as decimal, in separate fiels but also together
- collection_date and time (what time of the year was it, can use to determine seasons)
- size fractionation (essential to know what organisms to expect)

Env metadata
- temperature
- salinity
- as much as we can get really!

environment 
- env_biome
- env_feature
- env_material

procedual metadata
- sequencing technique
- sequencing platform `platform`
- sequencing model `model`

Information I know won't be there, but I would like
- coastal VS open ocean
- upwelling system or non-upwelling system
- consistent marine regions (e.g. which are all from the north atlantic? - can also be calculated later) - given as `geo_loc_name`
- layer (did they target a deep chlorophyll maximum?)


### bioGEOTRACES

#### Download metadata from publication: `download_SciDataTable_BGT.py`

Here, we are downloading table 3 from the data publication introducing the bioGEOTRACES, BATS, and HOT1 datasets. The table contains a column on `Bottle ID` which will allow us to link our data to additional metadata.

Data Publication: Biller, S., Berube, P., Dooley, K. et al. Marine microbial metagenomes sampled across space and time. Sci Data 5, 180176 (2018). https://doi.org/10.1038/sdata.2018.176

To run it, do:
```
python3 download_SciDataTable_BGT.py
```

#### link ENA metadata to metadata on BODC and to metadata mentioned in the data publication `patchNstandardiseBGT.R` 

Here, we
- import the table 3 we downloaded in the step above into R
- subset that table to only keep the values pertaining to BGT
- add the information on the `Bottle ID` (is also included in the ENA dataset but has some weird values sometimes) and `Collection Date` (this includes time, which the `collection_date` from ENA does not) to our dataframe with the suffix `_pub`

[This is your captain speaking. To proceed:] get additional BGT metadata from the BODC as described here: https://github.com/merenlab/public-marine-omics-metadata/issues/1

- import metadata from BODC
- remove any columns with NAs only
- remove the `QV:SEADATANET` columns that are associated with many of the environmental data columns
- clean the column names
- merge the dataframes based on the `bottle_id_pub` with the suffix `_bodc` for all new metadata keys

Now we will add some more information from the text of the publication https://doi.org/10.1038/sdata.2018.176

- add size fractionation information, `size_fraction_lower_threshold`, `size_fraction_upper_threshold` and `size_frac`
- add `samp_size` (volume of water collected) and `samp_vol_we_dna_ext` (volume of water filtered for DNA extraction) columns

 and rearrange/clean up some data
 
- make latitude and longitude values into decimals, have them in a combined field `lat_lon` and in separate fields `latitude` and `longitude`
- separate collection_date in to year, month, day, time
- streamline column names for environmental metadata (including units in the name for now)

> [!NOTE]
No information on layers to be found
Information in `geo_loc_name` relatively vague ("Pacific Ocean" or "Atlantic Ocean")
No information on coastal VS open ocean
No information on upwelling system or non-upwelling system

> [!NOTE]
Information to continue with: bottle_id_pub	biosample	run	bioproject	gbp	library_strategy	library_selection	model	sample_name	taxon_name	experiment_accession	experiment_title	library_name	library_source	library_layout	platform	study_accession	study_alias	sample_alias	sample_accession	collection_date	depth	env_biome	env_feature	env_material	geo_loc_name	geotraces_section	cruise_id	cruise_station	bottle_id	biosamplemodel	study_title	design_description	study_abstract   number_of_runs_for_sample	spots	bases	run_size	published	read1_length_average	read1_length_stdev	read2_length_average	read2_length_stdev

> [!NOTE]
"Special" information to continue with: year	month	day	time temperature_degC	salinity_pss   oxygen_umolKg	phosphate_umolKg  silicate_umolKg	nitrate_umolKg  nitrite_umolKg dic_umolKg	doc_umolKg chla_ngL	chlb_ngL	chlc_ngL size_fraction_lower_threshold	size_fraction_upper_threshold	size_frac	samp_size	samp_vol_we_dna_ext	latitude	longitude	lat_lon
`

### HOT1

#### Download metadata from publication: `download_SciDataTable_BGT.py`

Here, we are reusing the same table 3 from the data publication introducing the bioGEOTRACES, BATS, and HOT1 datasets. The table contains a column on `Bottle ID` which will allow us to link our data to additional metadata.

Data Publication: Biller, S., Berube, P., Dooley, K. et al. Marine microbial metagenomes sampled across space and time. Sci Data 5, 180176 (2018). https://doi.org/10.1038/sdata.2018.176

To run it, do:
```
python3 download_SciDataTable_BGT.py
```

#### link ENA metadata to metadata on HOTDOG and to metadata mentioned in the data publication `patchNstandardiseHOT1.R`

Here, we
- import the table 3 we downloaded in the step above into R
- subset that table to only keep the values pertaining to BGT
- add the information on the `Bottle ID` (is also included in the ENA dataset but has some weird values sometimes) and `Collection Date` (this includes time, which the `collection_date` from ENA does not) to our dataframe with the suffix `_pub`

[This is your captain speaking. To proceed:] get additional HOT metadata from the HOTDOG portal as described here: https://github.com/merenlab/public-marine-omics-metadata/issues/2

- import metadata from HOTDOG 2003-2010
- clean the column names
- merge the dataframes based on the `bottle_id_pub` with the suffix `_dog` for all new metadata keys

> [!NOTE]
For some bottles, there is no information

Anyhow, we will add some more information from the text of the publication https://doi.org/10.1038/sdata.2018.176

- add size fractionation information, `size_fraction_lower_threshold`, `size_fraction_upper_threshold` and `size_frac`
- add `samp_size` (volume of water collected) and `samp_vol_we_dna_ext` (volume of water filtered for DNA extraction) columns
- add `layer` based on the information in the publication (for each date they got sample from surface water, the deep chlorophyll maximum, and the bottom of the euphotic zone)

 and rearrange/clean up some data
 
- make latitude and longitude values into decimals, have them in a combined field `lat_lon` and in separate fields `latitude` and `longitude` (is very minimal)
- separate collection_date in to year, month, day, time
- create local_time by substracting 10h from time (as noted by [HOT DOGS tutorial]([url](https://hahana.soest.hawaii.edu/hot/hot-dogs/documentation/example1.html))
- streamline column names for environmental metadata (including units in the name for now)
- remove environemental metadata columns that have non-values (-0.9 or -0.99 for samples) and remove csal_dog because we are using bsal_dog (has more values) 

> [!NOTE]
> lat and lon have very few or no decimals. May patch since we know where the HOT sampling took place. Cross-checked with the lat_lon values in HOT3: 158 seems to be the average, so okay to keep it like it is



### BATS

[This is your captain speaking. To proceed:] get additional BATS metadata from the https://bats.bios.asu.edu portal as described here: https://github.com/merenlab/public-marine-omics-metadata/issues/3

#### link ENA metadata to metadata on https://bats.bios.asu.edu and to metadata mentioned in the data publication `patchNstandardiseBATS.R` 

- import metadata from https://bats.bios.asu.edu
- merge the dataframes based on the `bottle_id` with the suffix `_edu` for all new metadata keys

We will add some more information from the text of the publication https://doi.org/10.1038/sdata.2018.176

- add size fractionation information, `size_fraction_lower_threshold`, `size_fraction_upper_threshold` and `size_frac`
- add `samp_size` (volume of water collected) and `samp_vol_we_dna_ext` (volume of water filtered for DNA extraction) columns
- add `layer` based on the information in the publication (for each date they got sample from surface water, the deep chlorophyll maximum, and the bottom of the euphotic zone)

 and rearrange/clean up some data
 
- make latitude and longitude values into decimals, have them in a combined field `lat_lon` and in separate fields `latitude` and `longitude` (is very minimal)
- separate collection_date in to year, month, day
- make `time` column from Time_edu with format hh:mm
- streamline column names for environmental metadata (including units in the name for now)
- remove environemental metadata columns that have non-values (-999 for samples) and remove columns we won't be using since other projects don't have them

