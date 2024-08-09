# Purpose

Welcome to the Standardized Metadata Collection for Omics Data repository! This repository is dedicated to the collection, standardization, and sharing of metadata associated with various omics data types, currently focusing on metagenomics but with plans to expand to metatranscriptomics, metaproteomics, and metabolomics. 

Our goal is to present metadata in a standardized fashion, both semantically and syntactically, ensuring it is ready for analysis. We will provide guidance and examples to help others contribute. By pooling our efforts, we aim to avoid the duplication of work involved in preparing individual metadata sets and make the process more efficient, considering the significant amount of effort required for metadata preparation.

We are starting by providing the workflow we followed (see scripts/README.md) to get the metadata for the projects listed below as well as, of course sharing the final product.


# Metagenomomes

The purpose of this section is to list the metagenomes included in the current metadata curation effort. This includes the project name, (data) publication, date range, depth range, number of samples, number of runs, project accession number, and other relevant information about the projects and their metadata below.

For details of the metadata curation efforts that include the following datasets and publications that originally describe them see scripts/README.md

> [!NOTE]
> Please note, that the current collection of curated metadata is limited to runs from the projects noted below that
> - are metagenomes
> - are paired-end
> - are from samples collected in ≤100 m depth
> - are from samples associated with at least environmental metadata on `temperature`

* Tara Oceans Project
* Ocean Sampling Day 2014
* Bio-GO-SHIP
* bioGEOTRACES
* Hawaii Ocean Time-Series ALOHA
* BATS
* Western Channel Observatory L4 Station

Quick overview of dataset currently covered: 
Project name  |  date range | depth range | project accession # | (Data) publication | Other sources | Note
-- | -- | -- | -- | -- | -- | --  

Number of samples and runs at passing each step of this metadata curation:
| accession   | Observatory/Cruise |  Project acronym | #s in noted in PRJ accession | #runs noted in PRJ accession | #s post HOT1-BATS split | #runs post HOT1-BATS split | #s metagenomes and paired end only | #runs metagenomes and paired end only | #s depth filtering ≤100m | #runs depth filtering ≤100m     | s# after metadata filtering: env metadata ≥temp | #runs after metadata filtering: env metadata ≥temp  |
|-------------|--------------------------------------------------|------------------|---------------------------------|---------------------------------|------------------------------------------------------|---------------------------------------------------------|------------------------------------|---------------------------------------|---------------------------------|---------------------------------|---------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| PRJNA385855 | Bermuda Atlantic Time-series Study               | BATS             | 130                             | 130                             | 62                                                   | 62                                                      | 62                                 | 62                                    | 40                              | 40                              | 40                                                                        | 40                                                                          |
| PRJNA385854 | bioGEOTRACES                                     | BGT              | 480                             | 480                             | 480                                                  | 480                                                     | 480                                | 480                                   | 323                             | 323                             | 323                                                                       | 323                                                                         |
| PRJNA656268 | Bio-GO-SHIP                                      | BGS              | 996                             | 2407                            | 996                                                  | 2407                                                    | 971                                | 971                                   | 969 (in patchNstandardiseBGS.R) | 969 (in patchNstandardiseBGS.R) | 969                                                                       | 969                                                                         |
| PRJNA385855 | Hawaii Ocean Time-Series ALOHA (2003-2004; 2009) | HOT1             | 130                             | 130                             | 68                                                   | 68                                                      | 68                                 | 68                                    | 33                              | 33                              | 28                                                                        | 28                                                                          |
| PRJNA16339  | Hawaii Ocean Time-Series ALOHA (2007-2009)       | HOT2             | 54                              | 87                              | 54                                                   | 87                                                      | 0                                  | 0                                     | -                               | -                               | -                                                                         | -                                                                           |
| PRJNA352737 | Hawaii Ocean Time-Series ALOHA (2010-2016)       | HOT3             | 773                             | 1176                            | 773                                                  | 1176                                                    | 597                                | 691                                   | 230                             | 274                             | 230                                                                       | 274                                                                         |
| PRJEB52452  | Malaspina Expedition                             | MAL              | 81                              | 381                             | 81                                                   | 381                                                     | 81                                 | 381                                   | 16                              | 83                              | 16                                                                        | 83                                                                          |
| PRJEB8682   | Ocean Sampling Day 2014                          | OSD              | 162                             | 467                             | 162                                                  | 467                                                     | 150                                | 150                                   | 150                             | 150                             | 149                                                                       | 149                                                                         |
| PRJEB1787   | Tara Oceans Project                              | TARA             | 136                             | 249                             | 136                                                  | 249                                                     | 136                                | 246                                   | 95                              | 170                             | 95                                                                        | 170                                                                         |
| PRJEB2064   | Western Channel Observatory                      | WCO              | 10                              | 20                              | 10                                                   | 20                                                      | 0                                  | 0                                     | -                               | -                               | -                                                                         | -                                                                           |


# Metatranscriptomes

To be added as the collection of metadata grows.

# Metaproteomes

To be added as the collection of metadata grows.

# Metabolomes

To be added as the collection of metadata grows.

