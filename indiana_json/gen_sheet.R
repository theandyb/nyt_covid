library(tidyverse)
library(jsonlite)
library(googlesheets4)

# Get the data from the state's JSON feed(?)
json_data <- fromJSON(
  "https://www.coronavirus.in.gov/map/covid-19-indiana-daily-report-current.topojson")
VIZ_DATE <- json_data$objects$cb_2015_indiana_county_20m[[2]]$properties$VIZ_DATE
rm(json_data)

num_dates <- dim(VIZ_DATE[[13]])[1]
results <- vector(mode = "list", length = 92) # 92 counties in Indiana

for(i in 1:length(VIZ_DATE)){
  results[[i]] <- VIZ_DATE[[i]] %>%
    select(COUNTY_NAME, DATE, COVID_COUNT_CUMSUM, COVID_DEATHS_CUMSUM)
}
df <- bind_rows(results) %>%
  rename(County = COUNTY_NAME, 
         Date = DATE,
         Cases = COVID_COUNT_CUMSUM,
         Deaths = COVID_DEATHS_CUMSUM)

day_list <- sort(unique(df$Date))
final <- data.frame(County = sort(unique(df$County)))
for(day in day_list){
  little_df <- df %>% filter(Date == day) %>%
    select(County, Cases, Deaths) %>%
    arrange(County)
  colnames(little_df) <- c("County", paste0("cases-",day), paste0("deaths-",day))
  final <- full_join(final, little_df)
}

gs4_create("Indiana-2020_05_19", sheets = list(data = final))
