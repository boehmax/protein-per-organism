general_cleanup <- function(df){
  df <- df %>% na.omit()
  return(df)
}

species_cleanup <- function(df){
  df <- df %>% filter(is.species == TRUE)
  return(df)
}