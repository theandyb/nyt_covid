library(tidyverse)
library(jsonlite)

cases_json <- fromJSON("https://services5.arcgis.com/8Q02ELWlq5TYUASS/arcgis/rest/services/Pos_Cases_by_Coll_Date_View/FeatureServer/0/query?f=json&where=Date2%3C%3E%27%27+&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&groupByFieldsForStatistics=Date2&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22%2C%22onStatisticField%22%3A%22Cumul_Count_by_Coll_Date%22%2C%22outStatisticFieldName%22%3A%22value%22%7D%5D&resultType=standard&cacheHint=true")
cases <- cases_json$features$attributes %>%
  rename(cases = value)

death_json <- fromJSON("https://services5.arcgis.com/8Q02ELWlq5TYUASS/arcgis/rest/services/Deaths_by_Date_View/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&groupByFieldsForStatistics=Date2&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22%2C%22onStatisticField%22%3A%22Death_Date_Cumulative_Freq%22%2C%22outStatisticFieldName%22%3A%22value%22%7D%5D&resultType=standard&cacheHint=true")
deaths <- death_json$features$attributes %>%
  rename(deaths = value)

final <- full_join(cases, deaths) %>% 
  arrange(Date2) %>%
  select(Date2, cases, deaths)
final
