library(rjstat)
library(dplyr)

cso_rainfall_url <- 
  'http://www.cso.ie/StatbankServices/StatbankServices.svc/jsonservice/responseinstance/MTM01'

rainfall <- fromJSONstat(readLines(cso_rainfall_url))
names(rainfall)

rainfall$`Rainfall by Meteorological Weather Station, Month and Statistic` %>% 
  filter(`Meteorological Weather Station` == 'Clones') %>% 
  filter(Month == '2001M12')