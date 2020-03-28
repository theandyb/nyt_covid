#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(magrittr)
library(lubridate)

counties <- read_csv("../data/us-counties.csv")

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
    if(cur_date == min(unique(counties$date))){
        df <- counties %>% 
            filter(date == cur_date) %>% 
            select(state, county, cases, deaths)
        df %<>% right_join(state_county, by = c("state", "county")) %>%
            replace_na(list(cases = 0, deaths = 0))
        day_list[[as.character(cur_date)]] <- df
    }
    else {
        df <- counties %>% 
            filter(date == cur_date) %>% 
            select(state, county, cases, deaths)
        df %<>% right_join(state_county, by = c("state", "county")) %>%
            replace_na(list(cases = 0, deaths = 0))
        df$cases <- df$cases + day_list[[as.character(cur_date - 1)]]$cases
        df$deaths <- df$deaths + day_list[[as.character(cur_date - 1)]]$deaths
        day_list[[as.character(cur_date)]] <- df
    }
}
names(day_list) <- as.character(unique(counties$date))

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("COVID Cumulative Counts by Date"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            dateInput("date1", "Date:", value = min(counties$date)),
            selectInput("state", "State:", sort(unique(counties$state)))
        ),

        # Show a plot of the generated distribution
        mainPanel(
           tableOutput("counts")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$counts <- renderTable({
        day_list[[format(input$date1, "%Y-%m-%d")]] %>% 
            filter(state == input$state) %>%
            arrange(county)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
