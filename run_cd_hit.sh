#!/bin/bash

# Define the path to cd-hit
cdhit_path="cd-hit"

# Change to the directory provided as an argument
cd "output/2025-01-17/fasta_sorted_by_species"

# Loop over all .fasta files
for k in *.fasta
do
  "${cdhit_path}" -i "$k" -o ./fasta_species_clustered/"$k" -c 0.90 -n 5
done

set -e

# Directory containing .clstr files
dir="./fasta_species_clustered"

# Output file
output="cluster_representative.txt"

# Temporary file
temp=$(mktemp)

# Ensure temporary file is removed on exit
trap 'rm -f "$temp"' EXIT

# Remove the output file if it exists
rm -f "$output"

# Process each .clstr file in the directory
for file in "$dir"/*.clstr
do
    # Process each cluster in the file
    awk -v output="$output" '
    BEGIN { cluster_id = 0 }
    /^>Cluster/ {
        cluster_id++
        main_entry = ""
        next
    }
    {
        entry = gensub(/^.*>([^,]*),.*$/, "\\1", "g", $0)
        if ($0 ~ /\*/) {
            main_entry = entry
            percentage = "100.00"
        } else {
            percentage = gensub(/^.*at ([0-9.]+)%.*$/, "\\1", "g", $0)
            if (main_entry) {
                printf "%s\t%s\t%s\n", main_entry, entry, percentage >> output
            }
        }
    }
    ' "$file"
done
