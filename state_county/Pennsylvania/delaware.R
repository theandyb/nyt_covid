library(tidyverse)
library(jsonlite)
library(anytime)

json_data <- fromJSON("https://services.arcgis.com/G4S1dGvn7PIgYd6Y/arcgis/rest/services/COVID19_Statistics_Delaware_County_PA/FeatureServer/3/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Date_of_Report%20desc&outSR=102100&resultOffset=0&resultRecordCount=30&resultType=standard&cacheHint=true")
json_data$features$attributes %>%
  select(Date_of_Report, Total_Cases, Total_Deaths) %>% 
  mutate(Date_of_Report = as.Date(anytime(Date_of_Report / 1000))) %>%
  arrange(Date_of_Report)