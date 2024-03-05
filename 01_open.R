# Import Fasta files and clean up the data
import_fasta_and_cleanup <- function(file_path.fasta, protein_name){
  fasta.df <- phylotools::read.fasta(file_path.fasta) #reads fasta data nicely
  fasta.df$organism <- str_match(fasta.codh$seq.name, "\\[(.*?)\\]")[,2]  #separates the organism name out of the fasta name if organism name is in [ ] paranthesis
  fasta.df$gene_name <- sub("\\s.*", "",
                              sub("\\/.*", "", fasta.codh$seq.name) #gets the gene name, or another identifier that the seq name starts with
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
  
  write.csv(fasta_data[1:6], file=paste(Sys.Date(),'_fasta_total_slim.csv', sep=''), row.names=FALSE)
  return(fasta_data)
}

get_classification <- function(fasta_data) {
  class.total.org2 <- lapply(fasta_data$taxid, function(i) taxizedb::classification(i, db='ncbi')[1])
  class.total.org2 <- class.total.org2%>%
    flatten()
  saveRDS(class.total.org2, file = paste('output/',Sys.Date(),'_classification.RData', sep=''))
  return(class.total.org2)
}

check_species <- function(classification_data, fasta_data) {
  check <- lapply(class.total.org2, function(df) {
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
  fasta_data <- cbind(fasta_data, df)
  
  saveRDS(fasta_data, file = paste('output/',Sys.Date(),'_fasta_species_check.RData', sep=''))
  write.csv(fasta_data, file=paste('output/',Sys.Date(),'_fasta_species_check.csv', sep=''), row.names=FALSE)
  return(fasta_data)
}







