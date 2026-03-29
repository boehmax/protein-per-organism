# _targets_config.R - Configuration file for the targets pipeline
# 
# This file contains user-configurable parameters for the pipeline.
# Edit these values to customize your analysis without modifying _targets.R

# Input file paths
config <- list(
  # Path to the FASTA file containing protein sequences
  fasta_path = "data/protein.fasta",
  
  # Type of protein being analyzed
  protein_type = "protein",
  
  # Path to clade information (if available)
  clade_data_path = "data/clades",
  
  # Color palette for visualizations
  clade_colours = c("#FFD92F", "#A6D854", "#FC8D62", "#E78AC3", 
                    "#8DA0CB", "#66C2A5", "#56B4E9", "#E5C494", "#B3B3B3"),
  
  # CD-HIT parameters (for clustering)
  cd_hit_identity = 0.90,  # Sequence identity threshold
  cd_hit_word_size = 5,     # Word size for clustering
  
  # Output options
  output_base_dir = "output",
  
  # Whether to run CD-HIT (set to FALSE if not on Linux)
  run_clustering = TRUE,
  
  # Whether to generate phylogenetic tree (computationally expensive)
  generate_tree = FALSE
)

# Export the configuration
config
