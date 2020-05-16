library(tidyverse)
library(jsonlite)
library(anytime)

json_data <- fromJSON("https://services9.arcgis.com/dKYZjkrFtNq9jT4H/arcgis/rest/services/CumulativeTable_Public/FeatureServer/0/query?f=json&where=Total%20IS%20NOT%20NULL&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Date%20asc&resultOffset=0&resultRecordCount=32000&resultType=standard&cacheHint=true")


df <- json_data$features$attributes %>%
  mutate(Date = as.Date(anytime(Date / 1000))) %>%
  select(Date, Daily, Total)
