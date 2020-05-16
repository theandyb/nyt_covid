library(shiny)
library(tidyverse)
library(xlsx)

df <- read.xlsx("covid_report_county_date.xlsx", 1)

cases_as_of_date <-function(Day, County,df){
    df %>% 
        filter(DATE <= as.Date(Day)) %>% 
        filter(COUNTY_NAME == County) %>%
        pull(COVID_COUNT) %>% sum()
}

deaths_as_of_date <-function(Day, County,df){
    df %>% 
        filter(DATE <= as.Date(Day)) %>% 
        filter(COUNTY_NAME == County) %>%
        pull(COVID_DEATHS) %>% sum()
}

table_gen <- function(df, Day){
    
    final <- tibble(county = sort(unique(df$COUNTY_NAME)))
    counts <- c()
    deaths <- c()
    
    for(County in final$county){
        counts <- c(counts, cases_as_of_date(Day, County,df))
        deaths <- c(deaths, deaths_as_of_date(Day, County,df))
    }
    final$case_count <- counts
    final$deaths <- deaths
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
