# Proteins per Organism

This project is a phylogenetic analysis pipeline that imports FASTA files, cleans up the data, assigns taxonomic IDs, checks taxonomic levels down to species, adds clade information, performs general cleanup, and writes FASTA sequences for each species.
Future functions will include the plotting and evaluation of the occurence of a protein in different species and its co-occurence with other proteins in the same species.

## Dependencies

This project requires the following R packages:

- `phylotools`: For importing FASTA files.
- `tidyverse`: For data manipulation.
- `taxize`: For handling taxonomies.
- `taxizedb`: For using offline taxonomy databases.
- `seqinr`: For writing FASTA files.

## Usage

First, source the necessary scripts:

```R
source('01_open.R')
source('02_clean.R')
source('03_functions.R')
```

Then, call the main function:

```R
main()
```

The main function performs the following steps:

1. Creates an output folder.
1. Imports and cleans up FASTA files.
1. Merges the dataframes.
1. Assigns taxonomic IDs.
1. Gets taxonomic classifications.
1. Checks if taxonomic levels go down to species and appends the dataframe.
1. Adds clade information.
1. Performs general cleanup and species-specific cleanup.
1. Writes FASTA sequences for each species, if needed.
1. Input
1. The main function expects the input FASTA files to be located in the data directory. The names of the FASTA files should be passed as arguments to the import_fasta_and_cleanup function.

### Output
The output is a set of cleaned and classified FASTA sequences, one for each species. These are written to the output folder created by the create_output_folder function.