#' Ensures the search results are useful to the user. Throws errors if
#' validation fails.
#'
#' @param search_term A search term used to get CSO datasets.
#' @param num_results The number of results for the current search term.
#' @param max_num_results The maximum number of results to return.
#' @keywords internal

validate_search_term <- function(search_term, num_results, max_num_results){

  if(num_results > max_num_results) {
    stop(paste(
        "Too many search results.
         Number of results:", num_results, "\n",
        "Max number of results: ", max_num_results, "\n",
        "Creating the results will take a long time based on current settings.
         If you wish to proceed, call search_statbank_datasets() with a larger max_num_results."))
  }

  if(num_results == 0) {
    stop("Your search query did not return any results.")
  }
}
