create_cso_search_url <- function(search_term, offset){
  
  request_part_1 <- "http://www.cso.ie/px/pxeirestat/statire/search2003/searchresult.asp?place=statbank&Planguage=0&searchin=1&searchtext="
  request_part_2 <- "&forward=true&offset="
  request_part_3 <- "&showand=true"
  
  # replace spaces with URL encoding in search term
  search_term <-
    gsub(" ", "%20", search_term)
    
  paste0(request_part_1, search_term, request_part_2, offset, request_part_3)
}