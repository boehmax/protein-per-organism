#create folder structure
create_output_folder <- function() {
  dir.create('output', showWarnings = FALSE)
  dir.create(paste('output/',Sys.Date(), sep=''), showWarnings = FALSE)
  dir.create(paste('output/',Sys.Date(),'/fasta_sorted_by_species', sep=''), showWarnings = FALSE)
  dir.create(paste('output/',Sys.Date(),'/fasta_sorted_by_species/fasta_species_clustered', sep=''), showWarnings = FALSE)
}


# Import Fasta files and clean up the data
import_fasta_and_cleanup <- function(file_path.fasta, protein_name){
  fasta.df <- phylotools::read.fasta(file_path.fasta) #reads fasta data nicely
  fasta.df$organism <- str_match(fasta.df$seq.name, "\\[(.*?)\\]")[,2]  #separates the organism name out of the fasta name if organism name is in [ ] paranthesis
  fasta.df$protein_id <- sub("\\s.*", "",
                              sub("\\/.*", "", fasta.df$seq.name) #gets the gene name, or another identifier that the seq name starts with
  )
  fasta.df$protein <- protein_name #adds the protein name to the data frame
  fasta.df <- fasta.df %>% na.omit() #removes NA values
  return(fasta.df)
}

assign_taxid <- function(fasta_data) {
  fasta_data <- fasta_data %>%
    rowwise() %>%
    mutate(taxid = taxizedb::name2taxid(organism, db='ncbi', out_type = 'summary')$id[1])
  
  # Unlist the taxid column
  fasta_data$taxid <- unlist(fasta_data$taxid)
  
  
  # convert taxid to a factor
  fasta_data$taxid <- as.factor(fasta_data$taxid)
  fasta_data <- na.omit(fasta_data)
  
  write.csv(fasta_data[1:6], file=paste('output/',Sys.Date(),'/fasta_total_slim.csv', sep=''), row.names=FALSE)
  return(fasta_data)
}

get_classification <- function(fasta_data) {
  classification_data <- lapply(fasta_data$taxid, function(i) taxizedb::classification(i, db='ncbi')[1])
  classification_data <- classification_data%>%
    flatten()
  saveRDS(classification_data, file = paste('output/',Sys.Date(),'/classification.RData', sep=''))
  return(classification_data)
}

check_species <- function(classification_data, fasta_data) {
  check <- lapply(classification_data, function(df) {
    if(length(df) == 3) {
      is.species <- nrow(df[df$rank == 'no rank', ]) <= 1 & nrow(df[df$rank == 'species', ]) >0 & nrow(df[df$rank == 'genus', ]) == 1
      taxid <- tail(df$id, n=1)
      organism <- tail(df$name, n=1)
      species.name <- if(nrow(df[df$rank == 'species', ]) == 1) df$name[df$rank == 'species'] else tail(df$name, n=1)
      data.frame(taxid, organism, is.species, species.name)
    } else {
      data.frame(taxid = NA, organism = NA, is.species = NA, species.name = NA)
    }
  })
  
  # Combine the list of dataframes into a single dataframe
  df <- do.call(rbind, check)
  fasta_data <- cbind(fasta_data, df %>% select(-taxid, -organism))
  
  saveRDS(fasta_data, file = paste('output/',Sys.Date(),'/fasta_species_check.RData', sep=''))
  write.csv(fasta_data, file=paste('output/',Sys.Date(),'/fasta_species_check.csv', sep=''), row.names=FALSE)
  return(fasta_data)
}

add_clade_information <- function(fasta_data){
  # Load clade information from text files
  clade_files <- list.files('data/clades', pattern = "Clade.*.txt", full.names = TRUE)
  
  # Define a function to read and process each file
  process_clade_file <- function(file, clade) {
    read_delim(file, col_names = c('protein.id','V2','V3','V4'), delim="/", show_col_types = FALSE) %>%
      select(protein.id) %>%
      mutate(clade = clade)
  }
  
  # Apply the function to each file and clade, then bind rows
  clade_assign <- map2_df(clade_files, LETTERS[1:length(clade_files)], process_clade_file) 
  
  # Merge the clade information with the fasta data
  fasta_data_clade <- left_join(fasta_data, clade_assign, by = c('protein_id' = 'protein.id'))
  fasta_data_clade <- fasta_data_clade %>% 
    replace_na(list(clade = 'unknown')) %>% 
    mutate_at(vars(clade), factor)
  write.csv(fasta_data_clade, file=paste('output/',Sys.Date(),'/fasta_clade.csv', sep=''), row.names=FALSE)
  return(fasta_data_clade)
}





