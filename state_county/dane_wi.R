# Pull cumulative case and death counts by date
# from Dane County, WI

library(tidyverse)
library(jsonlite)

json_data <- fromJSON("https://services.arcgis.com/lx96Ahunbwmk5g5p/arcgis/rest/services/CaseCount_vw/FeatureServer/0/query?f=json&where=Date%3C%3E%27Null%27&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outSR=102100&resultOffset=0&resultRecordCount=32000&resultType=standard&cacheHint=true")

df <- json_data$features$attributes %>% 
  select(Date, Total_cases, Deaths) %>%
  mutate(Date = paste0(0, Date, "/2020")) %>%
  mutate(Date = as.Date(Date, "%m/%d/%Y")) %>%
  replace_na(list(Deaths = 0))

cumulative_deaths <- df$Deaths[1]

for(i in 2:length(df$Date)){
  cumulative_deaths <- c(cumulative_deaths, df$Deaths[i] + cumulative_deaths[i-1])
}

df$cDeath <- cumulative_deaths
