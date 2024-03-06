#!/bin/bash

# Define the path to cd-hit
cdhit_path="//wsl.localhost/Ubuntu/home/maxbo565/cd-hit-v4.8.1-2019-0228/cd-hit"

# Change to the directory provided as an argument
cd "output/2024-03-05/fasta_sorted_by_species"

# Loop over all .fasta files
for k in *.fasta
do
  "${cdhit_path}" -i "$k" -o ./fasta_species_clustered/"$k" -c 0.90 -n 5
done