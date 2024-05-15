library('phylotools') #importing FASTA
library('tidyverse') #data manipulation
library('taxize') #handeling taxonamie, load this first! then taxizedb
library('taxizedb') #using offline taxonamie database
library('seqinr') #for writing FastaFiles
library('reshape2') #for correlation matrix
library('ggplot2') #for correlation matrix
library('plotly') #for correlation matrix
library('ggtree') #for correlation matrix

# Color palette
clade_colours <- c("#FFD92F","#A6D854","#FC8D62","#E78AC3","#8DA0CB","#66C2A5","#56B4E9","#E5C494","#B3B3B3")

# Sourcing the functions
source('01_open.R')
source('02_clean.R')
source('03_functions.R')

# Main
 main <- function(){
   create_output_folder()
   # Import Fasta files and clean up the data
   codh <- import_fasta_and_cleanup('data/test_coos.fasta', 'coos')
   #cooc <- import_fasta_and_cleanup('data/cooc.fasta', 'cooc')
   
   # Merge the dataframes
   fasta.df <- rbind(codh)
   
   # Assign taxid
   fasta.df <- assign_taxid(fasta.df)
   
   # Get classification
   taxonimic_classification <- get_classification(fasta.df)
   
   # Check if taxonomic levels goes down to species and append fasta.df
   fasta.df <- check_species(taxonimic_classification, fasta.df)
   
   # Add clade information if available
   if (is_directory_empty('data/clades')) {
     print("No clade infromation has been added. The directory is empty.")
   } else {
     fasta.df <- add_clade_information(fasta.df)
   }

   
   # CleanUps
   fasta.df <- general_cleanup(fasta.df)
   fasta.df <- species_cleanup(fasta.df)
   
   # Write fasta sequences for each species
    write_fasta_per_species(fasta.df)
    
    # Run CD-Hit to remove duplicates on each organism individually, only works on LINUX
    #run_cd_hit()
    
    # Re-import clustered fasta files
    fasta.df <- clustered_fasta_import()
    
    # Make correlation matrix
    correlation_matrix <- make_correlation_matrix(fasta.df%>%
                              subset(select = c(organism, clade)), 
                            unique(fasta.df$clade))
    
    # How many CODH of the same clade in one organism
    clade_histograms2<- create_clade_histograms2(fasta.df)
    
    # Create and save tree of organism with clades
    create_and_save_tree_of_organism_with_clades(fasta.df)
    
 }