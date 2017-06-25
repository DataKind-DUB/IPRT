
get_httr_html_content <- function(request){
# convenience wrapper for httr requests to get the inner HTML content, given a
# request.

  request %>%
    GET() %>%
    content("text") %>%
    read_html()
}
