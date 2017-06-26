
get_httr_html_content <- function(request){
# convenience wrapper for httr requests to get the inner HTML content, given a
# request.

  request %>%
    httr::GET() %>%
    httr::content("text") %>%
    xml2::read_html()
}
