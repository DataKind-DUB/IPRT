
search_results_to_dataframe <- function(search_results){
  # Tidy up dataset code and description into data frame.
  search_results %<>%
    unlist() %>%
    as.data.frame()

  names(search_results)[1] <- "search_text"

  search_results %>%
    tidyr::separate(search_text,
                    into = c("dataset_code", "dataset_desc"),
                    sep = ": ")
}
