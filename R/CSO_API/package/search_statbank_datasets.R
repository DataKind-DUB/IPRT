library(httr)
library(rvest)
library(magrittr)
library(stringr)
source("./R/CSO_API/package/create_cso_search_url.R")
source("./R/CSO_API/package/get_httr_html_content.R")


search_statbank_datasets <- function(search_term){
  offset <- 0
  combined_dataset_names <- list()
  req <- create_cso_search_url(search_term, offset)
  res <- get_httr_html_content(req)
  
  # number of results overall
  num_results <-
    (res %>% 
       html_node(".fl") %>% 
       html_text %>% 
       str_match("made (.*?) results"))[2] %>% 
    as.numeric()
  
  search_offsets <-
    seq(15, num_results, 15)
  
  # Under construction!
  # for(offset in search_offsets){
  #   combined_dataset_names <- 
  #     list(combined_dataset_names, 
  #          list(
  #            res %>% 
  #              html_nodes(".SearchHeadCell") %>% 
  #              html_text
  #            )
  #          )
  #   
  # }
}
  
  
