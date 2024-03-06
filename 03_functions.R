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

run_cd_hit <- function(){
  system2("run_cd_hit.sh", stderr = TRUE)
}

# Function to calculate correlation
calculate_correlation <- function(df, vector) {
  matrix <- as.data.frame.matrix(table(na.omit(df)))
  correlation.matrix <- matrix(nrow = length(vector), ncol= length(vector))
  colnames(correlation.matrix) <- vector
  rownames(correlation.matrix) <- vector
  
  for (i in seq_along(vector)) {
    for (l in seq_along(vector)) {
      var1 <- nrow(matrix %>% filter(matrix[i] >= 1 & matrix[l] >= 1)) / nrow(matrix %>% filter(matrix[i] >= 1)) 
      correlation.matrix[i,l] <- var1
    }
  }
  
  return(correlation.matrix)
}

# Function to plot correlation matrix
plot_correlation_matrix <- function(correlation.matrix) {
  long <- reshape2::melt(correlation.matrix)
  
  output.p <- ggplot2::ggplot(long) + 
    ggplot2::geom_tile(aes(x=Var1, y=Var2, fill=value)) +
    ggplot2::geom_text(aes(x=Var1, y=Var2, label=round(value, 2)), size=4, col = "black") +
    ggplot2::ggtitle('Correlation of co-occurrence') +
    ggplot2::scale_fill_gradient(low = "white", high = "#66C2A5") +
    ggplot2::ylab('... how likely is to have a CODH from Clade ...') + 
    ggplot2::xlab('If an organism has a CODH from Clade...') +
    ggplot2::scale_x_discrete(position = "top")
  
  return(output.p)
}

# main correlation function
make_correlation_matrix <- function(df, vector) {
  correlation.matrix <- calculate_correlation(df, vector)
  plot <- plot_correlation_matrix(correlation.matrix)
  ggsave(paste('output/',Sys.Date(),'/correlation_matrix.png', sep=''), plot, width = 10, height = 10, units = "cm")
  return(plot)
}