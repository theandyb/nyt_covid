library(tidyverse)
library(jsonlite)

test <- fromJSON("https://www.coronavirus.in.gov/map/covid-19-indiana-daily-report-current.topojson")
names(test)

test$type

names(test$objects)

test$objects$daily_statistics

test$objects$cb_2015_indiana_county_20m[[2]]$properties$COVID_COUNT %>% dim

test$objects$cb_2015_indiana_county_20m[[2]]$properties$NAME

test$objects$cb_2015_indiana_county_20m[[2]]$properties$VIZ_DATE[[1]] %>% 
  filter(DATE == as.Date("2020-03-10")) %>%
  select(COUNTY_NAME, DATE, COVID_COUNT_CUMSUM, COVID_DEATHS_CUMSUM)

#######################################################################################
VIZ_DATE <- test$objects$cb_2015_indiana_county_20m[[2]]$properties$VIZ_DATE
num_dates <- dim(VIZ_DATE[[13]])[1]
results <- vector(mode = "list", length = 92) # 92 counties in Indiana

for(i in 1:length(VIZ_DATE)){
  results[[i]] <- VIZ_DATE[[i]] %>%
    select(COUNTY_NAME, DATE, COVID_COUNT_CUMSUM, COVID_DEATHS_CUMSUM)
}
