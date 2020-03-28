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
           tableOutput("stateTot"),
           tableOutput("counts"),
           tableOutput("stateTotals")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    cur_date <- function(){
        format(input$date1, "%Y-%m-%d")
    }
    
    output$stateTot <- renderTable({
        counties %>% filter(date == cur_date(), state == input$state) %>%
            group_by(state) %>% summarise(cases = sum(cases), deaths = sum(deaths))
    })
    output$counts <- renderTable({
        counties %>% filter(date==cur_date(), state == input$state) %>%
            arrange(county)
    })
    output$stateTotals <- renderTable({
        counties %>% filter(date==cur_date()) %>%
            group_by(state) %>% summarise(cases = sum(cases), deaths = sum(deaths))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
