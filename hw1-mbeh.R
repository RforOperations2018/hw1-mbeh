# Homework 1
# By Min Yan BEH (mbeh)

# If titanic dataset doesn't exist, run code below:
# install.packages("titanic")

library(shiny)
library(reshape2)
library(dplyr)
library(plotly)
library(DT)
library(plyr)
library(titanic)

# Use only train data as test data doesn't have Survived label
titanic_data <- titanic_train
pdf(NULL)


# Define UI for application that draws a scatter plot of people who survived or not
ui <- fluidPage(
  
  # Application title
  titlePanel("The Titanic: Who Survived?"),
  
  # Sidebar
  sidebarLayout(
    sidebarPanel(
      # selection input for passenger class
      selectInput("pclass_select",
                  "Passenger Class:",
                  choices = as.character(seq(3)),
                  multiple = TRUE,
                  selectize = TRUE,
                  selected = as.character(seq(3))),
      
      # sliding range input for defining min/max passenger age
      sliderInput("age_range", 
                  "Age Range:",
                  min = 0, 
                  max = 100, 
                  value = c(0,100)
      )
    ),
    mainPanel(
      
      # Tabs for plot and table
      tabsetPanel(
        tabPanel("Plot", 
                 plotlyOutput("plot")
        ),
        tabPanel("Table",
                 DT::dataTableOutput("table")
        )
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
}

# Run the application 
shinyApp(ui = ui, server = server)

