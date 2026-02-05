# Proteins per Organism

This script takes a list of FASTA files containing NiCODH, adds various types of information, and generates several plots for analysis.

## Quick Links

- [Quick Start Guide](QUICKSTART_TARGETS.md) - Get started with the targets pipeline
- [Workflow Comparison](WORKFLOW_COMPARISON.md) - Traditional vs targets pipeline
- [Data Structure](DATA_STRUCTURE.md) - Input/output file format documentation
- [Main README](#how-to-use) - Detailed usage instructions below

## Prerequisites

Before running this script, make sure you have the following R packages installed:

- phylotools: for importing FASTA files
- tidyverse: for data manipulation
- taxize and taxizedb: for handling taxonomies
- seqinr: for writing FASTA files
- reshape2, ggplot2, plotly, and ggtree: for creating correlation matrices
- **targets: for reproducible pipeline management (recommended)**

You should also have CD-HIT installed and compiled on your system. Please note that the CD-HIT functionality only works on Linux systems.

To install the targets package in R:
```r
install.packages("targets")
```

## How to Use

### Option 1: Using the targets Pipeline (Recommended for Reproducibility)

The targets package provides a reproducible, efficient pipeline that automatically manages dependencies and caches results:

1. **Configure the pipeline**: Edit `_targets_config.R` to customize your analysis:
   - `fasta_path`: Path to your FASTA file (default: "data/protein.fasta")
   - `protein_type`: Type of protein (default: "protein")
   - `run_clustering`: Whether to run CD-HIT clustering (default: TRUE, requires Linux)
   - `generate_tree`: Whether to generate phylogenetic tree (default: FALSE)
   - Other visualization and processing options

2. **Run the pipeline**:
   ```bash
   Rscript run_targets.R
   ```

3. **Additional targets commands**:
   ```bash
   # Visualize the pipeline graph
   Rscript run_targets.R visualize
   
   # Check which steps need to be re-run
   Rscript run_targets.R outdated
   
   # View pipeline manifest
   Rscript run_targets.R manifest
   
   # Get help
   Rscript run_targets.R help
   ```

**Benefits of using targets:**
- **Reproducibility**: Clear pipeline definition ensures consistent results
- **Efficiency**: Only re-runs steps that have changed
- **Caching**: Intermediate results are saved automatically
- **Dependency management**: Automatically tracks which steps depend on others
- **Pipeline visualization**: See the entire workflow at a glance

### Option 2: Using the Traditional Workflow

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

## Understanding the targets Workflow

The `targets` pipeline breaks down the analysis into discrete, reproducible steps:

1. **Output folder creation**: Sets up directory structure
2. **Data import**: Reads FASTA files and extracts metadata
3. **Taxonomic assignment**: Assigns taxonomic IDs to organisms
4. **Classification**: Retrieves full taxonomic classification
5. **Species validation**: Checks that sequences are at species level
6. **Clade annotation**: Adds clade information if available
7. **Data cleaning**: Removes invalid or incomplete entries
8. **FASTA export**: Writes individual FASTA files per species
9. **Clustering (optional)**: Runs CD-HIT to remove duplicates
10. **Visualization**: Creates correlation matrices and histograms

Each step is cached, so if you modify data or parameters, only affected steps will re-run.

### Working with the Pipeline

To inspect the pipeline status:
```r
library(targets)

# See all targets
tar_manifest()

# Check what needs to run
tar_outdated()

# Load a specific result
tar_read(fasta_df_clustered)

# Visualize dependencies
tar_visnetwork()
```

For more information about the targets package, visit: https://docs.ropensci.org/targets/

