library(jsonlite)
library(tidyverse)
library(anytime)

json_data <- fromJSON("https://services6.arcgis.com/K0qS4r8AEJxrE8em/arcgis/rest/services/Cumulative_Cases_57/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=ObjectId%2CCUMULATIVE_COUNT%2CDATE&orderByFields=DATE%20asc&resultOffset=0&resultRecordCount=32000&resultType=standard&cacheHint=true")

json_data$features$attributes %>%
  mutate(DATE = anytime(DATE / 1000) %>% as.Date()) %>%
  mutate(DATE = DATE - 1) %>%
  select(DATE, CUMULATIVE_COUNT) %>%
  knitr::kable()
