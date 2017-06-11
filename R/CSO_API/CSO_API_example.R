library(rjstat)
library(dplyr)

source("./R/CSO_API/package/get_cso_dataset.R")

rainfall <- get_cso_dataset("MTM01") 

rainfall$`Rainfall by Meteorological Weather Station, Month and Statistic` %>% 
  filter(`Meteorological Weather Station` == 'Clones') %>% 
  filter(Month == '2001M12')