#!/bin/bash

######################################
# script to download metadata stored in the INSDC databases (ENA, NCBI, DDBJ)
######################################

######################################
# This script requires the installation of Kingfisher 
# Please see here for the installation guide: https://wwood.github.io/kingfisher-download/
#
# If you use the Kingfisher program, please consider citing:
# Woodcroft, B. J., Cunningham, M., Gans, J. D., Bolduc, B. B., & Hodgkins, S. B. (2024). Kingfisher: A utility for procurement of public sequencing data (v0.4.0). Zenodo. https://doi.org/10.5281/zenodo.10525086
######################################

# Ensure the ../data directory exists
mkdir -p ../data

# Array of project IDs
projects=(
    "PRJNA385855"
    "PRJNA385854"
    "PRJNA656268"
    "PRJNA16339"
    "PRJNA352737"
    "PRJEB52452"
    "PRJEB8682"
    "PRJEB1787"
    "PRJEB2064"
)

# Array of project names
names=(
    "BATSnHOT1"
    "BGT"
    "BGS"
    "HOT2"
    "HOT3"
    "MAL"
    "OSD"
    "TARA"
    "WCO"
)

# Loop through each project to download metadata and count unique entries
for i in "${!projects[@]}"; do
    project="${projects[$i]}"
    name="${names[$i]}"
    echo "Annotating project $project ($name)..."
    output_file="../data/${project}_${name}_metadata.tsv"
    
    # Run kingfisher annotate command
    kingfisher annotate -p "$project" --all-columns -f tsv > "$output_file"
    
    # Check if the file was created successfully
    if [[ -f "$output_file" ]]; then
        # Extract the header to identify the column number for biosample and count total columns
        header=$(head -n 1 "$output_file")
        biosample_col=$(echo "$header" | tr '\t' '\n' | nl -v 1 | grep -E '\bbiosample\b' | awk '{print $1}')
        total_columns=$(echo "$header" | awk -F'\t' '{print NF}')
        
        if [[ -z "$biosample_col" ]]; then
            echo "Biosample column not found in $output_file."
            continue
        fi
        
        # Count unique entries in the run and biosample columns
        run_count=$(cut -f1 "$output_file" | tail -n +2 | sort | uniq | wc -l)
        biosample_count=$(cut -f"$biosample_col" "$output_file" | tail -n +2 | sort | uniq | wc -l)

        echo "Project $project ($name) has $run_count unique run entries, $biosample_count unique biosample entries, and $total_columns columns."
    else
        echo "File $output_file does not exist."
    fi
done

echo "ENA metadata download and counting complete for all projects."

