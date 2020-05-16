library(tidyverse)
library(jsonlite)

json_data <- fromJSON("https://opendata.arcgis.com/datasets/b31b6c48463c4ea98a57fe23df18fe62_0.geojson")

json_data$features$properties %>% dim()

json_data$features %>% head

data <- json_data$features$properties %>%
  select(DateReported, Deaths, Death_Announced) %>%
  mutate(DateReported = as.Date(DateReported),
         Death_Announced = as.Date(Death_Announced))

dayList <- seq(min(data$DateReported), max(data$Death_Announced, na.rm=T), "day") %>% 
  as.character()

final <- vector(mode = "list",
                length = length(dayList))
names(final) <- dayList

for(day in dayList){
  ddate <- as.Date(day)
  cases <- data %>% filter(DateReported <= ddate) %>% dim() %>% .[1]
  deaths <- data %>% 
    filter(Deaths==1) %>%
    filter(Death_Announced <= ddate) %>% dim() %>% .[1]
  final[[day]] <- tibble(Date = day, cases = cases, deaths = deaths)
}

final_table <- bind_rows(final)
knitr::kable(final_table)

