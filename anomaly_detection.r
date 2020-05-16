# Anomally detection
# Version 0.1
#
# As of now, this only checks county case and death numbers by 
# date and returns counties with counts that decrease
#
# Future versions of this might want to look at some sort of 
# running "growth-rate" and report counties that see an 
# unusual jump in either cases or deaths

library(tidyverse)
library(magrittr)
counties <- read_csv("data/covid-19-data/us-counties.csv")

# Build master list of states and counties

state_county <- counties %>%
  select(state, county) %>%
  group_by(state) %>%
  summarise_all(funs(toString(unique(.)))) 

state_county %<>% separate_rows(county, sep = ",") %>% 
  mutate(county = str_trim(county))

# create data frame
#how many days will we need?
day_list <- vector("list")

for(cur_date in unique(counties$date)){
  df <- counties %>% 
    filter(date == cur_date) %>% 
    select(state, county, cases, deaths)
  df %<>% right_join(state_county, by = c("state", "county")) %>%
    replace_na(list(cases = 0, deaths = 0))
  day_list[[as.character(cur_date)]] <- df
}
names(day_list) <- as.character(unique(counties$date))

### Loop through dates

final <- data.frame(state = character(0), county = character(0), 
                    cases=numeric(0), deaths = numeric(0),
                    cases2=numeric(0), deaths2 = numeric(0), 
                    date1=character(0), date2 = character(0))

for(i in 1:(length(names(day_list)) - 1) ){
  day1 <- names(day_list)[i]
  day2 <- names(day_list)[i+1]
  
  df1 <- day_list[[day1]] %>% 
    filter(county != "Unknown")
  
  df2 <- day_list[[day2]] %>% 
    filter(county != "Unknown") %>% 
    rename(cases2 = cases, deaths2 = deaths)
  
  df <- inner_join(df1, df2)
  df %<>% filter((cases2 < cases) | (deaths2 < deaths))
  
  if(dim(df)[1]>0){
    df$date1 <- day1
    df$date2 <- day2
    final <- bind_rows(final, df)
  }
}

write_csv(final, "weird_counties.csv")
