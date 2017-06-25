
get_cso_dataset <- function(cso_dataset_code) {
    cso_base_url <- "http://www.cso.ie/StatbankServices/StatbankServices.svc/jsonservice/responseinstance/"
    
    fromJSONstat(readLines(paste0(cso_base_url, cso_dataset_code)))
    
}

