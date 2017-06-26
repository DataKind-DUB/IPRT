
get_num_search_results <- function(search_term){
  # Returns total number of search results given a search term.
  req <- create_cso_search_url(search_term, 0)
  res <- get_httr_html_content(req)

  res <-
  (res %>%
      rvest::html_node(".fl") %>%
      rvest::html_text %>%
      stringr::str_match("made (.*?) results"))[2] %>%
    as.numeric()

  #  Handling NA when no result returned.
  if(is.na(res)) {
    0
  } else {
    res
  }

}
