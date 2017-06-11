library(httr)
library(rvest)
library(magrittr)
library(stringr)

request_part_1 <- "http://www.cso.ie/px/pxeirestat/statire/search2003/searchresult.asp?place=statbank&Planguage=0&searchin=1&searchtext="
search_term <- "garda"
request_part_2 <- "&forward=true&offset="
offset <- 0
request_part_3 <- "&showand=true"

req <- paste0(request_part_1, search_term, request_part_2, offset, request_part_3)

# Get the html
res <-
  req %>%
  GET() %>% 
  content("text") %>% 
  read_html()

# extract the data

# current pages 15 results
current_page_results <-
  res %>% 
  html_nodes(".SearchHeadCell") %>% 
  html_text

# number of results overall
num_results <-
  (res %>% 
  html_node(".fl") %>% 
  html_text %>% 
  str_match("made (.*?) results"))[2] %>% 
  as.numeric()
  


