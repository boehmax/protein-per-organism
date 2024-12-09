#!/bin/bash

set -e

# directory containing .clstr files
dir="./fasta_species_clustered"

# output file
output="cluster_representative.txt"

# temporary file
temp=$(mktemp)

# ensure temporary file is removed on exit
trap 'rm -f $temp' EXIT

# remove the output file if it exists
rm -f $output

# process each .clstr file in the directory
for file in $dir/*.clstr
do
    # process each cluster in the file
    awk '
    BEGIN { cluster_id = 0 }
    /^>Cluster/ {
        cluster_id++
        next
    }
    {
        entry = gensub(/^.*>([^,]*),.*$/, "\\1", "g", $0)
        if ($0 ~ /\*/) {
            main_entry = entry
        } else {
            if (main_entry) {
                printf "%s\t%s\n", main_entry, entry > "'"$output"'"
            }
        }
    }
    ' $file
done