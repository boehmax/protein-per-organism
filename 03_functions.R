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

how_many_clades_per_organism <- function(fasta_data) {
  # Create a data frame with organism and clade
  organism.and.clade <- data.frame(fasta_data$organism, fasta_data$clade)
  
  # Create a matrix from the data frame
  organism.and.clade.matrix <- as.data.frame.matrix(table(organism.and.clade))
  
  # Calculate the total for each clade
  organism.and.clade.matrix$total <- rowSums(organism.and.clade.matrix)
  
  return(organism.and.clade.matrix)
}


create_clade_histograms <- function(fasta_data, clade_colors = c("#FFD92F","#A6D854","#FC8D62","#E78AC3","#8DA0CB","#66C2A5","#56B4E9","#E5C494","#B3B3B3")) {
  fasta_data.matrix <- how_many_clades_per_organism(fasta_data)
  # Melt the data and filter rows where value > 0
  filtered_data <- reshape2::melt(fasta_data.matrix) %>%
    filter(value > 0)
  
  # Initialize a list to store all plots
  clade_histograms <- list()
  
  # Determine the number of clades dynamically
  num_clades <- length(unique(fasta_data$clade))
  
  # Loop over each clade
  for(i in 1:num_clades){
    # Subset the data for the current clade
    clade_data <- subset(filtered_data, as.character(variable) == as.character(unique(fasta_data$clade)[i]))
    
    # Create a histogram for the current clade
    clade_histograms[[i]] <- ggplot(clade_data, aes(x=value, fill = variable)) + 
      geom_histogram(col = 'white', binwidth = 1, fill = clade_colors[i]) +
      xlim(0,8)
  }
  
  # Combine all clade histograms into a single figure
  combined_histogram <- subplot(clade_histograms, nrows = 2) %>%
    layout(title = 'Multiples of one clade distribution')
  # Initialize a list to store the annotations
  annotations <- list()
  
  # Loop over each clade to generate the annotations
  for(i in 1:num_clades){
    annotations[[i]] <- list(
      x = (i-1)/num_clades + 1/(2*num_clades), 
      y = ifelse(i %% 2 == 0, 0.35, 0.9), 
      text = paste("Clade", as.character(unique(fasta_data$clade)[i])), 
      showarrow = F, 
      xref='paper', 
      yref='paper', 
      xanchor = "center",
      showarrow = FALSE
    )
  }
  
  # Add annotations to the combined histogram
  annotated_histogram <- combined_histogram %>% layout(annotations = annotations)
  return(annotated_histogram)
}

create_clade_histograms2 <- function(fasta_data, clade_colors = c("#FFD92F","#A6D854","#FC8D62","#E78AC3","#8DA0CB","#66C2A5","#56B4E9","#E5C494","#B3B3B3")) {
  fasta_data.matrix <- how_many_clades_per_organism(fasta_data)
  # Melt the data and filter rows where value > 0
  filtered_data <- suppressMessages(suppressWarnings(reshape2::melt(fasta_data.matrix))) %>%
    filter(value > 0)
  
  # Determine the number of clades dynamically
  num_clades <- length(unique(fasta_data$clade))
  
  # Create a histogram for each clade
  clade_histogram <- ggplot(filtered_data, aes(x=value, fill = variable)) + 
    geom_histogram(col = 'white', binwidth = 1) +
    scale_fill_manual(values = clade_colors) +
    facet_wrap(~variable, nrow = 2) +
    theme_minimal() +
    theme(strip.text = element_text(size = 12), legend.position = "none")+
    labs(x ="Number of CODH in one organism", y = "Count of Organism")
  
  ggsave(paste('output/',Sys.Date(),'/clade_histogram.png', sep=''), clade_histogram, width = 10, height = 10, units = "cm")
  return(clade_histogram)
}
