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
    titlePanel("Case Growth Over Time"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput("state", "State:", sort(unique(counties$state))),
            uiOutput("countyControl"),
            checkboxInput("smooth", "Smooth?"),
            checkboxInput("log", "Log Scale?")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        df <- counties %>% 
            filter(state == input$state, county == input$county) %>%
            arrange(date) %>%
            gather(type, count, 5:6)
        if(input$log == TRUE){
            df %<>% mutate(count = log10(count))
        }
        
        p <- df %>%
            ggplot(aes(x = date, y = count, color = factor(type)))+
            geom_point() + xlab("Date")
        
        if(input$smooth==TRUE){
            p <- p + geom_smooth()
        }
        
        if(input$log == TRUE){
            p <- p + ylab("log10 Count")
        } else {
            p <- p + ylab("Count")
        }
        p
    })
    
    output$countyControl <- renderUI({
        county_list <- state_county %>% filter(state==input$state) %>% pull(county)
        selectInput("county", "County:", county_list)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
