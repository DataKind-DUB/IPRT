library(httr)
library(rvest)
library(magrittr)
source("./R/CSO_API/package/create_cso_search_url.R")
source("./R/CSO_API/package/get_httr_html_content.R")

get_num_search_results <- function(search_term){
  # Returns total number of search results given a search term.
    
  req <- create_cso_search_url(search_term, 0)
  res <- get_httr_html_content(req)
  
  (res %>%
      html_node(".fl") %>% 
      html_text %>% 
      stringr::str_match("made (.*?) results"))[2] %>% 
    as.numeric()
}