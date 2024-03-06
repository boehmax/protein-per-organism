# Proteins per Organism

This script takes a list of FASTA files containing NiCODH, adds various types of information, and generates several plots for analysis.

## Prerequisites

Before running this script, make sure you have the following R packages installed:

- phylotools: for importing FASTA files
- tidyverse: for data manipulation
- taxize and taxizedb: for handling taxonomies
- seqinr: for writing FASTA files
- reshape2, ggplot2, plotly, and ggtree: for creating correlation matrices

You should also have CD-HIT installed and compiled on your system. Please note that the CD-HIT functionality only works on Linux systems.

## How to Use

1. Source the functions from the files `01_open.R`, `02_clean.R`, and `03_functions.R`.
2. Call the `main` function. This function will:
   - Create an output folder
   - Import FASTA files and clean up the data
   - Merge the dataframes
   - Assign taxid
   - Get taxonomic classification
   - Check if taxonomic levels go down to species and append to the dataframe
   - Add clade information if available
   - Perform general and species-specific cleanups
   - Write FASTA sequences for each species
   - Run CD-HIT to remove duplicates on each organism individually (Linux only)
   - Re-import clustered FASTA files
   - Make a correlation matrix
   - Create histograms of how many CODH of the same clade are in one organism
   - Create and save a tree of organisms with clades

Please note that the script expects the FASTA files to be located in a directory named `data`. If clade information is available, it should be placed in a directory named `data/clades`.

## Output

The script will generate several outputs, including a correlation matrix, histograms, and a tree of organisms with clades. These will be saved in the output folder created by the script.
