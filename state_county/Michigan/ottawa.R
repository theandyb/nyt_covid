library(tidyverse)
library(jsonlite)
library(anytime)

json_data <- fromJSON("https://services2.arcgis.com/ixRLoNIl4gmM9jgg/arcgis/rest/services/COVID19_Cases_By_Date_(Public)/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Date%20asc&resultOffset=0&resultRecordCount=32000&resultType=standard&cacheHint=true")
json_data$features$attributes %>% 
  select(Date, CumulativeTotalCases, CumulativeTotalDeaths) %>%
  mutate(Date = as.Date(anytime(Date / 1000)))
  
