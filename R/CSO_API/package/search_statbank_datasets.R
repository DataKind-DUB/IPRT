library(httr)
library(rvest)
library(magrittr)
source("./R/CSO_API/package/create_cso_search_url.R")
source("./R/CSO_API/package/get_httr_html_content.R")
source("./R/CSO_API/package/get_num_search_results.R")
source("./R/CSO_API/package/search_results_to_dataframe.R")
source("./R/CSO_API/package/validate_search_term.R")

search_statbank_datasets <- function(search_term, max_num_results = 500){
  offset <- 0
  
  num_results <- get_num_search_results(search_term)
  
  validate_search_term(search_term, num_results, max_num_results)
  
  search_offsets <-
    seq(0, num_results, 15)
  
  combined_dataset_names <- vector("list", length(search_offsets) +1)
  
  # Loop through all the results from search term
  for(offset in search_offsets){
  
    current_index <- (offset/15 + 1)
    print(current_index)
    req <- create_cso_search_url(search_term, offset)
    res <- get_httr_html_content(req)
    combined_dataset_names[current_index] <-
           list(
             res %>%
               html_nodes(".SearchHeadCell") %>%
               html_text
             )
  }
  
  search_results_to_dataframe(combined_dataset_names)
  
}
  
  
