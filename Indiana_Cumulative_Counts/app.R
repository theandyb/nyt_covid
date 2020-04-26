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

df <- read_csv("covid_report_stratified_20200425.csv")

cases_as_of_date <-function(Day, County,df){
    df %>% 
        filter(report_investigation_date <= as.Date(Day)) %>% 
        filter(county == County) %>%
        pull(case_count) %>% sum()
}

table_gen <- function(df, Day){
    
    final <- tibble(county = sort(unique(df$county)))
    counts <- c()
    
    for(County in final$county){
        counts <- c(counts, cases_as_of_date(Day, County,df))
    }
    final$case_count <- counts
    return(final)
}

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Indiana Cumulative Case Counts"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            dateInput("date1", "Date:")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           tableOutput("stateTotal"),
           tableOutput("finalTable")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    dataTable <- reactive({
        table_gen(df, input$date1)
    })
    output$stateTotal <- renderTable({
        total <- dataTable() %>% pull(case_count) %>% sum()
        data.frame(state = "Indiana", total = total)
    })
    output$finalTable <- renderTable({
        dataTable()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
