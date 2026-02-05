# Example Data Directory Structure

This document describes the expected structure for input data files.

## Directory Layout

```
protein-per-organism/
├── data/
│   ├── protein.fasta          # Main protein sequences file (REQUIRED)
│   └── clades/                # Clade classification directory (OPTIONAL)
│       ├── CladeA.txt         # Proteins belonging to Clade A
│       ├── CladeB.txt         # Proteins belonging to Clade B
│       └── CladeC.txt         # Proteins belonging to Clade C
```

## FASTA File Format

The main protein FASTA file should follow this format:

```
>protein_id1 [Organism name]
MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAPILSRVGDGTQDNLSGAEKAVQVKVKALPDAQFEVVHSLAKWKRQTLGQH
>protein_id2 [Another organism]
MALWMRLLPLLALLALWGPDPAAAFVNQHLCGSHLVEALYLVCGERGFFYTPKTRREAEDLQVGQVELGGGPGAGSLQPLALEG
```

**Key requirements:**
- Organism name must be enclosed in square brackets `[Organism name]`
- Protein ID should be at the start of the sequence name
- Each sequence should have both ID and organism information

## Clade Files Format

Clade files are plain text files with protein IDs separated by forward slashes:

```
protein_id1/optional_info/more_info
protein_id2/
protein_id3/additional/data/fields
```

**Notes:**
- Each line represents one protein
- The first field (before the first `/`) is the protein ID
- Additional fields after `/` are optional and will be ignored
- File names should follow the pattern: `Clade*.txt`
- Clades will be automatically assigned letters (A, B, C, ...) based on alphabetical file sorting

## Example Clade File: CladeA.txt

```
WP_003629534.1/hypothetical_protein/some_annotation
WP_003629535.1/CODH_protein
WP_003629536.1/
```

## Creating Your Data

1. **Prepare FASTA file**: Export protein sequences from NCBI or your database
2. **Ensure organism names**: Make sure organism names are in `[brackets]`
3. **(Optional) Add clade information**: Create text files in `data/clades/` directory
4. **Update configuration**: Edit `_targets_config.R` to point to your FASTA file

## Taxonomy Database

The pipeline requires the NCBI taxonomy database. To download it:

```r
library(taxizedb)
db_download_ncbi()
```

This creates a local SQLite database of NCBI taxonomy data for fast, offline lookups.

## Output Directory

After running the pipeline, output will be organized by date:

```
output/
└── YYYY-MM-DD/
    ├── fasta_total_slim.csv                    # Summary of all sequences
    ├── fasta_species_check.csv                 # Species validation results
    ├── fasta_clade.csv                         # Data with clade assignments
    ├── classification.RData                    # Taxonomic classifications
    ├── fasta_species_check.RData              # R data objects
    ├── correlation_matrix.png                  # Clade correlation heatmap
    ├── clade_histogram.png                     # Clade distribution plots
    └── fasta_sorted_by_species/                # Per-species FASTA files
        ├── Species_name_1.fasta
        ├── Species_name_2.fasta
        └── fasta_species_clustered/            # CD-HIT clustered sequences
            ├── Species_name_1.fasta
            └── Species_name_2.fasta
```
