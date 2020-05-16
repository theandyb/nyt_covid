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

counties <- read_csv("../data/covid-19-data/us-counties.csv")

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

state_list <- c("All", sort(unique(counties$state)))

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Counties with shrinking counts"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput("state", "State:", state_list)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           tableOutput("finalTable")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$finalTable <- renderTable({
        if(input$state != "All"){
            final %>% filter(state == input$state)
        } else{
            final
        }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
