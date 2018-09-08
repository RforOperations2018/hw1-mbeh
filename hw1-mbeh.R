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
  
  output$plot <- renderPlotly({
    
    # Filter plot data based on passenger class and age range inputs
    min_age <- input$age_range[1]
    max_age <- input$age_range[2]
    plot_data <- filter(titanic_data, Pclass %in% input$pclass_select, Age >= min_age, Age <= max_age)
    
    # Define function (used by ggplot) that customizes text displayed for 0/1 Survived label
    get_label_for_Survived_column <- function(variable, value){
      ifelse(value == "1", "Survived", "Did not survive")
    }
    
    plot <- ggplot() +
      geom_jitter(data = plot_data, aes(Pclass, Age, colour = factor(Sex), text = paste0("Age: ", Age, "<br>",
                                                                                         "Class: ", Pclass, "<br>",
                                                                                         "Sex: ", Sex ))) + 
      facet_grid(Survived ~ ., labeller = get_label_for_Survived_column) +
      # show integral values on x axis
      scale_x_continuous(breaks = function(x) seq(max(x))) + 
      scale_color_brewer(palette = "Set1") +
      # configure axis/legend labels and themes
      ggtitle("Survival of Titanic Passengers : by Age, Sex, Passenger Class") +
      xlab("Passenger Class") +
      labs(color = "Sex") +
      theme_gray()
    
    ggplotly(plot, tooltip = "text") %>%
      layout(legend = list(orientation = "h", x = 0, y = -0.1))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

