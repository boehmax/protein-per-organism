# Write fasta sequences for each species
write_fasta_per_species <- function(fasta_data){
  for(i in seq_len(nrow(fasta_data))) {
    seqinr::write.fasta(fasta_data$seq.text[i],  # fasta sequence
                        paste(fasta_data$protein_id[i], fasta_data$protein[i], fasta_data$clade[i], fasta_data$taxid[i], fasta_data$species.name[i], sep = ','),  # name of sequence
                        paste('output/',Sys.Date(),'/fasta_sorted_by_species/', gsub(" ", "_", fasta_data$species.name[i]), '.fasta', sep = ""),  # name of directory and file
                        open = "a", nbchar = 60, as.string = FALSE)
  }
  
}

is_directory_empty <- function(directory) {
  files <- list.files(directory)
  return(length(files) == 0)
}
