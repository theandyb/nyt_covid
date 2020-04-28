library(tidyverse)
library(jsonlite)

json_data <- fromJSON("https://opendata.arcgis.com/datasets/b913e9591eae4912b33dc5b4e88646c5_10.geojson")

df <- json_data$features$properties %>% filter(GEO == "County") %>%
  select(NAME, LoadDttm, POSITIVE, DEATHS) %>%
  mutate(Date = str_sub(LoadDttm,1,10)) %>%
  mutate(Date = as.Date(Date)) %>%
  select(-LoadDttm) %>% arrange(Date)

data_for_date <- function(df, Day){
  df %>% filter(Date==Day)
}

data_for_county <- function(df, County){
  df %>% filter(NAME==County)
}
