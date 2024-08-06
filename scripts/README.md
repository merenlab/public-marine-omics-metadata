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

 and rearrange some data
 
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

- import metadata from HOTDOG 2003-2004 and 2009
- combine the two dataframes
- clean the column names
- merge the dataframes based on the `bottle_id_pub` with the suffix `_dog` for all new metadata keys

> [!NOTE]
For some bottles, there is no information


```
> HOT1_pubNdog030409_merged$date_dog
 [1] " 022404" " 022404" " 042004" " 051804" " 061504" " 081504" " 081504" " 092804" " 103104" " 112704" NA        NA        NA        " 011703"
[15] " 022503" " 032803" " 042303" " 052003" " 061903" " 061903" " 071903" " 082003" " 110903" NA        " 122003" " 122003" " 101403" NA       
[29] " 012104" " 012104" " 031904" NA        NA       
> HOT1_pubNdog030409_merged$bottle_id_pub
 [1] "1560200314" "1560200308" "1580200313" "1590200314" "1600200414" "1620200414" "1620200408" "1630200414" "1640201117" "1650200419"
[11] "1650200409" "1660200514" "1660200508" "1440200914" "1450200318" "1460200314" "1470200314" "1480200316" "1490200314" "1490200308"
[21] "1500200314" "1510200316" "1530200314" "1530200308" "1540201018" "1540201010" "1520200320" "1520200308" "1550200314" "1550200308"
[31] "1570200323" "2140200308" "2160200304"
> HOT1_pubNdog030409_merged$collection_date
 [1] "2004-02-24" "2004-02-24" "2004-04-20" "2004-05-18" "2004-06-15" "2004-08-15" "2004-08-15" "2004-09-28" "2004-10-10" "2004-11-10"
[11] "2004-11-10" "2004-12-14" "2004-12-14" "2003-01-17" "2003-02-25" "2003-03-28" "2003-04-23" "2003-05-20" "2003-06-19" "2003-06-19"
[21] "2003-07-19" "2003-08-20" "2003-11-09" "2003-11-09" "2003-12-20" "2003-12-20" "2003-10-14" "2003-10-14" "2004-01-21" "2004-01-21"
[31] "2004-03-19" "2009-08-19" "2009-11-04"
```

I noticed that for some of the samples, where we got information from HOTDOG, the date_dog and the collection_date_pub do not match and the date in `date_dog` is significantly later. So perhaps, I have to increase the date range to capture those. Example: `collection_date_pub` = 2004-11-10 WHILE date_dog `112704`. Retry with that.


