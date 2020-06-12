library(tidyverse)
library(writexl)
library(anytime)

counties <- c("Adams","Allen","Ashland","Ashtabula","Athens","Auglaize","Belmont",
              "Brown","Butler","Carroll","Champaign","Clark", "Clermont", "Clinton", "Columbiana", 
              "Coshocton", "Crawford", "Cuyahoga", "Darke", "Defiance", "Delaware", "Erie",
              "Fairfield", "Fayette", "Franklin", "Fulton", "Gallia", "Geauga", "Greene", "Guernsey", "Hamilton",
              "Hancock", "Hardin", "Harrison", "Henry", "Highland", "Hocking", "Holmes", "Huron", "Jackson",
              "Jefferson", "Knox", "Lake", "Lawrence", "Licking", "Logan", "Lorain", "Lucas", "Madison",
              "Mahoning", "Marion", "Medina", "Meigs", "Mercer", "Miami", "Monroe", "Montgomery",
              "Morgan", "Morrow", "Muskingum", "Noble", "Ottawa", "Paulding", "Perry", "Pickaway",
              "Pike", "Portage", "Preble", "Putnam", "Richland", "Ross", "Sandusky", "Scioto", "Seneca", "Shelby",
              "Stark", "Summit", "Trumbull", "Tuscarawas", "Union",
              "Van Wert","Vinton","Warren", "Washington", "Wayne", "Williams", "Wood", "Wyandot")
df <- read_csv("https://coronavirus.ohio.gov/static/COVIDSummaryData.csv") %>%
  filter(County != "Grand Total") %>%
  arrange(County, `Onset Date`) %>%
  rename(age = `Age Range`,
         caseDate = `Onset Date`,
         deathDate = `Date Of Death`,
         adDate = `Admission Date`,
         cases = `Case Count`,
         deaths = `Death Count`,
         hospitalized = `Hospitalized Count`) %>%
  mutate(caseDate = paste0(0, caseDate),
         deathDate = paste0(0, deathDate),
         adDate = paste0(0, adDate)) %>%
  mutate(caseDate = as.Date(caseDate,"%m/%d/%y"),
         deathDate = as.Date(deathDate,"%m/%d/%y"),
         adDate = as.Date(adDate,"%m/%d/%y"))

deaths_as_of_date <- function(df, Day){
  deaths <- df %>% 
    filter(!is.na(deathDate)) %>%
    filter(deathDate <= Day) %>%
    group_by(County) %>%
    summarize(deaths = sum(deaths))
  return(deaths)
}

cases_as_of_date <- function(df, Day){
  cases <- df %>% 
    filter(!is.na(caseDate)) %>%
    filter(caseDate <= Day) %>%
    group_by(County) %>%
    summarize(cases = sum(cases))
  return(cases)
}

table_gen <- function(df, Day){
  cases <- cases_as_of_date(df, Day)
  deaths <- deaths_as_of_date(df, Day)
  
  total <- tibble(County = counties)
  total <- full_join(total,cases) %>% replace_na(list(cases = 0))
  total <- full_join(total,deaths) %>% replace_na(list(deaths = 0))
  return(total)
}

day_list <- sort(unique(df$caseDate))

for(day in day_list){
  print(anytime::anydate(day))
}

final <- data.frame(County = counties)
for(day in day_list){
  little_df <- table_gen(df, day)
  colnames(little_df) <- c("County", paste0("cases-",anydate(day)), paste0("deaths-",anydate(day)))
  final <- full_join(final, little_df)
}

writexl::write_xlsx(final, "ohio.xlsx")
