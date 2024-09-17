# A directory for ad-hoc scripts and workflows to acquire metadata

This README.md details the entire process of acquiring, patching, standardising, and filtering the metadata associated with the following project accession numbers PRJNA385855 (Bermuda Atlantic Time-series Study, Hawaii Ocean Time-series), PRJNA385854 (bioGEOTRACES), PRJNA656268 (Bio-GO-SHIP), PRJNA352737 (Hawaii Ocean Time-series), PRJEB52452 (Malaspina), PRJEB8682 (Ocean Sampling Day), and Tara Oceans (PRJEB1787).


## Table of contents

1. [`ENAmetadataKingfisherDownload.sh`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#1-enametadatakingfisherdownloadsh)
2. [`cleanKingfisherTARA.py`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#2-cleankingfishertarapy)
3. [`importENAmetadata.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#3-importenametadatar)
4.  [`sepBATSandHOT.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#4-sepbatsandhotr)
5.  [`metagenomicsNpairedOnly.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#5-metagenomicsnpairedonlyr)
6.  [`checkNpatchNfilterDepth.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#6-checknpatchnfilterdepthr)
- [Optionally `safeguardPostDepthFilter.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#optionally-safeguardpostdepthfilterr)
7. [Patch and Standardize metadata of each project](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#7-patch-and-standardize-metadata-of-each-project)
    - [bioGEOTRACES](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#biogeotraces)
       - [Download metadata from publication: `download_SciDataTable_BGT.py`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#download-metadata-from-publication-download_scidatatable_bgtpy)
       - [link ENA metadata to metadata on BODC and to metadata mentioned in the data publication `patchNstandardiseBGT.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#link-ena-metadata-to-metadata-on-bodc-and-to-metadata-mentioned-in-the-data-publication-patchnstandardisebgtr)
    - [HOT1](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#hot1)
       - [Download metadata from publication: `download_SciDataTable_BGT.py`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#download-metadata-from-publication-download_scidatatable_bgtpy-1)
       - [link ENA metadata to metadata on HOTDOG and to metadata mentioned in the data publication `patchNstandardiseHOT1.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#link-ena-metadata-to-metadata-on-hotdog-and-to-metadata-mentioned-in-the-data-publication-patchnstandardisehot1r)
    - [BATS](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#bats)
       - [link ENA metadata to metadata on https://bats.bios.asu.edu and to metadata mentioned in the data publication `patchNstandardiseBATS.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#link-ena-metadata-to-metadata-on-httpsbatsbiosasuedu-and-to-metadata-mentioned-in-the-data-publication-patchnstandardisebatsr)
    - [MAL](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#mal)
       - [link ENA metadata to metadata from the data publication and standardise it in `patchNstandardiseMAL.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#link-ena-metadata-to-metadata-from-the-data-publication-and-standardise-it-in-patchnstandardisemalr)
    - [TARA](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#tara)
       - [standardise and handle metadata with `patchNstandardiseTARA.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#standardise-and-handle-metadata-with-patchnstandardisetarar)
    - [OSD](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#osd)
       - [standardise and handle metadata with `patchNstandardiseOSD.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#standardise-and-handle-metadata-with-patchnstandardiseosdr)
    - [BGS](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#bgs)
       - [standardise and handle metadata with `patchNstandardiseBGS.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#standardise-and-handle-metadata-with-patchnstandardisebgsr)
    - [HOT3](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#hot3)
       - [standardise and handle metadata with `patchNstandardiseHOT3.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#standardise-and-handle-metadata-with-patchnstandardisehot3r)
8. [Combine metadatasets `bringTogether.R`](https://github.com/merenlab/public-marine-omics-metadata/tree/main/scripts#8-combine-metadatasets-bringtogetherr)

---

The following scripts connect to [anvi'o](https://anvio.org)

--- 

- [Link to metagenomics data download: `exportSRArunAccessionTxt.R`](https://github.com/merenlab/public-marine-omics-metadata/blob/main/scripts/README.md#link-to-metagenomics-data-download-exportsrarunaccessiontxtr)

- [Link to visualisation with anvi'o](https://github.com/merenlab/public-marine-omics-metadata/blob/main/scripts/README.md#link-to-visualisation-with-anvio)






## scripts

### 1. `ENAmetadataKingfisherDownload.sh`

Here, we are using `Kingfisher` to download metadata from ENA and NCBI.

> Woodcroft, B. J., Cunningham, M., Gans, J. D., Bolduc, B. B., & Hodgkins, S. B. (2024). Kingfisher: A utility for procurement of public sequencing data (v0.4.0). Zenodo. https://doi.org/10.5281/zenodo.10525086
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

---

From here on, we are focusing on patching the metadata of the individual projects 

---

### 7. Patch and Standardize metadata of each project

Information we are aiming for:

Essential
- latitude and longitude (needed to see latitudinal gradient) - given either in `lat_lon`, `latitude` + `longitude`,
   - need this as decimal, in separate fields but also together
- `collection_date` and time (what time of the year was it, can use to determine seasons)
- size fractionation (essential to know what organisms to expect)

Env metadata
- temperature
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

🧚🏻 [This is your captain speaking] To proceed, get additional BGT metadata from the BODC as described here: https://github.com/merenlab/public-marine-omics-metadata/issues/1

- import metadata from BODC
- remove any columns with NAs only
- remove the `QV:SEADATANET` columns that are associated with many of the environmental data columns
- clean the column names
- merge the dataframes based on the `bottle_id_pub` with the suffix `_bodc` for all new metadata keys

Now we will add some more information from the text of the publication https://doi.org/10.1038/sdata.2018.176

- add size fractionation information, `size_frac_low`, `size_frac_up` and `size_frac`
- add `samp_size` (volume of water collected) and `samp_vol_we_dna_ext` (volume of water filtered for DNA extraction) columns

 and rearrange/clean up some data
 
- make latitude and longitude values into decimals, have them in a combined field `lat_lon` and in separate fields `latitude` and `longitude`
- separate collection_date in to year, month, day, time
- streamline column names for environmental metadata (including units in the name for now)
- add emply columns on `layer` and `local_time`
- add column on `environmental_package` = water

> [!NOTE]
No information on layers to be found
Information in `geo_loc_name` relatively vague ("Pacific Ocean" or "Atlantic Ocean")
No information on coastal VS open ocean
No information on upwelling system or non-upwelling system

> [!NOTE]
Information to continue with: bottle_id_pub	biosample	run	bioproject	gbp	library_strategy	library_selection	model	sample_name	taxon_name	experiment_accession	experiment_title	library_name	library_source	library_layout	platform	study_accession	study_alias	sample_alias	sample_accession	collection_date	depth	env_biome	env_feature	env_material	geo_loc_name	geotraces_section	cruise_id	cruise_station	bottle_id	biosamplemodel	study_title	design_description	study_abstract   number_of_runs_for_sample	spots	bases	run_size	published	read1_length_average	read1_length_stdev	read2_length_average	read2_length_stdev

> [!NOTE]
"Special" information to continue with: year	month	day	time temperature_degC	salinity_pss   oxygen_umolKg	phosphate_umolKg  silicate_umolKg	nitrate_umolKg  nitrite_umolKg dic_umolKg	doc_umolKg chla_ngL	chlb_ngL	chlc_ngL size_frac_low	size_frac_up	size_frac	samp_size	samp_vol_we_dna_ext	latitude	longitude	lat_lon
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

🧚🏻 [This is your captain speaking] To proceed, get additional HOT metadata from the HOTDOG portal as described here: https://github.com/merenlab/public-marine-omics-metadata/issues/2

- import metadata from HOTDOG 2003-2010
- clean the column names
- merge the dataframes based on the `bottle_id_pub` with the suffix `_dog` for all new metadata keys

> [!NOTE]
For some bottles, there is no information. Those samples will have to be removed.

Anyhow, we will add some more information from the text of the publication https://doi.org/10.1038/sdata.2018.176

- add size fractionation information, `size_frac_low`, `size_frac_up` and `size_frac`
- add `samp_size` (volume of water collected) and `samp_vol_we_dna_ext` (volume of water filtered for DNA extraction) columns
- add `layer` based on the information in the publication (for each date they got sample from surface water, the deep chlorophyll maximum, and the bottom of the euphotic zone)

 and rearrange/clean up some data
 
- make latitude and longitude values into decimals, have them in a combined field `lat_lon` and in separate fields `latitude` and `longitude` (is very minimal)
- separate collection_date in to year, month, day, time
- create local_time by substracting 10h from time (as noted by [HOT DOGS tutorial]([url](https://hahana.soest.hawaii.edu/hot/hot-dogs/documentation/example1.html))
- streamline column names for environmental metadata (including units in the name for now)
- remove environemental metadata columns that have non-values (-0.9 or -0.99 for samples) and remove csal_dog because we are using bsal_dog (has more values)
- remove rows with samples that do not have temperature info
- add column on `environmental_package` = water

> [!NOTE]
> lat and lon have very few or no decimals. May patch since we know where the HOT sampling took place. Cross-checked with the lat_lon values in HOT3: 158 seems to be the average, so okay to keep it like it is



### BATS

🧚🏻 [This is your captain speaking] To proceed, get additional BATS metadata from the https://bats.bios.asu.edu portal as described here: https://github.com/merenlab/public-marine-omics-metadata/issues/3

#### link ENA metadata to metadata on https://bats.bios.asu.edu and to metadata mentioned in the data publication `patchNstandardiseBATS.R` 

- import metadata from https://bats.bios.asu.edu
- merge the dataframes based on the `bottle_id` with the suffix `_edu` for all new metadata keys

We will add some more information from the text of the publication https://doi.org/10.1038/sdata.2018.176

- add size fractionation information, `size_frac_low`, `size_frac_up` and `size_frac`
- add `samp_size` (volume of water collected) and `samp_vol_we_dna_ext` (volume of water filtered for DNA extraction) columns
- add `layer` based on the information in the publication (for each date they got sample from surface water, the deep chlorophyll maximum, and the bottom of the euphotic zone)

 and rearrange/clean up some data
 
- make latitude and longitude values into decimals, have them in a combined field `lat_lon` and in separate fields `latitude` and `longitude` (is very minimal)
- separate collection_date in to year, month, day
- make `time` column from Time_edu with format hh:mm
- streamline column names for environmental metadata (including units in the name for now)
- remove environemental metadata columns that have non-values (-999 for samples) and remove columns we won't be using since other projects don't have them
- add empty column on `local_time`
- add column on `environmental_package` = water


### MAL

Sánchez, P., Coutinho, F.H., Sebastián, M. et al. Marine picoplankton metagenomes and MAGs from eleven vertical profiles obtained by the Malaspina Expedition. Sci Data 11, 154 (2024). https://doi.org/10.1038/s41597-024-02974-1

#### link ENA metadata to metadata from the data publication and standardise it in `patchNstandardiseMAL.R` 

Here, we
- import Supplementary Table 02 from the data publication
- added the `layer` information (DCM or not) the ENA dataframe based on the "sample_name" = "sample_alias" and made it match the values of the other dfs (epipelagic = surface water; DCM = deep chlorophyll maximum)

We then continued to add some information mentioned in the text of the data pubilcation
- samp_size (ml of water collected)
- samp_vol_we_dna_ext (ml of of water filtered for DNA extraction)

And rearranged some data and standardised the column names
- Concatenate lower and upper filter size into `size_frac` and rename individual values to `size_frac_low` and `size_frac_up`
- Create new columns 'latitude' and 'longitude' (prev had _start suffix) and then concatenate them into 'lat_lon'
- create the column 'collection_date' from 'event_date.time_start' and then split 'collection_date' into 'year', 'month', 'day', and 'time' (if time = 99:99, it will be NA) columns
- Rename columns for environmental metadata to follow our naming structure
- add empty column on `local_time`

### TARA

#### standardise and handle metadata with `patchNstandardiseTARA.R`

Here, we
- make sure the metadata keys follow naming conventions
- make `lat_lon` field with concatenates `latitude` and `longitude`
- concatenate lower and upper filter size into `size_frac` and rename individual values to `size_frac_low` and `size_frac_up`
- split `collection_date` into year, month, day, and time
- take the `layer` info out of `environmental_feature`
- rename the columns for env metadata to match the other dataframes
- remove any samples that do not match the filter sizes we are focusing on 
- add empty column on `local_time`
- add empty column on `samp_size`
- add empty column on `samp_vol_we_dna_ext`

> [!NOTE]
> missing information on volume filtered (could not find this in publications)

> [!NOTE]
> one of the runs (ERR1701760) has a very different filter size range (1.6 - 20.0). I removed that one.

> [!NOTE]
> 2 samples (SAMEA2623295, SAMEA2623919),  with 5 runs (ERR598987, ERR599001, ERR599070, ERR599099, ERR599147) between them are lacking temperature data (9999). Removed.


### OSD

#### standardise and handle metadata with `patchNstandardiseOSD.R`

Here, we
- make sure the metadata keys follow naming conventions
- add the filter size info from the OSD handbook https://store.pangaea.de/Projects/OSD_2014/OSD_Handbook_v2_June_2014.pdf and concatenate the filter size thresholds into `size_frac`
- make `lat_lon` field with concatenates `latitude` and `longitude`
- split `collection_date` into year, month, day, and time
- take the `layer` info (only one sample notes "deep chlorophyll maximum", all others surface water)
- rename the columns for env metadata to match the other dataframes
- remove any samples that specify that they are freshwater
- add empty column on `local_time`
- add empty column on `samp_size`
- add empty column on `samp_vol_we_dna_ext`

> [!NOTE]
> missing information on volume filtered (have to see if one can deduct this from https://store.pangaea.de/Projects/OSD_2014/OSD_Handbook_v2_June_2014.pdf, which notes that it could e 10-20 liter...

> [!NOTE]
> look into "event_device" renaming?


### BGS

#### standardise and handle metadata with `patchNstandardiseBGS.R`

Here, we
- download the Supplementary Table from the BGS data publication https://doi.org/10.1038/s41597-021-00889-9
- make sure the metadata keys follow naming conventions
- merge the supplementary table inforamtion with the metadata from ENA
- based on the new inforamtion, redo the depth filtering

> [!NOTE]
> In the publicaiton, they had said all samples came from roughly the same depth, either 3-5 m or 7m. In the supplementary table from the publication, however, we see that some (even if very few) do not follow that pattern. Thus, I re-did the depth filtering. 2 Samples were filtered out.

- add the filter size info from the publication
- make `lat_lon` field with concatenates `latitude` and `longitude`
- split `collection_date` into year, month, day, and time
- add `local_time`
- take the `layer` info (all  surface water)
- rename the columns for env metadata to match the other dataframes
- add empty column on `samp_size`
- add empty column on `samp_vol_we_dna_ext`
- add empty column on `salinity_pss` (all other dfs have values here)
- add "water" in `environmental_package`

> [!NOTE]
> I did a whole other thing, following the trail of data noted in table 1 of the publication, but it was a tangled mess that frustrated me enough to say: "rather not work with salinity values for all projects than spend another day on this" (at least for now)..

### HOT3

#### standardise and handle metadata with `patchNstandardiseHOT3.R`

Here, we
- make sure the metadata keys follow naming conventions
- add the filter size info from Mende, D.R., Bryant, J.A., Aylward, F.O. et al. Environmental drivers of a microbial genomic transition zone in the ocean’s interior. Nat Microbiol 2, 1367–1373 (2017). https://doi.org/10.1038/s41564-017-0008-3
- make `lat_lon` field with concatenates `latitude` and `longitude`
- split `collection_date` into year, month, and day
- take the `local_time` and make it into `time` (wherever values were given)
- rename the columns for env metadata to match the other dataframes
- add empty column on `samp_size`
- add empty column on `samp_vol_we_dna_ext`
- add empty column on `layer`
- add "water" in `environmental_package`


---


### 8. Combine metadatasets `bringTogether.R`

Here, we perform several steps to clean, merge, and enhance data from multiple dataframes, each representing different projects.

First, we determine  the number of samples and runs that made it past metadata standardisation
- count and display the unique entries for the biosample and run columns in each dataframe.

Then, we combine the metadata dataframes of the different projects
- It then identifies the common columns across all dataframes and renames any non-common columns to avoid conflicts during merging.
- After renaming, the dataframes are merged using a full outer join on the common columns.
- The merged dataframe is reordered for easier analysis, and a subset containing only the common columns is saved separately.

Then, we add more information based on values in the dataframes
- The script then enriches the data by
   - determining the season based on the collection date and the hemisphere (using latitude) and
   - by categorizing locations as either "Coastal" or "Open Ocean" based on their proximity to coastlines.
 
Lastly, we will filter again based on the inforamtion just added (some are classified as land).
 
The final outputs are saved to text files for further analysis.

---

The following scripts link to anvi'o

--- 

### Link to metagenomics data download: `exportSRArunAccessionTxt.R`

This script links into the download of the metagenomes from the selected runs and samples. We are exporting a .txt file with the bioproject and run accession numbers of those samples we wish to continue with.

### Link to visualisation with anvi'o

`filterMetagenomesTxt.py` 
- We need to make sure that our metadata is following the format that anvi'o expects. That means to use the sample names we used as part of the metagenomics workflow, but also to subset the main metadata table we made above to only keep info on the samples that passed our filtering based on coverage and detection here.
- We will first subset `metagenomes.txt` to only include those samples that passed the filtering and are thus listed in the `unique_samples.txt` we created earlier.
- Further, the `metagenomes.txt` file currently has multiple rows per sample if there are multiple runs associated with one sample. We will make it such that there is only one row per sample (so one row per layer that we want to associate this with in anvi'o). Of course, ensuring that any differing values across different runs from the same sample are concatenated, and identical values retained as they are.

`prepAnvioMetadata.py`
- Select the columns we want to bring into anvi'o



