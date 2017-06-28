#' Takes the raw output list from the web scraping of the Statbanks search
#' page and returns a data frame. For internal use of the package.
#'
#' @param request A completed httr request.
#' @return The inner HTML content of the httr request.
#' @keywords internal
#' @importFrom magrittr %>% %<>%
#'

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
