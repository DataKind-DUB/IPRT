
search_statbank_datasets <- function(search_term, max_num_results = 500){
  offset <- 0
  num_results <- get_num_search_results(search_term)
  validate_search_term(search_term, num_results, max_num_results)

  search_offsets <-
    seq(0, num_results, 15)

  combined_dataset_names <- vector("list", length(search_offsets) +1)

  # Loop through all the results from search term
  for(offset in search_offsets) {
    current_index <- (offset / 15 + 1)
    print(paste("Requesting", current_index, "out of", length(search_offsets)))
    req <- create_cso_search_url(search_term, offset)
    res <- get_httr_html_content(req)
    combined_dataset_names[current_index] <-
      list(res %>%
             html_nodes(".SearchHeadCell") %>%
             html_text)
  }
  search_results_to_dataframe(combined_dataset_names)
}
