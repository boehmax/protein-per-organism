#!/bin/bash

# Define the path to cd-hit
cdhit_path="cd-hit"

# Change to the directory provided as an argument
cd "output/2024-03-05/fasta_sorted_by_species"

# Loop over all .fasta files
for k in *.fasta
do
  "${cdhit_path}" -i "$k" -o ./fasta_species_clustered/"$k" -c 0.90 -n 5
done

# Create the new directory if it doesn't exist
mkdir -p "${dir_path}/cluster"

# Move the .clstr files to the new directory
mv ./fasta_species_clustered/*.clstr "./fasta_species_clustered/cluster/"