library(jsonlite)
library(tidyverse)
library(anytime)

json_data <- fromJSON("https://services2.arcgis.com/xRI3cTw3hPVoEJP0/arcgis/rest/services/DAILY_CUMULATIVE_COUNT_EDIT/FeatureServer/0/query?f=json&where=CUMULATIVECOUNT%20IS%20NOT%20NULL&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=DATE%20asc&resultOffset=0&resultRecordCount=32000&resultType=standard&cacheHint=true")

json_data$features$attributes %>%
  mutate(DATE = as.Date(anytime(DATE / 1000)))
