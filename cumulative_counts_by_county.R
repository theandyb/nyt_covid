library(tidyverse)
library(magrittr)
library(lubridate)
library(xlsx)

counties <- read_csv("data/us-counties.csv")

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

final_rows <- list()
counter <- 1
for(s in unique(counties$state)){
  df1 <- data.frame(state = s, county = "All")
  df2 <- day_list[[names(day_list)[1]]] %>% select(state, county) %>% filter(state == s)
  final_rows[[counter]] <- bind_rows(df1, df2)
  counter <- counter + 1
}

final <- bind_rows(final_rows) %>% arrange(state)

for(i in names(day_list)){
  df <- day_list[[i]] %>% arrange(state)
  final_rows <- list()
  counter <- 1
  for(s in unique(df$state)){
    df1 <- data.frame(cases = df %>% filter(state == s) %>% pull(cases) %>% sum(),
                      deaths = df %>% filter(state == s) %>% pull(deaths) %>% sum())
    df2 <- df %>% filter(state == s) %>% select(cases, deaths)
    final_rows[[counter]] <- bind_rows(df1, df2)
    counter <- counter + 1
  }
  df <- bind_rows(final_rows)
  names(df) <- c(paste0(i, "-cases"), paste0(i,"-deaths"))
  final <- bind_cols(final, df)
}

write.xlsx(final, "data/cumulative_county_counts.xlsx")
