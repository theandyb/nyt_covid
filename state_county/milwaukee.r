library(tidyverse)
library(jsonlite)

# count_json <- fromJSON("https://services5.arcgis.com/8Q02ELWlq5TYUASS/arcgis/rest/services/Counts_by_Date_View/FeatureServer/0/query?f=json&where=(Pos_Date%3Ctimestamp%20%272020-04-26%2004%3A00%3A00%27%20OR%20Pos_Date%20%3E%20timestamp%20%272020-04-27%2003%3A59%3A59%27)&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&groupByFieldsForStatistics=Date2&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22%2C%22onStatisticField%22%3A%22Pos_Date_Cumulative_Freq%22%2C%22outStatisticFieldName%22%3A%22value%22%7D%5D&resultType=standard&cacheHint=true")
# 
# cases <- count_json$features$attributes %>%
#   rename(cases = value) %>%
#   mutate(date = paste0(0,Date2,"/2020")) %>%
#   mutate(date = as.Date(date, "%m/%d/%Y")) %>%
#   select(date, cases) %>%
#   arrange(date)
# 
# 
# death_json <- fromJSON("https://services5.arcgis.com/8Q02ELWlq5TYUASS/arcgis/rest/services/Deaths_by_Date_View/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&groupByFieldsForStatistics=Date2&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22%2C%22onStatisticField%22%3A%22Death_Date_Cumulative_Freq%22%2C%22outStatisticFieldName%22%3A%22value%22%7D%5D&resultType=standard&cacheHint=true")
# 
# deaths <- death_json$features$attributes %>%
#   rename(deaths = value) %>%
#   mutate(date = paste0(0,Date2,"/2020")) %>%
#   mutate(date = as.Date(date, "%m/%d/%Y")) %>%
#   select(date, deaths) %>%
#   arrange(date)

cases_json <- fromJSON("https://services5.arcgis.com/8Q02ELWlq5TYUASS/arcgis/rest/services/Counts_by_Date_View/FeatureServer/0/query?f=json&where=(Pos_Date%3Ctimestamp%20%272020-05-14%2004%3A00%3A00%27%20OR%20Pos_Date%20%3E%20timestamp%20%272020-05-15%2003%3A59%3A59%27)&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&groupByFieldsForStatistics=Date2&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22%2C%22onStatisticField%22%3A%22Pos_Date_Cumulative_Freq%22%2C%22outStatisticFieldName%22%3A%22value%22%7D%5D&resultType=standard&cacheHint=true")
cases <- cases_json$features$attributes %>%
  rename(cases = value)

death_json <- fromJSON("https://services5.arcgis.com/8Q02ELWlq5TYUASS/arcgis/rest/services/Deaths_by_Date_View/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&groupByFieldsForStatistics=Date2&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22%2C%22onStatisticField%22%3A%22Death_Date_Cumulative_Freq%22%2C%22outStatisticFieldName%22%3A%22value%22%7D%5D&resultType=standard&cacheHint=true")
deaths <- death_json$features$attributes %>%
  rename(deaths = value)

final <- full_join(cases, deaths) %>% 
  arrange(Date2) %>%
  select(Date2, cases, deaths)
final
