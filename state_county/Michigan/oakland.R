library(tidyverse)
library(jsonlite)
library(anytime)

json_data <- fromJSON("https://services1.arcgis.com/GE4Idg9FL97XBa3P/arcgis/rest/services/CumulativeCaseTotals_4/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Date%20desc&resultOffset=0&resultRecordCount=200&resultType=standard&cacheHint=true")

json_data$features$attributes %>% 
  mutate(Date = as.Date(anydate(Date/1000))) %>%
  select(Date, Sum_) %>% arrange(Date)
