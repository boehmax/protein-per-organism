# Quick Start Guide for targets Pipeline

This guide helps you get started with the reproducible `targets` pipeline for protein analysis.

## Installation

1. **Install R packages** (if not already installed):
   ```r
   install.packages(c(
     "targets",
     "phylotools",
     "tidyverse",
     "taxize",
     "taxizedb",
     "seqinr",
     "reshape2",
     "ggplot2",
     "plotly",
     "ggtree"
   ))
   ```

2. **Install CD-HIT** (Linux only, for clustering):
   Follow instructions at: https://github.com/weizhongli/cdhit

## Basic Usage

### 1. Prepare Your Data

Place your FASTA file in the `data/` directory:
```
protein-per-organism/
├── data/
│   ├── protein.fasta       # Your protein sequences
│   └── clades/             # (Optional) Clade information files
│       ├── CladeA.txt
│       └── CladeB.txt
```

### 2. Configure the Pipeline

Edit `_targets_config.R` to match your data:
```r
config <- list(
  fasta_path = "data/your_protein_file.fasta",  # Your FASTA file
  protein_type = "NiCODH",                      # Your protein type
  run_clustering = TRUE,                         # TRUE if on Linux with CD-HIT
  generate_tree = FALSE                          # Set TRUE for phylogenetic tree
)
```

### 3. Run the Pipeline

From the command line:
```bash
Rscript run_targets.R
```

Or from within R:
```r
library(targets)
tar_make()
```

### 4. Check Results

Results are saved in the `output/YYYY-MM-DD/` directory:
- `correlation_matrix.png` - Correlation heatmap of clades
- `clade_histogram.png` - Distribution of clades per organism
- CSV files with intermediate data

## Common Tasks

### Visualize the Pipeline
```bash
Rscript run_targets.R visualize
```
This creates an interactive network diagram showing all analysis steps and their dependencies.

### Check What Needs to Run
```bash
Rscript run_targets.R outdated
```
Shows which steps need to be re-run based on changes to data or code.

### Re-run Specific Steps

If you only changed clade assignments:
```r
library(targets)
tar_invalidate(starts_with("fasta_df_with_clade"))
tar_make()
```

### Access Intermediate Results
```r
library(targets)

# Load the cleaned data
cleaned_data <- tar_read(fasta_df_clustered)

# Load the correlation matrix
cor_matrix <- tar_read(correlation_matrix_plot)
```

## Troubleshooting

### Issue: "CD-HIT not found"
- **Solution**: Install CD-HIT or set `run_clustering = FALSE` in `_targets_config.R`

### Issue: "NCBI taxonomy database not found"
- **Solution**: Download the taxonomy database:
  ```r
  library(taxizedb)
  db_download_ncbi()
  ```

### Issue: Pipeline runs but creates empty plots
- **Solution**: Check that your FASTA file has organisms in `[brackets]` format
- Make sure clade information files exist if using clade analysis

### Issue: Want to start fresh
```bash
Rscript run_targets.R clean
```
This removes all cached results. Next run will start from scratch.

## Example Workflow

Complete example for analyzing NiCODH proteins:

```r
# 1. Set up configuration
# Edit _targets_config.R:
config <- list(
  fasta_path = "data/nicodh.fasta",
  protein_type = "NiCODH",
  run_clustering = TRUE
)

# 2. Prepare taxonomy database (first time only)
library(taxizedb)
db_download_ncbi()

# 3. Run the pipeline
library(targets)
tar_make()

# 4. View results
tar_read(correlation_matrix_plot)
tar_read(clade_histograms)

# 5. Export results for publication
ggsave("publication_figure.pdf", tar_read(correlation_matrix_plot))
```

## Next Steps

- Read the full [targets package documentation](https://docs.ropensci.org/targets/)
- Customize visualizations by editing functions in `03_functions.R`
- Add new analysis steps by editing `_targets.R`
- Learn about [parallel processing](https://books.ropensci.org/targets/performance.html) to speed up large datasets

## Getting Help

- View pipeline structure: `tar_manifest()`
- Debug a specific target: `tar_load(target_name)` then inspect the object
- See target metadata: `tar_meta()`
- For targets help: https://docs.ropensci.org/targets/
- For project issues: https://github.com/boehmax/protein-per-organism/issues
