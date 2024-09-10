library('phylotools') #importing FASTA
library('tidyverse') #data manipulation
library('taxize') #handeling taxonamie, load this first! hten taxizedb
library('taxizedb') #usinf offline taxonamie database
#source("functions/class2treeMod.R") #add some functions that are helpfull
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
   #Ask User if they want to reload an old run
   fasta.df <- reload_request()
   print('Creating outpud folders...')
   create_output_folder()
   
   if(is.data.frame(fasta.df)==FALSE){ #if the reload request was denied, continue with loading the new data
   
   # Import Fasta files and clean up the data
   path_to_fasta <- readline("Please provide path to .fasta file: ")
   type_of_protein <- readline("Type of protein: ")
   print('Importing new data...')
   protein <- import_fasta_and_cleanup(path_to_fasta, type_of_protein)
   #cooc <- import_fasta_and_cleanup('data/cooc.fasta', 'cooc')
   
   # Merge the dataframes
   fasta.df <- rbind(protein)
   
   # Assign taxid
   print('Assigning tax IDs based on acession number...')
   fasta.df <- assign_taxid(fasta.df)
   
   # Get classification
   print('Gets calssification of tax IDs...')
   taxonimic_classification <- get_classification(fasta.df)
   
   # Check if taxonomic levels goes down to species and append fasta.df
   print('Checks which protein stems from an assigned organism...')
   fasta.df <- check_species(taxonimic_classification, fasta.df)
   
   # Add clade information if available
   if (is_directory_empty('data/clades')) {
     print("No clade infromation has been added. The directory is empty.")
   } else {
     fasta.df <- add_clade_information(fasta.df)
   }

   
   # CleanUps
   print('Cleaning up...')
   fasta.df <- general_cleanup(fasta.df)
   fasta.df <- species_cleanup(fasta.df)
   
   # Write fasta sequences for each species
   print('Exporting .fasta sorted by species')
    write_fasta_per_species(fasta.df)
    
    # Run CD-Hit to remove duplicates on each organism individually, only works on LINUX
    print('Running CD-Hit on proteins per species with default settings...')
    run_cd_hit()
    
    # Re-import clustered fasta files
    fasta.df <- clustered_fasta_import()
 }
    print('Preparing plots...')
    # Make correlation matrix
    correlation_matrix <- make_correlation_matrix(fasta.df%>%
                              subset(select = c(organism, clade)), 
                            sort(unique(fasta.df$clade)))
    
    # How many CODH of the same clade in one organism
    clade_histograms2<- create_clade_histograms2(fasta.df)
    
    # Create and save tree of organism with clades
   # create_and_save_tree_of_organism_with_clades(fasta.df)
    
 }
 
