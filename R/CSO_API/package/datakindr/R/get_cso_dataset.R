#' Gets a CSO.ie StatBank dataset when given a dataset code.
#'
#' @param cso_dataset_code A dataset code.
#' @return A data frame of arbitrary dimension and size containing a StatBank dataset.
#' @examples
#' get_cso_dataset("LRM07")
#' @export

get_cso_dataset <- function(cso_dataset_code){
  cso_base_url <-
    'http://www.cso.ie/StatbankServices/StatbankServices.svc/jsonservice/responseinstance/'

  rjstat::fromJSONstat(readLines(paste0(cso_base_url, cso_dataset_code)))

}

