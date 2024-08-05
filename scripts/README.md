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


