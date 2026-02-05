## _targets.R file for reproducible analysis pipeline
library(targets)
library(tarchetypes)

# Load configuration (optional - can be customized by users)
if (file.exists("_targets_config.R")) {
  config <- source("_targets_config.R")$value
} else {
  # Default configuration
  config <- list(
    fasta_path = "data/protein.fasta",
    protein_type = "protein",
    clade_colours = c("#FFD92F","#A6D854","#FC8D62","#E78AC3","#8DA0CB","#66C2A5","#56B4E9","#E5C494","#B3B3B3"),
    run_clustering = TRUE,
    generate_tree = FALSE
  )
}

# Load functions from R scripts
source("01_open.R")
source("02_clean.R")
source("03_functions.R")

# Load required packages
tar_option_set(
  packages = c(
    "phylotools",
    "tidyverse",
    "taxize",
    "taxizedb",
    "seqinr",
    "reshape2",
    "ggplot2",
    "plotly",
    "ggtree"
  )
)

# Define color palette
clade_colours <- config$clade_colours

# Define the targets pipeline
list(
  # Create output folder structure
  tar_target(
    output_folder,
    {
      create_output_folder()
      paste('output/', Sys.Date(), sep='')
    }
  ),
  
  # Get user inputs (path to fasta and protein type)
  # Note: For non-interactive use, these can be set as parameters
  tar_target(
    fasta_path,
    config$fasta_path,
    format = "file"
  ),
  
  tar_target(
    protein_type,
    config$protein_type
  ),
  
  # Import FASTA files and clean up
  tar_target(
    protein_data,
    import_fasta_and_cleanup(fasta_path, protein_type)
  ),
  
  # Merge dataframes (in case multiple proteins are added in future)
  tar_target(
    fasta_df_raw,
    rbind(protein_data)
  ),
  
  # Assign taxonomic IDs
  tar_target(
    fasta_df_with_taxid,
    assign_taxid(fasta_df_raw)
  ),
  
  # Get taxonomic classification
  tar_target(
    taxonomic_classification,
    get_classification(fasta_df_with_taxid)
  ),
  
  # Check species level classification
  tar_target(
    fasta_df_with_species,
    check_species(taxonomic_classification, fasta_df_with_taxid)
  ),
  
  # Add clade information if available
  tar_target(
    fasta_df_with_clade,
    {
      if (is_directory_empty('data/clades')) {
        message("No clade information has been added. The directory is empty.")
        fasta_df_with_species
      } else {
        add_clade_information(fasta_df_with_species)
      }
    }
  ),
  
  # General cleanup
  tar_target(
    fasta_df_cleaned,
    general_cleanup(fasta_df_with_clade)
  ),
  
  # Species-specific cleanup
  tar_target(
    fasta_df_species_cleaned,
    species_cleanup(fasta_df_cleaned)
  ),
  
  # Write FASTA files per species
  tar_target(
    fasta_files_written,
    {
      write_fasta_per_species(fasta_df_species_cleaned)
      "fasta_files_written"
    }
  ),
  
  # Run CD-HIT clustering (Linux only) - conditional based on config
  tar_target(
    cd_hit_completed,
    {
      if (config$run_clustering) {
        run_cd_hit()
      } else {
        message("Skipping CD-HIT clustering (disabled in config)")
      }
      "cd_hit_completed"
    }
  ),
  
  # Re-import clustered FASTA files (or use original if clustering skipped)
  tar_target(
    fasta_df_clustered,
    {
      if (config$run_clustering && dir.exists(paste0('output/', Sys.Date(), '/fasta_sorted_by_species/fasta_species_clustered'))) {
        clustered_fasta_import()
      } else {
        message("Using original (non-clustered) data")
        fasta_df_species_cleaned
      }
    },
    depends = cd_hit_completed
  ),
  
  # Create correlation matrix
  tar_target(
    correlation_matrix_plot,
    make_correlation_matrix(
      fasta_df_clustered %>% subset(select = c(organism, clade)),
      sort(unique(fasta_df_clustered$clade))
    )
  ),
  
  # Create clade histograms
  tar_target(
    clade_histograms,
    create_clade_histograms2(fasta_df_clustered)
  ),
  
  # Create phylogenetic tree (conditional based on config)
  tar_target(
    phylogenetic_tree,
    {
      if (isTRUE(config$generate_tree)) {
        create_and_save_tree_of_organism_with_clades(fasta_df_clustered)
      } else {
        message("Phylogenetic tree generation skipped (disabled in config)")
        NULL
      }
    }
  )
)
