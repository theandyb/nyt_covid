library(readxl)
library(tidyverse)
library(lubridate)
library(rlang)

'%!in%' <- function(x,y)!('%in%'(x,y))

read_the_data <- function(fname){
   tmp <- read_excel(fname) %>% filter(!is.na(Date))
   tmp.confirmed <- tmp %>% 
      filter(CASE_STATUS == "Confirmed") %>%
      select(COUNTY, Date, Cases.Cumulative, Deaths.Cumulative) %>%
      mutate(Date = as_date(Date)) %>%
      rename(cCase = Cases.Cumulative, cDeath = Deaths.Cumulative)
   
   tmp.probable <- tmp %>% 
      filter(CASE_STATUS == "Probable") %>%
      select(COUNTY, Date, Cases.Cumulative, Deaths.Cumulative) %>%
      mutate(Date = as_date(Date)) %>%
      rename(pCase = Cases.Cumulative, pDeath = Deaths.Cumulative)
   
   return(full_join(tmp.confirmed, tmp.probable))
}

df5 <- read_the_data("data/MI_2020-06-17.xlsx")
df4 <- read_the_data("data/MI_2020-06-16.xlsx")
df3 <- read_the_data("data/MI_2020-06-15.xlsx")
df2 <- read_the_data("data/MI_2020-06-14.xlsx")

df <- read_excel("data/MI_confirmed_prob_6-13.xlsx") %>%
  select(COUNTY, `Date *`, `Confirmed Cases.Cumulative`, `Confirmed Deaths.Cumulative`,
         `Probable Cases.Cumulative`, `Probable Deaths.Cumulative`) %>%
  rename(Date = `Date *`,
         cCase = `Confirmed Cases.Cumulative`,
         cDeath = `Confirmed Deaths.Cumulative`,
         pCase = `Probable Cases.Cumulative`,
         pDeath = `Probable Deaths.Cumulative`) %>%
  mutate(Date = as_date(Date)) %>%
  filter(!is.na(Date))

renamer <- function(df, num){
   v1 <- paste0("cCase",num) %>% sym()
   v2 <- paste0("cDeath",num) %>% sym()
   v3 <- paste0("pCase",num) %>% sym()
   v4 <- paste0("pDeath",num) %>% sym()
   df %>% rename(!!v1 := cCase,
                !!v2 := cDeath,
                !!v3 := pCase,
                !!v4 := pDeath)
}

df <- df %>%
   renamer(1)
df2 <- df2 %>%
   renamer(2)
df3 <- df3 %>%
   renamer(3)
df4 <- df4 %>%
   renamer(4)
df5 <- df5 %>%
   renamer(5)


df <- full_join(df, df2, by=c("COUNTY", "Date")) %>% 
   full_join(df3, by=c("COUNTY", "Date")) %>%
   full_join(df4, by=c("COUNTY", "Date")) %>%
   full_join(df5, by=c("COUNTY", "Date"))

wayne <- df %>% filter(COUNTY == "Wayne") %>%
   gather(type, measure, cCase1:pDeath4) %>% 
   arrange(Date) %>%
   filter(!is.na(measure))

### Question: how variable are cCase and pCase values from the three different datasets?

wayne %>% filter(grepl("cCase", type)) %>%
   filter(Date >= as.Date("2020-06-01")) %>%
   ggplot(aes(x = Date, y = measure, colour = type)) +
   geom_point()

###
day_list <- unique(df3$Date)
counties <- unique(df3 %>% filter(COUNTY %!in% c("Detroit City", "FCI", "MDOC", "Out-of-State", "Unknown")) %>% pull(COUNTY))
counties <- c(counties, "Unknown")

table_gen <- function(df, day){
   df2 <- df %>% 
       filter(Date == day) %>% 
       arrange(COUNTY) %>%
       mutate(cases = cCase + pCase,
              deaths = cDeath + pDeath) %>%
       select(COUNTY, cases, deaths)
   
   wayne_tot <- df2[which(df2$COUNTY == "Detroit City"), 2:3] +
     df2[which(df2$COUNTY == "Wayne"), 2:3]
   wayne_tot <- bind_cols(data.frame(COUNTY = "Wayne"), wayne_tot)
   
   unknown_tot <- df2[which(df2$COUNTY == "FCI"), 2:3] +
     df2[which(df2$COUNTY == "MDOC"), 2:3] +
     df2[which(df2$COUNTY == "Out-of-State"), 2:3] +
     df2[which(df2$COUNTY == "Unknown"), 2:3]
   unknown_tot <- bind_cols(data.frame(COUNTY = "Unknown"), unknown_tot)
   
   df2 <- df2 %>% filter(COUNTY %!in% c("Wayne", "Detroit City", "FCI", "MDOC", "Out-of-State", "Unknown"))
   df2 <- bind_rows(df2, wayne_tot) %>% arrange(COUNTY) %>% bind_rows(unknown_tot)
   return(df2)
}

final <- data.frame(COUNTY = counties)

for(day in day_list){
   print(day)
   little_df <- table_gen(df3, day)
   colnames(little_df) <- c("COUNTY", paste0("cases-",anydate(day)), paste0("deaths-",anydate(day)))
   final <- full_join(final, little_df)
}
writexl::write_xlsx(final, "michigan_6_14.xlsx")
