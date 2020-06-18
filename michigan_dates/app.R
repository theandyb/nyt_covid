#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readxl)
library(tidyverse)
library(lubridate)
library(rlang)
library(plotly)
library(htmlwidgets)

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

df5 <- read_the_data("../data/MI_2020-06-17.xlsx")
df4 <- read_the_data("../data/MI_2020-06-16.xlsx")
df3 <- read_the_data("../data/MI_2020-06-15.xlsx")
df2 <- read_the_data("../data/MI_2020-06-14.xlsx")

df <- read_excel("../data/MI_confirmed_prob_6-13.xlsx") %>%
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

df <- df %>% mutate(tCase1 = cCase1 + pCase1, tDeath1 = cDeath1 + pDeath1)
df2 <- df2 %>% mutate(tCase2 = cCase2 + pCase2, tDeath2 = cDeath2 + pDeath2)
df3 <- df3 %>% mutate(tCase3 = cCase3 + pCase3, tDeath3 = cDeath3 + pDeath3)
df4 <- df4 %>% mutate(tCase4 = cCase4 + pCase4, tDeath4 = cDeath4 + pDeath4)
df5 <- df5 %>% mutate(tCase5 = cCase5 + pCase5, tDeath5 = cDeath5 + pDeath5)


df <- full_join(df, df2, by=c("COUNTY", "Date")) %>% 
    full_join(df3, by=c("COUNTY", "Date")) %>%
    full_join(df4, by=c("COUNTY", "Date")) %>%
    full_join(df5, by=c("COUNTY", "Date"))

counties <- c("All",unique(df$COUNTY))

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("The Michigan Difference"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput("county", "County", counties),
            selectInput("type", "Variable", c("tCase", "cCase", "pCase", "tDeath","cDeath", "pDeath"))
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotlyOutput("cntPlt")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$cntPlt <- renderPlotly({
        
        if(input$county != "All"){
            vizdat <- df %>% filter(COUNTY == input$county)
        } else{
            vizdat <- df %>% select(-COUNTY) %>% group_by(Date) %>%
                summarise_at(vars(-group_cols()), sum)
        }
        vizdat <- vizdat %>%
            gather(type, measure, cCase1:tDeath5) %>% 
            arrange(Date) %>%
            filter(!is.na(measure))
        
        p<- vizdat %>% filter(grepl(input$type, type)) %>%
            filter(Date >= as.Date("2020-06-01")) %>%
            ggplot(aes(x = Date, y = measure, colour = type)) +
            geom_point() + geom_line() + ylab("Count") + labs( colour = "Day of Report") +
            scale_color_discrete(labels = c("6/13","6/14","6/15","6/16","6/17"))
        ggplotly(p)
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
