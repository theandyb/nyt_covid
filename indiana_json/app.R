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

# Get the data from the state's JSON feed(?)
json_data <- jsonlite::fromJSON(
  "https://www.coronavirus.in.gov/map/covid-19-indiana-daily-report-current.topojson")
VIZ_DATE <- json_data$objects$cb_2015_indiana_county_20m[[2]]$properties$VIZ_DATE
rm(json_data)

num_dates <- dim(VIZ_DATE[[13]])[1]
results <- vector(mode = "list", length = 92) # 92 counties in Indiana

for(i in 1:length(VIZ_DATE)){
  results[[i]] <- VIZ_DATE[[i]] %>%
    select(COUNTY_NAME, DATE, COVID_COUNT_CUMSUM, COVID_DEATHS_CUMSUM)
}
df <- bind_rows(results) %>%
  rename(County = COUNTY_NAME, 
         Date = DATE,
         Cases = COVID_COUNT_CUMSUM,
         Deaths = COVID_DEATHS_CUMSUM)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Indiana Cumulative Case and Death Counts"),
  
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
    df %>% filter(Date == as.Date(input$date1)) %>%
      select(County, Cases, Deaths) %>%
      arrange(County)
  })
  output$stateTotal <- renderTable({
    totalCases <- dataTable() %>% pull(Cases) %>% sum()
    totalDeaths <- dataTable() %>% pull(Deaths) %>% sum()
    data.frame(state = "Indiana", Cases = totalCases, Deaths = totalDeaths)
  })
  output$finalTable <- renderTable({
    dataTable()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
