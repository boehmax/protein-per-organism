# Write fasta sequences for each species
sort_fasta_by_species <- function(fasta_data){
  for(i in seq_len(nrow(fasta_data))) {
    seqinr::write.fasta(fasta_data$seq.text[i],  # fasta sequence
                        paste(fasta_data$gene_name[i], fasta_data$protein[i], fasta_data$taxid[i], fasta_data$species.name[i], sep = ','),  # name of sequence
                        paste('output/',Sys.Date(),'fasta_sorted_by_species/', gsub(" ", "_", fasta_data$species.name[i]), '.fasta', sep = ""),  # name of directory and file
                        open = "a", nbchar = 60, as.string = FALSE)
  }
  
}

